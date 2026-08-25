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
import 'package:libretapp/features/agenda/data/agenda_refresh_signal.dart';
import 'package:libretapp/features/agenda/domain/operational_work.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_task_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class AgendaReminderSyncService {
  AgendaReminderSyncService({
    required AnimalRepository animalRepository,
    required AgendaRepository agendaRepository,
    required HealthRecordRepository healthRepo,
    required ReproductionRecordRepository reproductionRepo,
    required CareRepository careRepo,
    required CareCalendarService careCalendarService,
    ReproductionScheduler? reproductionScheduler,
    LocationRepository? locationRepository,
    AgendaRefreshSignal? refreshSignal,
  }) : _animalRepository = animalRepository,
       _agendaRepository = agendaRepository,
       _healthRepo = healthRepo,
       _reproductionRepo = reproductionRepo,
       _careRepo = careRepo,
       _careCalendarService = careCalendarService,
       _locationRepository = locationRepository,
       _reproductionScheduler =
           reproductionScheduler ?? const ReproductionScheduler(),
       _refreshSignal = refreshSignal;

  final AnimalRepository _animalRepository;
  final AgendaRepository _agendaRepository;
  final HealthRecordRepository _healthRepo;
  final ReproductionRecordRepository _reproductionRepo;
  final CareRepository _careRepo;
  final CareCalendarService _careCalendarService;
  final LocationRepository? _locationRepository;
  final ReproductionScheduler _reproductionScheduler;
  final AgendaRefreshSignal? _refreshSignal;
  Future<int>? _syncInFlight;

  Future<int> sync({DateTime? now}) {
    final inFlight = _syncInFlight;
    if (inFlight != null) return inFlight;

    final operation = _syncInternal(now: now);
    _syncInFlight = operation;
    return operation.whenComplete(() {
      if (identical(_syncInFlight, operation)) _syncInFlight = null;
    });
  }

  Future<int> _syncInternal({DateTime? now}) async {
    final existing = await _agendaRepository.fetchEntries();
    final manual = existing
        .where((e) => !_isAutoEntry(e))
        .toList(growable: true);

    final existingAuto = <String, AgendaEntry>{
      for (final entry in existing.where(_isAutoEntry)) entry.id: entry,
    };

    final desiredAuto = await _buildAutoEntries(now: now);

    final desiredIds = desiredAuto.map((entry) => entry.id).toSet();
    final successorByPrevious = <String, AgendaEntry>{
      for (final entry in existingAuto.values)
        if (entry.supersedesId != null && !_isTerminal(entry.estado))
          entry.supersedesId!: entry,
    };
    final mergedAuto = desiredAuto
        .map((desired) {
          // A manually reprogrammed automatic occurrence wins over the
          // deterministic date that the source would otherwise recreate.
          if (successorByPrevious.containsKey(desired.id)) return null;
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
        .whereType<AgendaEntry>()
        .toList(growable: false);

    final preservedSuccessors = successorByPrevious.values.where(
      (entry) => !mergedAuto.any((candidate) => candidate.id == entry.id),
    );
    final historicalAuto = existingAuto.values.where(
      (entry) =>
          (entry.estado == AgendaEstado.reprogramada &&
              successorByPrevious.containsKey(entry.id)) ||
          (!desiredIds.contains(entry.id) &&
              _isTerminal(entry.estado) &&
              !successorByPrevious.containsKey(entry.id)),
    );

    final merged = <AgendaEntry>[
      ...manual,
      ...historicalAuto,
      ...preservedSuccessors,
      ...mergedAuto,
    ];

    await _agendaRepository.replaceAll(merged);
    _refreshSignal?.notifyChanged();
    return desiredAuto.length;
  }

  bool _isAutoEntry(AgendaEntry entry) =>
      entry.id.startsWith('auto:') ||
      (entry.sourceType != null &&
          entry.sourceType != WorkSourceType.manual.name);

  bool _isTerminal(String status) =>
      status == AgendaEstado.completado ||
      status == AgendaEstado.verificado ||
      status == AgendaEstado.cancelado ||
      status == AgendaEstado.reprogramada;

  Future<List<AgendaEntry>> _buildAutoEntries({DateTime? now}) async {
    final animals = await _animalRepository.getAll();
    final desired = <String, AgendaEntry>{};
    final careRules = {
      for (final rule in await _careRepo.getRules()) rule.id: rule,
    };

    for (final animal in animals) {
      final healthRecords = _latestHealthRecords(
        await _healthRepo.getHealthRecords(animal.uuid),
      );
      final explicitHealthCycles = healthRecords
          .where(
            (record) =>
                record.nextDueDate != null &&
                _isReminderHealthType(record.type),
          )
          .map((record) => record.type)
          .toSet();
      final pendingCare = await _careCalendarService.regenerateFor(
        animal,
        now: now,
      );
      for (final task in pendingCare) {
        if (task.done) continue;
        if (_careIsBackedByHealth(task.type, explicitHealthCycles)) continue;
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
          actionKind: WorkActionType.recordCare.name,
          sourceType: WorkSourceType.care.name,
          sourceId: '${animal.uuid}:${task.ruleId}',
        );
      }

      for (final record in healthRecords) {
        final date = record.nextDueDate;
        if (date == null) continue;
        if (!_isReminderHealthType(record.type)) continue;

        final typeLabel = _healthTypeLabel(record.type);
        // Health records use an auto-increment Isar id, so it is not stable
        // across a demo reset or a restore. The latest cycle for a health
        // type is uniquely identified by the animal, type and due date.
        final sourceId = '${animal.uuid}:${record.type.name}';
        final entryId =
            'auto:health:${animal.uuid}:${record.type.name}:${_dateKey(date)}';
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
          actionKind: WorkActionType.recordHealth.name,
          sourceType: WorkSourceType.health.name,
          sourceId: '$sourceId:${record.type.name}',
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
            actionKind: WorkActionType.reproductionCheck.name,
            sourceType: WorkSourceType.reproduction.name,
            sourceId: '$sourceId:pregcheck',
          );
        }

        final expectedCalvingDate = record.expectedCalvingDate;
        if (record.actualCalvingDate == null && expectedCalvingDate != null) {
          final dueDate = _startOfDay(expectedCalvingDate);
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
            actionKind: WorkActionType.calving.name,
            sourceType: WorkSourceType.reproduction.name,
            sourceId: '$sourceId:parto',
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
            actionKind: WorkActionType.calving.name,
            sourceType: WorkSourceType.reproduction.name,
            sourceId: '$sourceId:parto-pre21',
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
            actionKind: WorkActionType.calving.name,
            sourceType: WorkSourceType.reproduction.name,
            sourceId: '$sourceId:parto-pre7',
          );
        }
      }
    }

    if (_locationRepository != null) {
      await _buildCropEntries(desired);
    }

    return desired.values.toList(growable: false)
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
  }

  bool _isReminderHealthType(HealthRecordType type) {
    return type == HealthRecordType.vaccine ||
        type == HealthRecordType.deworming;
  }

  bool _careIsBackedByHealth(CareType type, Set<HealthRecordType> healthTypes) {
    final healthType = switch (type) {
      CareType.vaccination => HealthRecordType.vaccine,
      CareType.deworming => HealthRecordType.deworming,
      CareType.tickBath => HealthRecordType.tickBath,
      CareType.supplement => HealthRecordType.vitamins,
      _ => null,
    };
    return healthType != null && healthTypes.contains(healthType);
  }

  List<HealthRecord> _latestHealthRecords(List<HealthRecord> records) {
    final latest = <HealthRecordType, HealthRecord>{};
    for (final record in records) {
      final previous = latest[record.type];
      if (previous == null || record.date.isAfter(previous.date)) {
        latest[record.type] = record;
      }
    }
    return latest.values.toList(growable: false);
  }

  Future<void> _buildCropEntries(Map<String, AgendaEntry> desired) async {
    final locations = await _locationRepository!.getAll();
    for (final location in locations) {
      for (final crop in location.crops) {
        if (crop.status != CropStatus.active) continue;

        for (final task in crop.tasks.where((task) => !task.completed)) {
          final date = _startOfDay(task.dueDate);
          final id =
              'auto:crop-task:${location.uuid}:${crop.uuid}:${task.uuid}';
          desired[id] = _cropEntry(
            id: id,
            title: '${task.type.displayName} - ${crop.cropName}',
            date: date,
            location: location,
            crop: crop,
            action: task.type == CropTaskType.harvest
                ? WorkActionType.harvest
                : WorkActionType.cropTask,
            sourceType: WorkSourceType.cropTask,
            sourceId: task.uuid,
          );
        }

        final wateringDate = crop.nextWateringDate;
        if (wateringDate != null) {
          final date = _startOfDay(wateringDate);
          final id =
              'auto:crop-watering:${location.uuid}:${crop.uuid}:${_dateKey(date)}';
          desired[id] = _cropEntry(
            id: id,
            title: 'Riego - ${crop.cropName}',
            date: date,
            location: location,
            crop: crop,
            action: WorkActionType.cropWater,
            sourceType: WorkSourceType.cropCycle,
            sourceId: '${crop.uuid}:watering',
          );
        }

        final harvestDate = crop.expectedHarvestDate;
        if (harvestDate != null) {
          final date = _startOfDay(harvestDate);
          final id =
              'auto:crop-harvest:${location.uuid}:${crop.uuid}:${_dateKey(date)}';
          desired[id] = _cropEntry(
            id: id,
            title: 'Cosecha esperada - ${crop.cropName}',
            date: date,
            location: location,
            crop: crop,
            action: WorkActionType.harvest,
            sourceType: WorkSourceType.cropCycle,
            sourceId: '${crop.uuid}:harvest',
          );
        }
      }
    }
  }

  AgendaEntry _cropEntry({
    required String id,
    required String title,
    required DateTime date,
    required LocationEntity location,
    required CropRecord crop,
    required WorkActionType action,
    required WorkSourceType sourceType,
    required String sourceId,
  }) {
    return AgendaEntry(
      id: id,
      titulo: title,
      descripcion: 'Trabajo agrícola programado automáticamente.',
      fecha: date,
      tipo: action == WorkActionType.harvest ? 'Cosecha' : 'Cultivo',
      animalIds: const [],
      loteIds: const [],
      ubicacion: location.name,
      locationUuid: location.uuid,
      cropUuid: crop.uuid,
      estado: AgendaEstado.pendiente,
      completedAnimalIds: const [],
      notas: crop.notes ?? '',
      actionKind: action.name,
      sourceType: sourceType.name,
      sourceId: sourceId,
    );
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
