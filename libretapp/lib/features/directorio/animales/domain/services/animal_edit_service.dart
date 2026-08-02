/// features › directorio › animales › domain › services › animal_edit_service — canonical animal edit workflow.
library;

import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/care_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/sex.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_lifecycle_calculator.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_registration_normalizer.dart';
import 'package:libretapp/features/directorio/animales/domain/services/care_calendar_service.dart';
import 'package:libretapp/features/directorio/animales/domain/services/pedigree_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

/// Thrown by [AnimalEditService.applyEdit] when a draft cannot be persisted
/// as-is: a duplicate ear tag, or a genealogically invalid sire/dam.
///
/// A typed exception (rather than a bare [Exception] or a result object)
/// because every existing save flow already has a `catch (e)` block that
/// shows `e` (or `e.toString()`) to the user — this slots into that pattern
/// with a message that is already user-facing, in Spanish.
class AnimalEditValidationException implements Exception {
  const AnimalEditValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Canonical entry point for persisting an edit to an existing
/// [AnimalEntity].
///
/// Every screen that lets a user edit an animal already loaded from storage
/// — `RegisterAnimalPage` in edit mode, `AnimalEditPage`, the
/// location/batch bottom sheet, and the list's quick location-assign action
/// — should route the save through [applyEdit] instead of calling
/// `AnimalRepository.update` directly. Before this service existed, each of
/// those screens re-implemented (and subtly diverged on) the same diffing
/// logic: whether to move the animal out of its old lote and into the new
/// one, whether to record a [MovementRecord], and whether to touch
/// `lastMovementDate`. `applyEdit` is the one place that gets it right, so
/// every caller does too.
class AnimalEditService {
  AnimalEditService({
    required AnimalRepository animalRepository,
    required LotesRepository lotesRepository,
    required MovementRecordRepository movementRepository,
    required CareRepository careRepository,
    required AgendaReminderSyncService agendaReminderSyncService,
    CareCalendarService? careCalendarService,
  }) : _animalRepository = animalRepository,
       _lotesRepository = lotesRepository,
       _movementRepository = movementRepository,
       _careRepository = careRepository,
       _agendaReminderSyncService = agendaReminderSyncService,
       _careCalendarService =
           careCalendarService ?? CareCalendarService(careRepository);

  final AnimalRepository _animalRepository;
  final LotesRepository _lotesRepository;
  final MovementRecordRepository _movementRepository;
  final CareRepository _careRepository;
  final AgendaReminderSyncService _agendaReminderSyncService;
  final CareCalendarService _careCalendarService;

  static const _pedigree = PedigreeService();

