/// core › sync › sync_service — Fase 1 del respaldo en la nube: solo subida.
///
/// Empuja a Supabase todo lo que quede marcado como `synced == false` en
/// cada repositorio local. No hay descarga ni fusión todavía (eso es Fase 2):
/// esto es un respaldo literal, no una sincronización bidireccional.
///
/// El almacenamiento local en Isar sigue siendo la fuente de verdad — nada
/// de esto se ejecuta salvo que el usuario lo dispare a mano (botón
/// "Respaldar ahora") y haya una sesión de Supabase activa.
library;

import 'package:libretapp/core/sync/supabase_config.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/production_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_dto.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/agenda/data/workforce_model.dart';
import 'package:libretapp/features/agenda/data/workforce_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lote_dto.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/finanzas/domain/entities/general_expense_record.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';
import 'package:libretapp/features/finanzas/domain/repositories/finanzas_repository.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncResult {
  const SyncResult({required this.pushed, required this.errors})
    : _unavailableReason = null;

  const SyncResult.unavailable(String reason)
    : pushed = 0,
      errors = const [],
      _unavailableReason = reason;

  final int pushed;
  final List<String> errors;
  final String? _unavailableReason;

  bool get isUnavailable => _unavailableReason != null;
  String? get unavailableReason => _unavailableReason;
  bool get hasErrors => errors.isNotEmpty;
}

class SyncService {
  SyncService({
    required AnimalRepository animalRepository,
    required LotesRepository lotesRepository,
    required HealthRecordRepository healthRecordRepository,
    required WeightRecordRepository weightRecordRepository,
    required MovementRecordRepository movementRecordRepository,
    required CostRecordRepository costRecordRepository,
    required CommercialRecordRepository commercialRecordRepository,
    required ProductionRecordRepository productionRecordRepository,
    required ReproductionRecordRepository reproductionRecordRepository,
    required FinanzasRepository finanzasRepository,
    required MilkingRepository milkingRepository,
    required LocationRepository locationRepository,
    required AgendaRepository agendaRepository,
    required WorkforceRepository workforceRepository,
  }) : _animalRepository = animalRepository,
       _lotesRepository = lotesRepository,
       _healthRecordRepository = healthRecordRepository,
       _weightRecordRepository = weightRecordRepository,
       _movementRecordRepository = movementRecordRepository,
       _costRecordRepository = costRecordRepository,
       _commercialRecordRepository = commercialRecordRepository,
       _productionRecordRepository = productionRecordRepository,
       _reproductionRecordRepository = reproductionRecordRepository,
       _finanzasRepository = finanzasRepository,
       _milkingRepository = milkingRepository,
       _locationRepository = locationRepository,
       _agendaRepository = agendaRepository,
       _workforceRepository = workforceRepository;

  final AnimalRepository _animalRepository;
  final LotesRepository _lotesRepository;
  final HealthRecordRepository _healthRecordRepository;
  final WeightRecordRepository _weightRecordRepository;
  final MovementRecordRepository _movementRecordRepository;
  final CostRecordRepository _costRecordRepository;
  final CommercialRecordRepository _commercialRecordRepository;
  final ProductionRecordRepository _productionRecordRepository;
  final ReproductionRecordRepository _reproductionRecordRepository;
  final FinanzasRepository _finanzasRepository;
  final MilkingRepository _milkingRepository;
  final LocationRepository _locationRepository;
  final AgendaRepository _agendaRepository;
  final WorkforceRepository _workforceRepository;

  SupabaseClient? get _clientOrNull =>
      SupabaseConfig.isConfigured ? Supabase.instance.client : null;

  Future<SyncResult> syncNow() async {
    final client = _clientOrNull;
    if (client == null) {
      return const SyncResult.unavailable(
        'Respaldo en la nube no configurado.',
      );
    }
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      return const SyncResult.unavailable(
        'Inicia sesión para respaldar en la nube.',
      );
    }

    var pushed = 0;
    final errors = <String>[];

    Future<void> run(String label, Future<int> Function() task) async {
      try {
        pushed += await task();
      } catch (e) {
        errors.add('$label: $e');
      }
    }

