library;

import 'package:libretapp/features/agenda/data/agenda_refresh_signal.dart';
import 'package:libretapp/features/agenda/data/agenda_registration_repository.dart';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/features/agenda/data/agenda_recurrence.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/domain/agenda_registration.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/care_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:uuid/uuid.dart';

class AgendaRegistrationCoordinator {
  AgendaRegistrationCoordinator({
    required AgendaRepository agendaRepository,
    required AgendaRegistrationRepository registrationRepository,
    required HealthRecordRepository healthRepository,
    required WeightRecordRepository weightRepository,
    required MovementRecordRepository movementRepository,
    required ReproductionRecordRepository reproductionRepository,
    required CareRepository careRepository,
    required LotesRepository lotesRepository,
    AgendaReminderSyncService? reminderSyncService,
    AgendaRefreshSignal? refreshSignal,
  }) : _agendaRepository = agendaRepository,
       _registrationRepository = registrationRepository,
       _healthRepository = healthRepository,
       _weightRepository = weightRepository,
       _movementRepository = movementRepository,
       _reproductionRepository = reproductionRepository,
       _careRepository = careRepository,
       _lotesRepository = lotesRepository,
       _reminderSyncService = reminderSyncService,
       _refreshSignal = refreshSignal;

  final AgendaRepository _agendaRepository;
  final AgendaRegistrationRepository _registrationRepository;
  final HealthRecordRepository _healthRepository;
  final WeightRecordRepository _weightRepository;
  final MovementRecordRepository _movementRepository;
  final ReproductionRecordRepository _reproductionRepository;
  final CareRepository _careRepository;
  final LotesRepository _lotesRepository;
  final AgendaReminderSyncService? _reminderSyncService;
  final AgendaRefreshSignal? _refreshSignal;

  Future<AgendaRegistrationBatchResult> register(
    AgendaRegistrationRequest request,
  ) async {
    final batchId = request.batchId ?? const Uuid().v4();
    final results = <AgendaRegistrationRowResult>[];
    var shouldSyncReminders = false;

    for (final draft in request.rows) {
      try {
        final currentRegistration =
            draft.existingRegistration ??
            await _registrationRepository.getForRow(
              draft.row.entry.id,
              draft.row.animalId,
            );
        final registration = await _saveRow(
          request.eventKey,
          batchId,
          draft,
          currentRegistration,
        );
        shouldSyncReminders =
            shouldSyncReminders || draft.kind == AgendaRegistrationKind.health;
        results.add(
          AgendaRegistrationRowResult(draft: draft, registration: registration),
        );
      } catch (error) {
        results.add(
          AgendaRegistrationRowResult(
            draft: draft,
            error: error.toString().replaceFirst('Exception: ', ''),
          ),
        );
      }
    }

    if (shouldSyncReminders && results.any((result) => result.succeeded)) {
      try {
        await _reminderSyncService?.sync();
      } catch (_) {
        // The actual records and Agenda progress already succeeded. A later
        // Agenda refresh retries reminder reconciliation.
      }
    }
    if (results.any((result) => result.succeeded)) {
      _refreshSignal?.notifyChanged();
    }
    return AgendaRegistrationBatchResult(List.unmodifiable(results));
  }