  /// Applies [draft] as the new state of [original] and returns the animal
  /// as it was actually persisted.
  ///
  /// [original] only needs to carry the right `uuid` — every other field is
  /// re-read from storage right before mutating anything, so calling
  /// `applyEdit` twice in a row with the same (possibly stale) `original`
  /// and `draft` is safe: the second call sees its own first call's result
  /// as "already applied" and does not repeat side effects like creating a
  /// second [MovementRecord] or re-touching `lastMovementDate`.
  ///
  /// Throws [AnimalEditValidationException] — without writing anything —
  /// when [draft] would create a duplicate ear tag or an invalid pedigree
  /// link (the animal as its own parent, or a cycle).
  Future<AnimalEntity> applyEdit({
    required AnimalEntity original,
    required AnimalEntity draft,
  }) async {
    final uuid = original.uuid;
    if (draft.uuid != uuid) {
      throw const AnimalEditValidationException(
        'No se puede cambiar el identificador del animal al editarlo.',
      );
    }

    // Diff against what is actually stored right now, never against
    // `original` on its own — that is what keeps a repeated call from
    // double-applying a movement or a lote change (see the doc comment
    // above).
    final persisted = await _animalRepository.getByUuid(uuid);
    if (persisted == null) {
      throw const AnimalEditValidationException(
        'No se encontró el animal que se intenta editar.',
      );
    }

    final herd = await _animalRepository.getAll();

    if (AnimalRegistrationNormalizer.isDuplicateIdentification(
      candidate: draft.earTagNumber,
      animals: herd,
      excludingUuid: uuid,
    )) {
      throw AnimalEditValidationException(
        'Ya existe otro animal con el arete "${draft.earTagNumber}".',
      );
    }

    var next = draft.copyWith(
      uuid: uuid,
      creationDate: persisted.creationDate,
      lastUpdateDate: DateTime.now(),
      synced: false,
    );

    // Biology changed: age and life stage are derived, not user-entered,
    // so they must be recomputed rather than trusted from the draft.
    if (next.species != persisted.species ||
        next.sex != persisted.sex ||
        next.birthDate != persisted.birthDate) {
      final lifecycle = AnimalLifecycleCalculator.calculate(
        birthDate: next.birthDate,
        species: next.species,
        sex: next.sex,
        currentLifeStage: next.lifeStage,
      );
      next = next.copyWith(
        ageMonths: lifecycle.ageMonths,
        lifeStage: lifecycle.lifeStage,
      );
    }

    if (next.sireUuid != persisted.sireUuid ||
        next.damUuid != persisted.damUuid) {
      _validatePedigree(animal: next, herd: herd);
    }

    // Location diff: `lastMovementDate` (and the MovementRecord itself)
    // must only move when the location genuinely changed — not whenever
    // the lote happens to change too.
    final locationChanged =
        next.currentLocationId != persisted.currentLocationId;
    if (locationChanged) {
      final newLocation = next.currentLocationId;
      if (newLocation != null) {
        await _movementRepository.addMovementRecord(
          uuid,
          MovementRecord(
            fromLocation: persisted.currentLocationId,
            toLocation: newLocation,
            date: DateTime.now(),
            reason: MovementReason.paddockRotation,
          ),
        );
      }
      next = next.copyWith(
        lastMovementDate: DateTime.now(),
        initialLocationId: persisted.initialLocationId ?? newLocation,
      );
    } else {
      next = next.copyWith(
        lastMovementDate: persisted.lastMovementDate,
        initialLocationId: persisted.initialLocationId,
      );
    }

    // Leaving the active herd always drops lote membership, regardless of
    // what the draft's batchUuid says — a sold/dead/archived animal does
    // not linger on a lote roster.
    final leavingHerd =
        persisted.status.isInActiveHerd && !next.status.isInActiveHerd;
    if (leavingHerd) {
      next = next.copyWith(batchUuid: null);
      // `regenerateFor` is only called for the active herd (below), so
      // without this, whatever was already pending stays pending forever —
      // the animal's own Cuidados tab would keep showing tasks for a cow
      // that was just sold. Manual (non-auto-generated) entries are left
      // alone; only the rule-derived ones are cleared.
      await _careRepository.clearGeneratedFor(uuid);
    }

    final batchChanged = next.batchUuid != persisted.batchUuid;
    if (batchChanged && persisted.batchUuid != null) {
      await _lotesRepository.removeAnimalFromLote(
        loteUuid: persisted.batchUuid!,
        animalUuid: uuid,
      );
    }

    final saved = await _animalRepository.update(next);

    if (batchChanged && next.batchUuid != null) {
      await _lotesRepository.addAnimalToLote(
        loteUuid: next.batchUuid!,
        animalUuid: uuid,
      );
    }

    // A sold/dead/archived animal is not due for anything new — whatever
    // was already scheduled stays, nothing new gets generated for it.
    if (saved.status.isInActiveHerd) {
      await _careCalendarService.regenerateFor(saved);
    }
    await _agendaReminderSyncService.sync();

    return saved;
  }

  /// Rejects [animal] as its own parent, and rejects a proposed sire/dam
  /// that is actually one of [animal]'s own descendants (which would turn
  /// the pedigree into a cycle). Reuses [PedigreeService.candidateParents],
  /// the same lookup the registration forms use to populate their sire/dam
  /// dropdowns, so "valid parent" means the same thing everywhere.
  void _validatePedigree({
    required AnimalEntity animal,
    required List<AnimalEntity> herd,
  }) {
    final sireUuid = _normalize(animal.sireUuid);
    final damUuid = _normalize(animal.damUuid);
    if (sireUuid == null && damUuid == null) return;

    if (sireUuid == animal.uuid || damUuid == animal.uuid) {
      throw const AnimalEditValidationException(
        'Un animal no puede ser su propio padre o madre.',
      );
    }

    if (sireUuid != null) {
      final eligible = _pedigree.candidateParents(
        herd: herd,
        sex: Sex.male,
        excluding: animal,
      );
      if (!eligible.any((candidate) => candidate.uuid == sireUuid)) {
        throw const AnimalEditValidationException(
          'El padre seleccionado no es válido: crearía un ciclo '
          'genealógico o no corresponde a la especie del animal.',
        );
      }
    }

    if (damUuid != null) {
      final eligible = _pedigree.candidateParents(
        herd: herd,
        sex: Sex.female,
        excluding: animal,
      );
      if (!eligible.any((candidate) => candidate.uuid == damUuid)) {
        throw const AnimalEditValidationException(
          'La madre seleccionada no es válida: crearía un ciclo '
          'genealógico o no corresponde a la especie del animal.',
        );
      }
    }
  }

  static String? _normalize(String? uuid) {
    if (uuid == null) return null;
    final trimmed = uuid.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
