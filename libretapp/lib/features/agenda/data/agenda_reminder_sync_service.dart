/// features › agenda › data › agenda_reminder_sync_service — syncs agenda with auto-generated reminders.
library;

import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_rule.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/care_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/services/care_calendar_service.dart';
import 'package:libretapp/features/directorio/animales/domain/services/reproduction_scheduler.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';

class AgendaReminderSyncService {
  AgendaReminderSyncService({
    required AnimalRepository animalRepository,
    required AgendaRepository agendaRepository,
    required HealthRecordRepository healthRepo,
    required ReproductionRecordRepository reproductionRepo,
    required CareRepository careRepo,
    required CareCalendarService careCalendarService,
    ReproductionScheduler? reproductionScheduler,
  }) : _animalRepository = animalRepository,
       _agendaRepository = agendaRepository,
       _healthRepo = healthRepo,
       _reproductionRepo = reproductionRepo,
       _careRepo = careRepo,
       _careCalendarService = careCalendarService,
       _reproductionScheduler =
           reproductionScheduler ?? const ReproductionScheduler();

  final AnimalRepository _animalRepository;
  final AgendaRepository _agendaRepository;
  final HealthRecordRepository _healthRepo;
  final ReproductionRecordRepository _reproductionRepo;
  final CareRepository _careRepo;
  final CareCalendarService _careCalendarService;
  final ReproductionScheduler _reproductionScheduler;

  Future<int> sync({DateTime? now}) async {
    final existing = await _agendaRepository.fetchEntries();
    final manual = existing
        .where((e) => !_isAutoEntry(e.id))
        .toList(growable: true);

    final existingAuto = <String, AgendaEntry>{
      for (final entry in existing.where((e) => _isAutoEntry(e.id)))
        entry.id: entry,
    };

    final desiredAuto = await _buildAutoEntries(now: now);

    final mergedAuto = desiredAuto
        .map((desired) {
          final previous = existingAuto[desired.id];
          if (previous == null) return desired;

          // Refresh source-derived fields without erasing execution history.
          return desired.copyWith(
            estado: previous.estado,
            completedAnimalIds: previous.completedAnimalIds,
            notas: previous.notas,
            fechaCompletado: previous.fechaCompletado,
            prioridad: previous.prioridad,
            assigneeId: previous.assigneeId,
            collaboratorIds: previous.collaboratorIds,
            workTeamId: previous.workTeamId,
            createdById: previous.createdById,
            createdAt: previous.createdAt,
            updatedAt: previous.updatedAt,
            blockedReason: previous.blockedReason,
            checklist: previous.checklist,
            activities: previous.activities,
            evidence: previous.evidence,
          );
        })
        .toList(growable: false);

    final desiredIds = desiredAuto.map((entry) => entry.id).toSet();
    final activeAnimalIds = (await _animalRepository.getAll())
        .map((animal) => animal.uuid)
        .toSet();
    final historicalAuto = existingAuto.values.where(
      (entry) =>
          !desiredIds.contains(entry.id) &&
          (entry.estado == AgendaEstado.completado ||
              entry.estado == AgendaEstado.verificado ||
              entry.estado == AgendaEstado.cancelado) &&
          entry.animalIds.any(activeAnimalIds.contains),
    );

    final merged = <AgendaEntry>[...manual, ...historicalAuto, ...mergedAuto];

    await _agendaRepository.replaceAll(merged);
    return desiredAuto.length;
  }

  bool _isAutoEntry(String id) => id.startsWith('auto:');

