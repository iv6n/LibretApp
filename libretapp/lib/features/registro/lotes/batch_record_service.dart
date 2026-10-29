import 'package:libretapp/core/database/write_transaction.dart';
import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/core/persistence/json_feature_repository.dart';
import 'package:libretapp/core/tenancy/tenancy.dart';
import 'package:libretapp/core/utils/number_parsing.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/registro/lotes/batch_record_session.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:uuid/uuid.dart';

export 'batch_record_session.dart';

/// Drafts, records and completion receipts share one local transaction. There
/// is no network dependency and a retry cannot apply a completed session twice.
class BatchRecordService {
  BatchRecordService({
    required FeatureRecordStore store,
    required WriteTransactionRunner transactions,
    required FarmContextRepository context,
    required AnimalRepository animals,
    required LotesRepository lots,
    required HealthRecordRepository health,
    required WeightRecordRepository weights,
    required MovementRecordRepository movements,
    required LocationRepository locations,
  }) : _sessions = JsonFeatureRepository<BatchRecordSession>(
         store: store,
         kind: 'record.batch_session',
         decode: BatchRecordSession.fromJson,
         encode: (session) => session.toJson(),
       ),
       _transactions = transactions,
       _context = context,
       _animals = animals,
       _lots = lots,
       _health = health,
       _weights = weights,
       _movements = movements,
       _locations = locations;

  final JsonFeatureRepository<BatchRecordSession> _sessions;
  final WriteTransactionRunner _transactions;
  final FarmContextRepository _context;
  final AnimalRepository _animals;
  final LotesRepository _lots;
  final HealthRecordRepository _health;
  final WeightRecordRepository _weights;
  final MovementRecordRepository _movements;
  final LocationRepository _locations;

  Future<FarmContext> _access({String? farmId, BatchRecordKind? kind}) async {
    final current = await _context.current();
    if (current == null || (farmId != null && current.farmId != farmId))
      throw StateError('Abre la finca de esta sesión para continuar.');
    if (!current.membership.role.canOperate ||
        (kind == BatchRecordKind.health &&
            !current.membership.role.canManageHealth))
      throw StateError('Tu acceso no permite registrar esta actividad.');
    return current;
  }

  Future<List<BatchRecordSession>> list() async {
    final current = await _access();
    final sessions = await _sessions.list(current.farmId);
    sessions.sort((a, b) {
      final state = (a.isCompleted ? 1 : 0).compareTo(b.isCompleted ? 1 : 0);
      return state != 0 ? state : b.createdAt.compareTo(a.createdAt);
    });
    return sessions;
  }

  Future<BatchRecordSession> open(String uuid) async {
    final current = await _access();
    final session = await _sessions.get(current.farmId, uuid);
    if (session == null) throw StateError('No se encontró la sesión.');
    await _access(farmId: session.farmId, kind: session.kind);
    return session;
  }

  Future<BatchRecordSession> start({
    required String lotUuid,
    required BatchRecordKind kind,
  }) => _transactions.run(() async {
    final current = await _access(kind: kind);
    final lot = await _lots.getByUuid(lotUuid);
    if (lot == null || !lot.active)
      throw StateError('Selecciona un lote activo.');
    final animals = await _animals.getByBatchUuid(lotUuid);
    final members = animals.where((a) => a.status.isInActiveHerd).toList()
      ..sort((a, b) => a.earTagNumber.compareTo(b.earTagNumber));
    if (members.isEmpty) throw StateError('El lote no tiene animales activos.');
    final now = DateTime.now();
    final session = BatchRecordSession(
      uuid: 'batch-${const Uuid().v4()}',
      farmId: current.farmId,
      lotUuid: lot.uuid,
      lotName: lot.name,
      kind: kind,
      date: now,
      createdAt: now,
      participants: List.unmodifiable(
        members.map(
          (a) => BatchParticipant(
            uuid: a.uuid,
            tag: a.earTagNumber,
            name: a.customName,
            locationId: a.currentLocationId,
          ),
        ),
      ),
    );
    return _sessions.save(
      farmId: session.farmId,
      value: session,
      uuid: session.uuid,
    );
  });

  Future<BatchRecordSession> saveDraft(
    BatchRecordSession draft, {
    required int expectedVersion,
  }) => _transactions.run(() async {
    await _access(farmId: draft.farmId, kind: draft.kind);
    final current = await _sessions.get(draft.farmId, draft.uuid);
    if (draft.isCompleted || draft.savedCount != 0) {
      throw StateError(
        'Confirma la sesión para aplicar los registros; un borrador no puede marcarse como completado.',
      );
    }
    if (current == null || current.isCompleted)
      throw StateError('La sesión ya se completó o no está disponible.');
    if (current.version != expectedVersion)
      throw StateError(
        'La sesión cambió en otra pantalla. Vuelve a abrirla antes de editar.',
      );
    if (current.lotUuid != draft.lotUuid ||
        current.kind != draft.kind ||
        current.participants.length != draft.participants.length ||
        !List.generate(
          current.participants.length,
          (i) => current.participants[i].uuid == draft.participants[i].uuid,
        ).every((same) => same))
      throw StateError(
        'Los integrantes originales de la sesión no se pueden reemplazar.',
      );
    final memberIds = current.participants.map((p) => p.uuid).toSet();
    if (!memberIds.containsAll(draft.skipped) ||
        !memberIds.containsAll(draft.weights.keys))
      throw StateError('La captura contiene animales ajenos a la sesión.');
    final saved = draft.copyWith(version: current.version + 1);
    return _sessions.save(farmId: saved.farmId, value: saved, uuid: saved.uuid);
  });