    // ── Root entities (already have their own stable uuid) ────────────────
    await run(
      'animales',
      () async => _pushByUuid(
        client,
        userId,
        table: 'animals',
        items: await _animalRepository.getUnsynchronized(),
        uuidOf: (a) => a.uuid,
        toRow: (a) => AnimalDto.fromEntity(a).toJson()..remove('id'),
        markSynced: _animalRepository.markAsSynced,
      ),
    );
    await run(
      'lotes',
      () async => _pushByUuid(
        client,
        userId,
        table: 'lotes',
        items: await _lotesRepository.getUnsynchronized(),
        uuidOf: (l) => l.uuid,
        toRow: (l) => LoteDto.fromEntity(l).toJson()..remove('id'),
        markSynced: _lotesRepository.markAsSynced,
      ),
    );
    await run(
      'ubicaciones',
      () async => _pushByUuid(
        client,
        userId,
        table: 'locations',
        items: await _locationRepository.getUnsynchronized(),
        uuidOf: (l) => l.uuid,
        toRow: _locationToRow,
        markSynced: _locationRepository.markAsSynced,
      ),
    );
    await run(
      'agenda',
      () async => _pushByUuid(
        client,
        userId,
        table: 'agenda_entries',
        items: await _agendaRepository.getUnsynchronized(),
        uuidOf: (a) => a.id,
        toRow: _agendaEntryToRow,
        markSynced: _agendaRepository.markAsSynced,
      ),
    );
    await run(
      'personal',
      () async => _pushByUuid(
        client,
        userId,
        table: 'worker_profiles',
        items: await _workforceRepository.getUnsynchronizedWorkers(),
        uuidOf: (w) => w.id,
        toRow: _workerToRow,
        markSynced: _workforceRepository.markWorkerSynced,
      ),
    );
    await run(
      'equipos_trabajo',
      () async => _pushByUuid(
        client,
        userId,
        table: 'work_teams',
        items: await _workforceRepository.getUnsynchronizedTeams(),
        uuidOf: (t) => t.id,
        toRow: _workTeamToRow,
        markSynced: _workforceRepository.markTeamSynced,
      ),
    );
    await run(
      'ordena_sesiones',
      () async => _pushByUuid(
        client,
        userId,
        table: 'milking_sessions',
        items: await _milkingRepository.getUnsynchronizedSessions(),
        uuidOf: (s) => s.uuid,
        toRow: _milkingSessionToRow,
        markSynced: _milkingRepository.markSessionSynced,
      ),
    );
    await run(
      'ordena_registros',
      () async => _pushByUuid(
        client,
        userId,
        table: 'milking_entries',
        items: await _milkingRepository.getUnsynchronizedEntries(),
        uuidOf: (e) => e.uuid,
        toRow: _milkingEntryToRow,
        markSynced: _milkingRepository.markEntrySynced,
      ),
    );

    // ── Records with no uuid of their own: the server assigns one ─────────
    await run(
      'ingresos',
      () async => _pushGenerated(
        client,
        userId,
        table: 'income_records',
        items: await _finanzasRepository.getUnsynchronizedIncomes(),
        localIdOf: (r) => r.id!,
        toRow: _incomeToRow,
        markSynced: _finanzasRepository.markIncomeSynced,
      ),
    );
    await run(
      'gastos',
      () async => _pushGenerated(
        client,
        userId,
        table: 'general_expense_records',
        items: await _finanzasRepository.getUnsynchronizedExpenses(),
        localIdOf: (r) => r.id!,
        toRow: _expenseToRow,
        markSynced: _finanzasRepository.markExpenseSynced,
      ),
    );

    // ── Animal child records: no uuid, and the animal uuid travels
    // alongside the entity instead of living on it ────────────────────────
    await run(
      'salud',
      () async => _pushChildRecords(
        client,
        userId,
        table: 'health_records',
        items: await _healthRecordRepository.getUnsynchronized(),
        localIdOf: (r) => r.id!,
        toRow: _healthRecordToRow,
        markSynced: _healthRecordRepository.markAsSynced,
      ),
    );
    await run(
      'peso',
      () async => _pushChildRecords(
        client,
        userId,
        table: 'weight_records',
        items: await _weightRecordRepository.getUnsynchronized(),
        localIdOf: (r) => r.id!,
        toRow: _weightRecordToRow,
        markSynced: _weightRecordRepository.markAsSynced,
      ),
    );
    await run(
      'movimientos',
      () async => _pushChildRecords(
        client,
        userId,
        table: 'movement_records',
        items: await _movementRecordRepository.getUnsynchronized(),
        localIdOf: (r) => r.id!,
        toRow: _movementRecordToRow,
        markSynced: _movementRecordRepository.markAsSynced,
      ),
    );
    await run(
      'costos',
      () async => _pushChildRecords(
        client,
        userId,
        table: 'cost_records',
        items: await _costRecordRepository.getUnsynchronized(),
        localIdOf: (r) => r.id!,
        toRow: _costRecordToRow,
        markSynced: _costRecordRepository.markAsSynced,
      ),
    );
    await run(
      'comercial',
      () async => _pushChildRecords(
        client,
        userId,
        table: 'commercial_records',
        items: await _commercialRecordRepository.getUnsynchronized(),
        localIdOf: (r) => r.id!,
        toRow: _commercialRecordToRow,
        markSynced: _commercialRecordRepository.markAsSynced,
      ),
    );
    await run(
      'produccion',
      () async => _pushChildRecords(
        client,
        userId,
        table: 'production_records',
        items: await _productionRecordRepository.getUnsynchronized(),
        localIdOf: (r) => r.id!,
        toRow: _productionRecordToRow,
        markSynced: _productionRecordRepository.markAsSynced,
      ),
    );
    await run(
      'reproduccion',
      () async => _pushChildRecords(
        client,
        userId,
        table: 'reproduction_records',
        items: await _reproductionRecordRepository.getUnsynchronized(),
        localIdOf: (r) => r.id!,
        toRow: _reproductionRecordToRow,
        markSynced: _reproductionRecordRepository.markAsSynced,
      ),
    );

