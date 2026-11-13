import 'dart:convert';

import 'package:libretapp/core/database/write_transaction.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/models/animal_batch_draft.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

enum BatchLotChoice { none, existing, create }

class AnimalBatchSession {
  const AnimalBatchSession({
    this.animals = const [],
    this.lotChoice = BatchLotChoice.none,
    this.lotUuid,
    this.newLotName = '',
    this.newLotDescription = '',
  });

  final List<AnimalBatchDraft> animals;
  final BatchLotChoice lotChoice;
  final String? lotUuid;
  final String newLotName;
  final String newLotDescription;

  AnimalBatchSession copyWith({
    List<AnimalBatchDraft>? animals,
    BatchLotChoice? lotChoice,
    String? lotUuid,
    String? newLotName,
    String? newLotDescription,
  }) => AnimalBatchSession(
    animals: animals ?? this.animals,
    lotChoice: lotChoice ?? this.lotChoice,
    lotUuid: lotUuid ?? this.lotUuid,
    newLotName: newLotName ?? this.newLotName,
    newLotDescription: newLotDescription ?? this.newLotDescription,
  );

  Map<String, dynamic> toJson() => {
    'version': 1,
    'animals': animals.map((draft) => draft.toJson()).toList(),
    'lotChoice': lotChoice.name,
    'lotUuid': lotUuid,
    'newLotName': newLotName,
    'newLotDescription': newLotDescription,
  };

  factory AnimalBatchSession.fromJson(
    Map<String, dynamic> json,
  ) => AnimalBatchSession(
    animals: (json['animals'] as List? ?? const [])
        .map(
          (item) =>
              AnimalBatchDraft.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    lotChoice: BatchLotChoice.values.byName(
      json['lotChoice'] as String? ?? 'none',
    ),
    lotUuid: json['lotUuid'] as String?,
    newLotName: json['newLotName'] as String? ?? '',
    newLotDescription: json['newLotDescription'] as String? ?? '',
  );
}

class AnimalBatchRegistration {
  AnimalBatchRegistration({
    required this.preferences,
    required this.animals,
    required this.lots,
    required this.health,
    required this.movements,
    required this.reproduction,
    required this.transactions,
  });

  static const draftKey = 'animal.batch.registration.v1';
  final SharedPrefsService preferences;
  final AnimalRepository animals;
  final LotesRepository lots;
  final HealthRecordRepository health;
  final MovementRecordRepository movements;
  final ReproductionRecordRepository reproduction;
  final WriteTransactionRunner transactions;

  AnimalBatchSession load() {
    final raw = preferences.getString(draftKey);
    if (raw == null) return const AnimalBatchSession();
    return AnimalBatchSession.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  Future<void> persist(AnimalBatchSession session) =>
      preferences.setString(draftKey, jsonEncode(session.toJson()));

  Future<void> discard() => preferences.remove(draftKey);

  Future<String?> commit(AnimalBatchSession session) async {
    if (session.animals.isEmpty) throw StateError('Agrega al menos un animal.');
    final identifiers = <String>{};
    for (final draft in session.animals) {
      final tag = draft.animal.earTagNumber.trim().toLowerCase();
      if (tag.isNotEmpty && !identifiers.add(tag)) {
        throw StateError('Hay identificaciones repetidas en la lista.');
      }
    }

    // A completed write can leave a stale preferences draft if the process
    // stops between the database commit and clearing the preference.
    final alreadyWritten = await Future.wait(
      session.animals.map((draft) => animals.getByUuid(draft.animal.uuid)),
    );
    if (alreadyWritten.every((animal) => animal != null)) {
      try {
        await discard();
      } catch (_) {}
      return alreadyWritten.first!.batchUuid;
    }
    if (alreadyWritten.any((animal) => animal != null)) {
      throw StateError(
        'Algunos animales ya existen. Revisa la lista antes de guardar.',
      );
    }

    final existingAnimals = await animals.getAllIncludingInactive();
    for (final tag in identifiers) {
      if (AnimalRegistrationNormalizer.isDuplicateIdentification(
        candidate: tag,
        animals: existingAnimals,
      )) {
        throw StateError('La identificación $tag ya pertenece a otro animal.');
      }
    }
    if (session.lotChoice == BatchLotChoice.create &&
        session.newLotName.trim().isEmpty) {
      throw StateError('Escribe un nombre para el lote.');
    }
    if (session.lotChoice == BatchLotChoice.existing) {
      final lot = session.lotUuid == null
          ? null
          : await lots.getByUuid(session.lotUuid!);
      if (lot == null || !lot.active) {
        throw StateError('El lote ya no está activo. Elige otro.');
      }
    }

    String? selectedLotUuid;
    await transactions.run(() async {
      if (session.lotChoice == BatchLotChoice.create) {
        final lot = await lots.createLote(
          nombre: session.newLotName.trim(),
          descripcion: session.newLotDescription.trim(),
        );
        selectedLotUuid = lot.uuid;
      } else if (session.lotChoice == BatchLotChoice.existing) {
        selectedLotUuid = session.lotUuid;
        final currentLot = await lots.getByUuid(selectedLotUuid!);
        if (currentLot == null || !currentLot.active) {
          throw StateError('El lote ya no está activo. Elige otro.');
        }
      }
      for (final draft in session.animals) {
        final animal = draft.animal.copyWith(batchUuid: selectedLotUuid);
        await animals.save(animal);
        final location = animal.initialLocationId;
        if (location != null) {
          await movements.addMovementRecord(
            animal.uuid,
            MovementRecord(
              toLocation: location,
              date: animal.lastMovementDate ?? animal.creationDate,
              reason: MovementReason.relocation,
              notes: 'Ubicación inicial al momento del registro',
            ),
          );
        }
        for (final data in draft.healthRecords) {
          await health.addHealthRecord(
            animal.uuid,
            HealthRecord(
              type: HealthRecordType.values.byName(data['type'] as String),
              product: data['product'] as String? ?? '',
              dose: data['dose'] as String?,
              date: DateTime.fromMillisecondsSinceEpoch(data['date'] as int),
              notes: data['notes'] as String?,
            ),
          );
        }
        for (final data in draft.reproductionRecords) {
          await reproduction.addReproductionRecord(
            animal.uuid,
            ReproductionRecord(
              serviceDate: DateTime.fromMillisecondsSinceEpoch(
                data['serviceDate'] as int,
              ),
              serviceType: ServiceType.values.byName(
                data['serviceType'] as String,
              ),
              maleSireIdentifier: data['maleSireIdentifier'] as String?,
              pregnancyResult: data['pregnancyResult'] == null
                  ? null
                  : PregnancyCheckResult.values.byName(
                      data['pregnancyResult'] as String,
                    ),
              expectedCalvingDate: data['expectedCalvingDate'] == null
                  ? null
                  : DateTime.fromMillisecondsSinceEpoch(
                      data['expectedCalvingDate'] as int,
                    ),
              notes: data['notes'] as String?,
            ),
          );
        }
      }
      if (selectedLotUuid != null) {
        await lots.addAnimalsToLote(
          loteUuid: selectedLotUuid!,
          animalUuids: session.animals
              .map((draft) => draft.animal.uuid)
              .toList(),
        );
      }
    });
    try {
      await discard();
    } catch (_) {}
    return selectedLotUuid;
  }
}