  Future<List<AgendaEntry>> _buildAutoEntries({DateTime? now}) async {
    final animals = await _animalRepository.getAll();
    final desired = <String, AgendaEntry>{};
    final careRules = {
      for (final rule in await _careRepo.getRules()) rule.id: rule,
    };

    for (final animal in animals) {
      final pendingCare = await _careCalendarService.regenerateFor(
        animal,
        now: now,
      );
      for (final task in pendingCare) {
        if (task.done) continue;
        final label = careRules[task.ruleId]?.name ?? _careTypeLabel(task.type);
        final date = _startOfDay(task.dueAt);
        final id = 'auto:care:${animal.uuid}:${task.ruleId}:${_dateKey(date)}';
        desired[id] = AgendaEntry(
          id: id,
          titulo: '$label - ${_animalLabel(animal)}',
          descripcion: 'Tarea de cuidado programada automáticamente.',
          fecha: date,
          tipo: _careTypeLabel(task.type),
          animalIds: [animal.uuid],
          loteIds: const [],
          ubicacion: animal.currentLocationId ?? 'Sin ubicación',
          estado: AgendaEstado.pendiente,
          completedAnimalIds: const [],
          notas: '',
        );
      }

      final healthRecords = await _healthRepo.getHealthRecords(animal.uuid);
      for (final record in healthRecords) {
        final date = record.nextDueDate;
        if (date == null) continue;
        if (!_isReminderHealthType(record.type)) continue;

        final typeLabel = _healthTypeLabel(record.type);
        final sourceId =
            record.id ?? record.date.millisecondsSinceEpoch.toString();
        final entryId =
            'auto:health:${animal.uuid}:${record.type.name}:$sourceId:${_dateKey(date)}';
        desired[entryId] = AgendaEntry(
          id: entryId,
          titulo: '$typeLabel - ${_animalLabel(animal)}',
          descripcion: 'Recordatorio automático basado en registro sanitario.',
          fecha: _startOfDay(date),
          tipo: typeLabel,
          animalIds: [animal.uuid],
          loteIds: const [],
          ubicacion: animal.currentLocationId ?? 'Sin ubicación',
          estado: AgendaEstado.pendiente,
          completedAnimalIds: const [],
          notas: '',
        );
      }

      final reproRecords = await _reproductionRepo.getReproductionRecords(
        animal.uuid,
      );
      for (final record in reproRecords) {
        final sourceId =
            record.id ?? record.serviceDate.millisecondsSinceEpoch.toString();
        final schedule = _reproductionScheduler.estimate(
          serviceDate: record.serviceDate,
        );

        final pregCheckDate =
            record.pregnancyCheckDate ?? schedule.pregnancyCheckDate;
        if (pregCheckDate != null &&
            record.pregnancyResult != PregnancyCheckResult.positive) {
          final date = _startOfDay(pregCheckDate);
          final id =
              'auto:repro:${animal.uuid}:pregcheck:$sourceId:${_dateKey(date)}';
          desired[id] = AgendaEntry(
            id: id,
            titulo: 'Chequeo de preñez - ${_animalLabel(animal)}',
            descripcion:
                'Control automático de gestación (35 días post servicio).',
            fecha: date,
            tipo: 'Revisión veterinaria',
            animalIds: [animal.uuid],
            loteIds: const [],
            ubicacion: animal.currentLocationId ?? 'Sin ubicación',
            estado: AgendaEstado.pendiente,
            completedAnimalIds: const [],
            notas: '',
          );
        }

        final dueDate = _startOfDay(
          record.expectedCalvingDate ?? schedule.dueDate,
        );
        if (record.actualCalvingDate == null) {
          final partoId =
              'auto:repro:${animal.uuid}:parto:$sourceId:${_dateKey(dueDate)}';
          desired[partoId] = AgendaEntry(
            id: partoId,
            titulo: 'Parto estimado - ${_animalLabel(animal)}',
            descripcion: 'Fecha estimada de parto según último servicio.',
            fecha: dueDate,
            tipo: 'Parto',
            animalIds: [animal.uuid],
            loteIds: const [],
            ubicacion: animal.currentLocationId ?? 'Sin ubicación',
            estado: AgendaEstado.pendiente,
            completedAnimalIds: const [],
            notas: '',
          );

          final pre21 = dueDate.subtract(const Duration(days: 21));
          final pre7 = dueDate.subtract(const Duration(days: 7));

          final pre21Id =
              'auto:repro:${animal.uuid}:parto-pre21:$sourceId:${_dateKey(pre21)}';
          desired[pre21Id] = AgendaEntry(
            id: pre21Id,
            titulo: 'Parto próximo (21 días) - ${_animalLabel(animal)}',
            descripcion: 'Preparar manejo preparto y monitoreo.',
            fecha: pre21,
            tipo: 'Parto',
            animalIds: [animal.uuid],
            loteIds: const [],
            ubicacion: animal.currentLocationId ?? 'Sin ubicación',
            estado: AgendaEstado.pendiente,
            completedAnimalIds: const [],
            notas: '',
          );

          final pre7Id =
              'auto:repro:${animal.uuid}:parto-pre7:$sourceId:${_dateKey(pre7)}';
          desired[pre7Id] = AgendaEntry(
            id: pre7Id,
            titulo: 'Parto próximo (7 días) - ${_animalLabel(animal)}',
            descripcion: 'Revisión final preparto.',
            fecha: pre7,
            tipo: 'Parto',
            animalIds: [animal.uuid],
            loteIds: const [],
            ubicacion: animal.currentLocationId ?? 'Sin ubicación',
            estado: AgendaEstado.pendiente,
            completedAnimalIds: const [],
            notas: '',
          );
        }
      }
    }

    return desired.values.toList(growable: false)
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
  }

  bool _isReminderHealthType(HealthRecordType type) {
    return type == HealthRecordType.vaccine ||
        type == HealthRecordType.deworming;
  }

  String _healthTypeLabel(HealthRecordType type) {
    switch (type) {
      case HealthRecordType.vaccine:
        return 'Vacunación';
      case HealthRecordType.deworming:
        return 'Desparasitación';
      default:
        return 'Salud';
    }
  }

  String _careTypeLabel(CareType type) => switch (type) {
    CareType.vaccination => 'Vacunación',
    CareType.deworming => 'Desparasitación',
    CareType.tickBath => 'Baño garrapaticida',
    CareType.supplement => 'Suplemento/Vitaminas',
    CareType.hoofCare => 'Revisión de casco',
    CareType.reproductionCheck => 'Chequeo reproductivo',
    CareType.custom => 'Cuidado',
  };

  String _animalLabel(AnimalEntity animal) {
    if (animal.customName != null && animal.customName!.trim().isNotEmpty) {
      return animal.customName!.trim();
    }
    if (animal.visualId != null && animal.visualId!.trim().isNotEmpty) {
      return animal.visualId!.trim();
    }
    return animal.earTagNumber;
  }

  String _dateKey(DateTime date) {
    final d = _startOfDay(date);
    return '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
  }

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