    return SyncResult(pushed: pushed, errors: errors);
  }

  // ── Push strategies ──────────────────────────────────────────────────────

  /// For entities that already have a stable, client-generated uuid: upsert
  /// by that uuid, so re-pushing an edited record updates the same row.
  Future<int> _pushByUuid<T>(
    SupabaseClient client,
    String userId, {
    required String table,
    required List<T> items,
    required String Function(T) uuidOf,
    required Map<String, dynamic> Function(T) toRow,
    required Future<void> Function(String uuid, String remoteId) markSynced,
  }) async {
    var count = 0;
    for (final item in items) {
      final uuid = uuidOf(item);
      final row = toRow(item)
        ..['uuid'] = uuid
        ..['user_id'] = userId;
      await client.from(table).upsert(row);
      await markSynced(uuid, uuid);
      count++;
    }
    return count;
  }

  /// For entities with no uuid of their own (only a local Isar id): insert
  /// without an id and let Postgres assign one via `gen_random_uuid()`,
  /// reading it back to store as the local `remoteId`.
  Future<int> _pushGenerated<T>(
    SupabaseClient client,
    String userId, {
    required String table,
    required List<T> items,
    required String Function(T) localIdOf,
    required Map<String, dynamic> Function(T) toRow,
    required Future<void> Function(String localId, String remoteId)
    markSynced,
  }) async {
    var count = 0;
    for (final item in items) {
      final row = toRow(item)..['user_id'] = userId;
      final inserted = await client
          .from(table)
          .insert(row)
          .select('uuid')
          .single();
      await markSynced(localIdOf(item), inserted['uuid'] as String);
      count++;
    }
    return count;
  }

  Future<int> _pushChildRecords<T>(
    SupabaseClient client,
    String userId, {
    required String table,
    required List<(String animalUuid, T record)> items,
    required String Function(T) localIdOf,
    required Map<String, dynamic> Function(T) toRow,
    required Future<void> Function(String localId, String remoteId)
    markSynced,
  }) async {
    var count = 0;
    for (final (animalUuid, record) in items) {
      final row = toRow(record)
        ..['animal_uuid'] = animalUuid
        ..['user_id'] = userId;
      final inserted = await client
          .from(table)
          .insert(row)
          .select('uuid')
          .single();
      await markSynced(localIdOf(record), inserted['uuid'] as String);
      count++;
    }
    return count;
  }

  // ── Row builders for the collections without a ready-made DTO ──────────
  //
  // Fase 1 es solo-subida: estos mapas alimentan un INSERT/UPSERT y no
  // necesitan un fromJson de vuelta todavía (eso llega en la Fase 2, junto
  // con la descarga).

  Map<String, dynamic> _locationToRow(LocationEntity l) => {
    'name': l.name,
    'kind': l.kind.name,
    'parent_uuid': l.parentUuid,
    'template_uuid': l.templateUuid,
    'type': l.type.name,
    'surface_area': l.surfaceArea,
    'capacity': l.capacity,
    'water_source': l.waterSource,
    'terrain_type': l.terrainType,
    'status': l.status.name,
    'category': l.category?.name,
    'geometry': l.geometry,
    'is_shared': l.isShared,
    'is_communal': l.isCommunal,
    'image_paths': l.imagePaths,
    // Fase 1: solo se respaldan los campos de identidad/configuración de la
    // ubicación. El historial operativo embebido (visitas, agua, cultivos,
    // etc.) queda pendiente para la Fase 2.
  };

  Map<String, dynamic> _agendaEntryToRow(AgendaEntry a) => {
    'titulo': a.titulo,
    'descripcion': a.descripcion,
    'fecha': a.fecha.toIso8601String(),
    'tipo': a.tipo,
    'animal_ids': a.animalIds,
    'lote_ids': a.loteIds,
    'ubicacion': a.ubicacion,
    'location_uuid': a.locationUuid,
    'estado': a.estado,
    'prioridad': a.prioridad,
    'completed_animal_ids': a.completedAnimalIds,
    'notas': a.notas,
    'fecha_completado': a.fechaCompletado?.toIso8601String(),
    'assignee_id': a.assigneeId,
    'collaborator_ids': a.collaboratorIds,
    'work_team_id': a.workTeamId,
    'created_by_id': a.createdById,
    'created_at': a.createdAt?.toIso8601String(),
    'updated_at': a.updatedAt?.toIso8601String(),
    'recurrence_rule': a.recurrenceRule,
    'blocked_reason': a.blockedReason,
  };

  Map<String, dynamic> _workerToRow(WorkerProfile w) => {
    'name': w.name,
    'role': w.role,
    'phone': w.phone,
    'active': w.active,
    'created_at': w.createdAt.toIso8601String(),
    'updated_at': w.updatedAt.toIso8601String(),
  };

  Map<String, dynamic> _workTeamToRow(WorkTeam t) => {
    'name': t.name,
    'member_ids': t.memberIds,
    'active': t.active,
    'created_at': t.createdAt.toIso8601String(),
    'updated_at': t.updatedAt.toIso8601String(),
  };

  Map<String, dynamic> _milkingSessionToRow(MilkingSession s) => {
    'occurred_at': s.occurredAt.toIso8601String(),
    'shift': s.shift.name,
    'status': s.status.name,
    'source_lote_uuid': s.sourceLoteUuid,
    'notes': s.notes,
    'created_at': s.createdAt.toIso8601String(),
    'updated_at': s.updatedAt.toIso8601String(),
  };

  Map<String, dynamic> _milkingEntryToRow(MilkingEntry e) => {
    'session_uuid': e.sessionUuid,
    'animal_uuid': e.animalUuid,
    'volume_milliliters': e.volumeMilliliters,
    'notes': e.notes,
    'created_at': e.createdAt.toIso8601String(),
    'updated_at': e.updatedAt.toIso8601String(),
  };

  Map<String, dynamic> _incomeToRow(IncomeRecord r) => {
    'date': r.date.toIso8601String(),
    'type': r.type.name,
    'amount': r.amount,
    'currency': r.currency,
    'animal_uuid': r.animalUuid,
    'notes': r.notes,
  };

  Map<String, dynamic> _expenseToRow(GeneralExpenseRecord r) => {
    'date': r.date.toIso8601String(),
    'type': r.type.name,
    'amount': r.amount,
    'currency': r.currency,
    'notes': r.notes,
  };

  Map<String, dynamic> _healthRecordToRow(HealthRecord r) => {
    'date': r.date.toIso8601String(),
    'type': r.type.name,
    'product': r.product,
    'dose': r.dose,
    'applied_by': r.appliedBy,
    'notes': r.notes,
    'next_due_date': r.nextDueDate?.toIso8601String(),
    'cause': r.cause,
    'medicine_batch': r.medicineBatch,
    'withdrawal_days': r.withdrawalDays,
    'withdrawal_end_date': r.withdrawalEndDate?.toIso8601String(),
  };

  Map<String, dynamic> _weightRecordToRow(WeightRecord r) => {
    'date': r.date.toIso8601String(),
    'weight': r.weight,
    'method': r.method.name,
    'measured_by': r.measuredBy,
    'notes': r.notes,
  };

  Map<String, dynamic> _movementRecordToRow(MovementRecord r) => {
    'from_location': r.fromLocation,
    'to_location': r.toLocation,
    'date': r.date.toIso8601String(),
    'reason': r.reason.name,
    'notes': r.notes,
    'moved_by': r.movedBy,
  };

  Map<String, dynamic> _costRecordToRow(CostRecord r) => {
    'date': r.date.toIso8601String(),
    'type': r.type.name,
    'amount': r.amount,
    'currency': r.currency,
    'notes': r.notes,
  };

  Map<String, dynamic> _commercialRecordToRow(CommercialRecord r) => {
    'date': r.date.toIso8601String(),
    'type': r.type.name,
    'amount': r.amount,
    'currency': r.currency,
    'counterparty': r.counterparty,
    'notes': r.notes,
  };

  Map<String, dynamic> _productionRecordToRow(ProductionRecord r) => {
    'date': r.date.toIso8601String(),
    'type': r.type.name,
    'value': r.value,
    'unit': r.unit,
    'score': r.score,
    'notes': r.notes,
  };

  Map<String, dynamic> _reproductionRecordToRow(ReproductionRecord r) => {
    'service_date': r.serviceDate.toIso8601String(),
    'service_type': r.serviceType.name,
    'male_sire_uuid': r.maleSireUuid,
    'male_sire_identifier': r.maleSireIdentifier,
    'pregnancy_check_date': r.pregnancyCheckDate?.toIso8601String(),
    'pregnancy_result': r.pregnancyResult?.name,
    'expected_calving_date': r.expectedCalvingDate?.toIso8601String(),
    'actual_calving_date': r.actualCalvingDate?.toIso8601String(),
    'calving_result': r.calvingResult,
    'notes': r.notes,
    'serviced_by': r.servicedBy,
  };
}