  Future<BatchRecordSession> discard(String uuid) =>
      _transactions.run(() async {
        final session = await open(uuid);
        if (session.isCompleted)
          throw StateError('Una sesión completada conserva su historial.');
        await _sessions.delete(session.farmId, session.uuid);
        return session;
      });

  Future<BatchRecordSession> complete(
    String uuid, {
    required int expectedVersion,
  }) => _transactions.run(() async {
    final session = await open(uuid);
    if (session.isCompleted) return session;
    if (session.version != expectedVersion)
      throw StateError(
        'La sesión cambió. Vuelve a abrirla antes de confirmar.',
      );
    final included = session.included;
    if (included.isEmpty)
      throw StateError('Incluye al menos un animal con datos para guardar.');
    final animals = <String, AnimalEntity>{};
    for (final member in included) {
      final animal = await _animals.getByUuid(member.uuid);
      if (animal == null)
        throw StateError(
          'Ya no se encuentra ${member.tag}. Omítelo para continuar.',
        );
      AnimalRecordValidation.operation(animal, session.date);
      animals[member.uuid] = animal;
    }
    final now = DateTime.now();
    String recordUuid(String animalUuid) => '${session.uuid}-$animalUuid';
    switch (session.kind) {
      case BatchRecordKind.weight:
        final entries = <WeightBatchEntry>[];
        for (final member in included) {
          final weight = parseFormDouble(session.weights[member.uuid]!);
          if (weight == null || !weight.isFinite || weight <= 0)
            throw StateError(
              'Corrige el peso de ${member.tag}. Debe ser mayor que cero.',
            );
          entries.add(
            WeightBatchEntry(
              animalUuid: member.uuid,
              record: WeightRecord(
                animalUuid: member.uuid,
                lotUuid: session.lotUuid,
                date: session.date,
                weight: weight,
                method: WeightMethod.scale,
                notes: _optional(session.notes),
                measuredBy: _optional(session.responsible),
                createdAt: now,
                recordUuid: recordUuid(member.uuid),
              ),
            ),
          );
        }
        await _weights.addWeightRecordsAtomically(entries);
      case BatchRecordKind.health:
        final days = session.withdrawalDays.trim().isEmpty
            ? null
            : int.tryParse(session.withdrawalDays.trim());
        if (session.withdrawalDays.trim().isNotEmpty &&
            (days == null || days < 0))
          throw StateError(
            'Los días de retiro deben ser un número entero igual o mayor que cero.',
          );
        final record = HealthRecord(
          date: session.date,
          type: session.healthType,
          product: session.product.trim(),
          dose: _optional(session.dose),
          appliedBy: _optional(session.responsible),
          notes: _optional(session.notes),
          medicineBatch: _optional(session.medicineBatch),
          withdrawalDays: days,
          withdrawalEndDate: days == null
              ? null
              : session.date.add(Duration(days: days)),
          nextDueDate: session.nextDueDate,
        );
        AnimalRecordValidation.health(record);
        for (final member in included) {
          await _health.addHealthRecord(
            member.uuid,
            record.copyWith(recordUuid: recordUuid(member.uuid)),
          );
        }
      case BatchRecordKind.movement:
        final destinationId = session.destinationId;
        final destination = destinationId == null
            ? null
            : await _locations.getByUuid(destinationId);
        if (destination == null || destination.status == LocationStatus.closed)
          throw StateError('Selecciona una ubicación de destino activa.');
        for (final member in included) {
          if (animals[member.uuid]!.currentLocationId != member.locationId)
            throw StateError(
              'La ubicación de ${member.tag} cambió desde el inicio. Omítelo o inicia una sesión nueva.',
            );
          await _movements.addMovementRecord(
            member.uuid,
            MovementRecord(
              fromLocation: member.locationId,
              toLocation: destinationId!,
              date: session.date,
              reason: session.reason,
              notes: _optional(session.notes),
              movedBy: _optional(session.responsible),
              recordUuid: recordUuid(member.uuid),
            ),
          );
        }
        // Update the lot's position only when all current members really moved.
        final lot = await _lots.getByUuid(session.lotUuid);
        final currentMembers = await _animals.getByBatchUuid(session.lotUuid);
        if (lot != null &&
            currentMembers.isNotEmpty &&
            currentMembers.every(
              (a) =>
                  animals.containsKey(a.uuid) &&
                  a.currentLocationId == destinationId,
            )) {
          await _lots.upsert(
            lot.copyWith(
              currentLocationId: destinationId,
              lastUpdateDate: now,
              synced: false,
            ),
          );
        }
    }
    final completed = session.copyWith(
      completedAt: now,
      savedCount: included.length,
      version: session.version + 1,
    );
    return _sessions.save(
      farmId: completed.farmId,
      value: completed,
      uuid: completed.uuid,
    );
  });

  static String? _optional(String value) =>
      value.trim().isEmpty ? null : value.trim();
}