  Future<AgendaRegistration> _saveRow(
    String eventKey,
    String batchId,
    AgendaRegistrationRowDraft draft,
    AgendaRegistration? existing,
  ) async {
    final row = draft.row;
    final now = DateTime.now();
    final registrationId =
        existing?.id ??
        'agenda-registration:${row.entry.id}:${row.animalId ?? 'general'}';
    final stableRecordUuid =
        existing?.recordUuid ??
        'agenda-record:${draft.kind.name}:$registrationId';
    String? savedRecordUuid;

    switch (draft.kind) {
      case AgendaRegistrationKind.health:
        final animalId = _requireAnimal(row.animalId);
        final record = draft.healthRecord;
        if (record == null) throw StateError('Faltan los datos sanitarios.');
        final saved = await _healthRepository.addHealthRecord(
          animalId,
          record.copyWith(recordUuid: stableRecordUuid, updatedAt: now),
        );
        savedRecordUuid = saved.recordUuid ?? stableRecordUuid;
        await _saveCareExecutionIfNeeded(row.entry, animalId, draft);
        break;
      case AgendaRegistrationKind.weight:
        final animalId = _requireAnimal(row.animalId);
        final record = draft.weightRecord;
        if (record == null) throw StateError('Faltan los datos de peso.');
        final saved = await _weightRepository.addWeightRecord(
          animalId,
          record.copyWith(recordUuid: stableRecordUuid, updatedAt: now),
        );
        savedRecordUuid = saved.recordUuid ?? stableRecordUuid;
        break;
      case AgendaRegistrationKind.movement:
        final animalId = _requireAnimal(row.animalId);
        final record = draft.movementRecord;
        if (record == null)
          throw StateError('Faltan los datos del movimiento.');
        final saved = await _movementRepository.addMovementRecord(
          animalId,
          record.copyWith(recordUuid: stableRecordUuid, updatedAt: now),
        );
        savedRecordUuid = saved.recordUuid ?? stableRecordUuid;
        break;
      case AgendaRegistrationKind.reproduction:
        final animalId = _requireAnimal(row.animalId);
        final record = draft.reproductionRecord;
        if (record == null) {
          throw StateError('Faltan los datos reproductivos.');
        }
        final saved = await _reproductionRepository.addReproductionRecord(
          animalId,
          record.copyWith(recordUuid: stableRecordUuid, updatedAt: now),
        );
        savedRecordUuid = saved.recordUuid ?? stableRecordUuid;
        break;
      case AgendaRegistrationKind.general:
        savedRecordUuid = null;
        break;
    }

    final registration = AgendaRegistration(
      id: registrationId,
      batchId: existing?.batchId ?? batchId,
      entryId: row.entry.id,
      eventKey: eventKey,
      animalId: row.animalId,
      kind: draft.kind,
      recordUuid: savedRecordUuid,
      performedAt: draft.performedAt,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      data: draft.generalData,
      evidencePaths: draft.evidencePaths,
    );

    // Both writes are idempotent: registration and child record use stable
    // keys. If the second phase fails, retrying cannot create a duplicate.
    await _registrationRepository.save(registration);
    await _markAgendaRowRegistered(
      row.entry.id,
      row.animalId,
      registration,
      edited: existing != null,
    );
    return registration;
  }

  String _requireAnimal(String? animalId) {
    if (animalId == null || animalId.isEmpty) {
      throw StateError('La tarea no tiene un animal válido.');
    }
    return animalId;
  }

  Future<void> _saveCareExecutionIfNeeded(
    AgendaEntry entry,
    String animalId,
    AgendaRegistrationRowDraft draft,
  ) async {
    if (!entry.id.startsWith('auto:care:')) return;
    final parts = entry.id.split(':');
    if (parts.length < 5) return;
    final ruleId = parts[3];
    final rules = await _careRepository.getRules();
    final rule = rules.where((candidate) => candidate.id == ruleId).firstOrNull;
    if (rule == null) return;
    await _careRepository.saveRecord(
      CareRecord(
        id: 'agenda-care:${entry.id}',
        animalId: animalId,
        ruleId: rule.id,
        type: rule.type,
        performedAt: draft.performedAt,
        notes:
            draft.healthRecord?.notes ??
            'Registrado desde Agenda: ${entry.titulo}',
        performedBy: draft.healthRecord?.appliedBy,
      ),
    );
  }

  Future<void> _markAgendaRowRegistered(
    String entryId,
    String? animalId,
    AgendaRegistration registration, {
    required bool edited,
  }) async {
    final before = await _agendaRepository.getEntry(entryId);
    final now = DateTime.now();
    final activityId = edited
        ? 'registration:${registration.id}:edited:${now.microsecondsSinceEpoch}'
        : 'registration:${registration.id}:created';
    final activities = [
      ...before.activities.where((activity) => activity.id != activityId),
      AgendaActivity(
        id: activityId,
        type: edited ? 'registration_edited' : 'registration_created',
        timestamp: now,
        note: registration.id,
      ),
    ];

    AgendaEntry after;
    if (edited) {
      after = before.copyWith(updatedAt: now, activities: activities);
    } else if (animalId == null) {
      after = before.copyWith(
        estado: AgendaEstado.completado,
        fechaCompletado: now,
        updatedAt: now,
        activities: activities,
      );
    } else {
      final completed = {...before.completedAnimalIds, animalId}.toList();
      final targetIds = <String>{...before.animalIds};
      for (final loteId in before.loteIds) {
        final lote = await _lotesRepository.getByUuid(loteId);
        if (lote != null) targetIds.addAll(lote.animalUuids);
      }
      final allDone =
          targetIds.isNotEmpty && targetIds.every(completed.contains);
      after = before.copyWith(
        completedAnimalIds: completed,
        estado: allDone ? AgendaEstado.completado : AgendaEstado.enProgreso,
        fechaCompletado: allDone ? now : before.fechaCompletado,
        updatedAt: now,
        activities: activities,
      );
    }

    await _agendaRepository.updateEntry(after);
    if (!edited &&
        before.estado != AgendaEstado.completado &&
        after.estado == AgendaEstado.completado) {
      final next = buildNextOccurrence(after);
      if (next != null) await _agendaRepository.saveEntry(next);
    }
  }
}
