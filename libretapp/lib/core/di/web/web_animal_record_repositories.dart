import 'package:libretapp/core/di/web/farm_record_access.dart';
import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/editable_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:uuid/uuid.dart';

DateTime? _date(dynamic value) =>
    value == null ? null : DateTime.parse(value as String);

/// All record writes, projections, and the enclosing batch receipt use one
/// Drift transaction. Record UUIDs also make a repeated insert idempotent.
abstract class _WebAnimalRecords<T> {
  _WebAnimalRecords(this.access, this.animals, this.kind);
  final FarmRecordAccess access;
  final AnimalRepository animals;
  final String kind;

  T decode(FeatureRecord row);
  Future<void> project(String animalUuid);

  Future<List<FeatureRecord>> rows() async {
    final result = (await access.list(kind)).toList();
    result.sort((a, b) {
      final event = DateTime.parse(
        b.payload['date'] as String,
      ).compareTo(DateTime.parse(a.payload['date'] as String));
      if (event != 0) return event;
      final created = b.createdAt.compareTo(a.createdAt);
      return created != 0 ? created : b.uuid.compareTo(a.uuid);
    });
    return result;
  }

  Future<List<T>> history(String animalUuid) async => (await rows())
      .where((r) => r.payload['animalUuid'] == animalUuid)
      .map(decode)
      .toList();

  Future<Map<String, T>> byUuids(Set<String> ids) async => {
    for (final row in await rows())
      if (ids.contains(row.uuid)) row.uuid: decode(row),
  };

  Future<List<({String animalUuid, T record})>> recent(int limit) async =>
      (await rows())
          .take(limit < 0 ? 0 : limit)
          .map(
            (row) => (
              animalUuid: row.payload['animalUuid'] as String,
              record: decode(row),
            ),
          )
          .toList();

  Future<AnimalEntity> animal(
    String uuid,
    DateTime date, {
    bool editing = false,
  }) async {
    await access.requireWrite(health: kind == 'animal.health');
    final current = await animals.getByUuid(uuid);
    if (current == null) throw StateError('Animal no encontrado.');
    AnimalRecordValidation.operation(current, date, editing: editing);
    return current;
  }

  Future<Map<String, dynamic>> baseline(
    AnimalEntity animal,
    Map<String, dynamic> values,
  ) async {
    final uuid = 'animal-baseline-${animal.uuid}';
    final previous = await access.get('animal.record_baseline', uuid);
    final payload = {...?previous?.payload};
    var changed = false;
    for (final entry in values.entries) {
      if (!payload.containsKey(entry.key)) {
        payload[entry.key] = entry.value;
        changed = true;
      }
    }
    if (changed) await access.put('animal.record_baseline', uuid, payload);
    return payload;
  }

  Future<FeatureRecord?> existing(
    String? uuid,
    String animalUuid,
    Map<String, dynamic> payload, {
    bool editing = false,
  }) async {
    if (uuid == null) return null;
    final row = await access.store.get(await access.farmId, uuid);
    if (row == null) {
      if (editing) throw StateError('No se encontró el registro a corregir.');
      return null;
    }
    if (row.kind != kind ||
        row.deletedAt != null ||
        row.payload['animalUuid'] != animalUuid) {
      throw ArgumentError(
        'La identidad del registro ya pertenece a otra captura.',
      );
    }
    if (!editing &&
        (row.payload.length != payload.length ||
            payload.entries.any(
              (entry) => row.payload[entry.key] != entry.value,
            ))) {
      throw ArgumentError('El registro ya existe con otra captura.');
    }
    return row;
  }

  Future<T> write(
    String uuid,
    Map<String, dynamic> payload, {
    DateTime? createdAt,
  }) async {
    final row = await access.put(kind, uuid, payload, createdAt: createdAt);
    await project(payload['animalUuid'] as String);
    return decode(row);
  }

  Future<void> delete(String uuid) => access.transaction(() async {
    await access.requireWrite(health: kind == 'animal.health');
    final row = await access.get(kind, uuid);
    if (row == null) return;
    await access.delete(kind, uuid);
    await project(row.payload['animalUuid'] as String);
  });
}

class WebWeightRecordRepository extends _WebAnimalRecords<WeightRecord>
    implements
        WeightRecordRepository,
        WeightRecordUuidLookup,
        EditableRecordRepository<WeightRecord> {
  WebWeightRecordRepository(FarmRecordAccess access, AnimalRepository animals)
    : super(access, animals, 'animal.weight');

  @override
  WeightRecord decode(FeatureRecord row) {
    final p = row.payload;
    return WeightRecord(
      id: row.uuid,
      recordUuid: row.uuid,
      animalUuid: p['animalUuid'] as String,
      lotUuid: p['lotUuid'] as String?,
      date: DateTime.parse(p['date'] as String),
      weight: (p['weight'] as num).toDouble(),
      method: WeightMethod.values.byName(p['method'] as String),
      measuredBy: p['measuredBy'] as String?,
      notes: p['notes'] as String?,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Future<List<WeightRecord>> getWeightRecords(String animalUuid) =>
      history(animalUuid);
  @override
  Future<Map<String, WeightRecord>> getWeightRecordsByRecordUuids(
    Set<String> ids,
  ) => byUuids(ids);
  @override
  Future<Map<String, List<WeightRecord>>> getWeightRecordsForAnimals(
    Set<String> ids,
  ) async {
    final result = <String, List<WeightRecord>>{};
    for (final row in await rows()) {
      final id = row.payload['animalUuid'] as String;
      if (ids.contains(id)) result.putIfAbsent(id, () => []).add(decode(row));
    }
    return result;
  }

  @override
  Future<List<WeightRecord>> getWeightRecordsForLot(String lotUuid) async =>
      (await rows())
          .where((r) => r.payload['lotUuid'] == lotUuid)
          .map(decode)
          .toList();
  @override
  Future<WeightRecord> addWeightRecord(
    String animalUuid,
    WeightRecord record,
  ) => access.transaction(() => _save(animalUuid, record));
  @override
  Future<List<WeightRecord>> addWeightRecordsAtomically(
    List<WeightBatchEntry> entries,
  ) => access.transaction(() async {
    final result = <WeightRecord>[];
    for (final entry in entries) {
      result.add(await _save(entry.animalUuid, entry.record));
    }
    return result;
  });

  Future<WeightRecord> _save(
    String animalUuid,
    WeightRecord record, {
    bool editing = false,
  }) async {
    if (record.animalUuid != null && record.animalUuid != animalUuid) {
      throw ArgumentError('El peso pertenece a otro animal.');
    }
    if (!record.weight.isFinite || record.weight <= 0)
      throw ArgumentError('El peso debe ser mayor que cero.');
    final uuid = editing ? record.id : record.recordUuid ?? const Uuid().v4();
    if (uuid == null) throw ArgumentError('Falta la identidad del registro.');
    final payload = <String, dynamic>{
      'animalUuid': animalUuid,
      'lotUuid': record.lotUuid,
      'date': record.date.toIso8601String(),
      'weight': record.weight,
      'method': record.method.name,
      'measuredBy': record.measuredBy,
      'notes': record.notes,
    };
    await access.requireWrite();
    final old = await existing(uuid, animalUuid, payload, editing: editing);
    if (old != null && !editing) return decode(old);
    final current = await animal(animalUuid, record.date, editing: editing);
    await baseline(current, {'weight': current.weight});
    return write(uuid, payload, createdAt: record.createdAt);
  }

  @override
  Future<void> project(String animalUuid) async {
    final current = await animals.getByUuid(animalUuid);
    if (current == null) return;
    final original = await baseline(current, {'weight': current.weight});
    final records = await history(animalUuid);
    await animals.update(
      current.copyWith(
        weight: records.isEmpty
            ? (original['weight'] as num?)?.toDouble()
            : records.first.weight,
      ),
    );
  }

  @override
  Future<void> deleteWeightRecord(String recordId) => delete(recordId);
  @override
  Future<WeightRecord> updateRecord(String animalUuid, WeightRecord record) =>
      access.transaction(() => _save(animalUuid, record, editing: true));
}

class WebHealthRecordRepository extends _WebAnimalRecords<HealthRecord>
    implements
        HealthRecordRepository,
        HealthRecordUuidLookup,
        HealthRecordRecentLookup,
        EditableRecordRepository<HealthRecord> {
  WebHealthRecordRepository(FarmRecordAccess access, AnimalRepository animals)
    : super(access, animals, 'animal.health');

  @override
  HealthRecord decode(FeatureRecord row) {
    final p = row.payload;
    return HealthRecord(
      id: row.uuid,
      recordUuid: row.uuid,
      updatedAt: row.updatedAt,
      date: DateTime.parse(p['date'] as String),
      type: HealthRecordType.values.byName(p['type'] as String),
      product: p['product'] as String,
      dose: p['dose'] as String?,
      appliedBy: p['appliedBy'] as String?,
      notes: p['notes'] as String?,
      cause: p['cause'] as String?,
      nextDueDate: _date(p['nextDueDate']),
      medicineBatch: p['medicineBatch'] as String?,
      withdrawalDays: p['withdrawalDays'] as int?,
      withdrawalEndDate: _date(p['withdrawalEndDate']),
    );
  }

  @override
  Future<List<HealthRecord>> getHealthRecords(String animalUuid) =>
      history(animalUuid);
  @override
  Future<Map<String, HealthRecord>> getHealthRecordsByRecordUuids(
    Set<String> ids,
  ) => byUuids(ids);
  @override
  Future<List<({String animalUuid, HealthRecord record})>>
  getRecentHealthRecords({int limit = 5}) => recent(limit);
  @override
  Future<Map<String, DateTime>> getActiveWithdrawals(
    Set<String> ids, {
    DateTime? asOf,
  }) async {
    final result = <String, DateTime>{};
    final reference = asOf ?? DateTime.now();
    for (final row in await rows()) {
      final id = row.payload['animalUuid'] as String;
      final end = decode(row).withdrawalEndDate;
      if (ids.contains(id) &&
          end != null &&
          end.isAfter(reference) &&
          (result[id] == null || end.isAfter(result[id]!)))
        result[id] = end;
    }
    return result;
  }

  @override
  Future<HealthRecord> addHealthRecord(
    String animalUuid,
    HealthRecord record,
  ) => access.transaction(() => _save(animalUuid, record));
  @override
  Future<void> addHealthRecordToMultiple(
    List<String> ids,
    HealthRecord record,
  ) => access.transaction(() async {
    for (final id in ids.toSet()) {
      await _save(
        id,
        record.copyWith(
          recordUuid: record.recordUuid == null
              ? const Uuid().v4()
              : '${record.recordUuid}-$id',
        ),
      );
    }
  });

  Future<HealthRecord> _save(
    String animalUuid,
    HealthRecord record, {
    bool editing = false,
  }) async {
    AnimalRecordValidation.health(record);
    final uuid = editing ? record.id : record.recordUuid ?? const Uuid().v4();
    if (uuid == null) throw ArgumentError('Falta la identidad del registro.');
    final payload = <String, dynamic>{
      'animalUuid': animalUuid,
      'date': record.date.toIso8601String(),
      'type': record.type.name,
      'product': record.product,
      'dose': record.dose,
      'appliedBy': record.appliedBy,
      'notes': record.notes,
      'cause': record.cause,
      'nextDueDate': record.nextDueDate?.toIso8601String(),
      'medicineBatch': record.medicineBatch,
      'withdrawalDays': record.withdrawalDays,
      'withdrawalEndDate': record.withdrawalEndDate?.toIso8601String(),
    };
    await access.requireWrite(health: true);
    final old = await existing(uuid, animalUuid, payload, editing: editing);
    if (old != null && !editing) return decode(old);
    final current = await animal(animalUuid, record.date, editing: editing);
    await baseline(current, _healthBaseline(current));
    return write(uuid, payload);
  }

  Map<String, dynamic> _healthBaseline(AnimalEntity a) => {
    'vaccinated': a.vaccinated,
    'dewormed': a.dewormed,
    'hasVitamins': a.hasVitamins,
    'underObservation': a.underObservation,
    'requiresAttention': a.requiresAttention,
    'status': a.status.name,
  };

  @override
  Future<void> project(String animalUuid) async {
    final current = await animals.getByUuid(animalUuid);
    if (current == null) return;
    final original = await baseline(current, _healthBaseline(current));
    final types = (await history(animalUuid)).map((r) => r.type).toSet();
    final disease = types.contains(HealthRecordType.disease);
    final death = types.contains(HealthRecordType.death);
    final status = death
        ? AnimalStatus.dead
        : current.status == AnimalStatus.dead
        ? AnimalStatus.values.byName(original['status'] as String)
        : current.status;
    await animals.update(
      current.copyWith(
        vaccinated:
            original['vaccinated'] == true ||
            types.contains(HealthRecordType.vaccine),
        dewormed:
            original['dewormed'] == true ||
            types.contains(HealthRecordType.deworming),
        hasVitamins:
            original['hasVitamins'] == true ||
            types.contains(HealthRecordType.vitamins),
        underObservation:
            status.isInActiveHerd &&
            (original['underObservation'] == true || disease),
        requiresAttention:
            status.isInActiveHerd &&
            (original['requiresAttention'] == true || disease),
        status: status,
      ),
    );
  }

  @override
  Future<void> deleteHealthRecord(String recordId) => delete(recordId);
  @override
  Future<HealthRecord> updateRecord(String animalUuid, HealthRecord record) =>
      access.transaction(() => _save(animalUuid, record, editing: true));
}

class WebMovementRecordRepository extends _WebAnimalRecords<MovementRecord>
    implements
        MovementRecordRepository,
        AtomicMovementRepository,
        MovementRecordUuidLookup,
        MovementRecordRecentLookup,
        EditableRecordRepository<MovementRecord> {
  WebMovementRecordRepository(
    FarmRecordAccess access,
    AnimalRepository animals,
    this.locations,
    this.lots,
  ) : super(access, animals, 'animal.movement');
  final LocationRepository locations;
  final LotesRepository lots;

  @override
  MovementRecord decode(FeatureRecord row) {
    final p = row.payload;
    return MovementRecord(
      id: row.uuid,
      recordUuid: row.uuid,
      updatedAt: row.updatedAt,
      date: DateTime.parse(p['date'] as String),
      fromLocation: p['fromLocation'] as String?,
      toLocation: p['toLocation'] as String,
      clearsLocation: p['clearsLocation'] as bool,
      reason: MovementReason.values.byName(p['reason'] as String),
      notes: p['notes'] as String?,
      movedBy: p['movedBy'] as String?,
      latitude: (p['latitude'] as num?)?.toDouble(),
      longitude: (p['longitude'] as num?)?.toDouble(),
      accuracyMeters: (p['accuracyMeters'] as num?)?.toDouble(),
    );
  }

  @override
  Future<List<MovementRecord>> getMovementRecords(String animalUuid) =>
      history(animalUuid);
  @override
  Future<Map<String, MovementRecord>> getMovementRecordsByRecordUuids(
    Set<String> ids,
  ) => byUuids(ids);
  @override
  Future<List<({String animalUuid, MovementRecord record})>>
  getRecentMovementRecords({int limit = 5}) => recent(limit);
  @override
  Future<MovementRecord> addMovementRecord(
    String animalUuid,
    MovementRecord record,
  ) => access.transaction(() => _save(animalUuid, record));
  @override
  Future<List<MovementRecord>> addMovementRecordsAtomically(
    List<MovementBatchEntry> entries,
  ) => access.transaction(() async {
    final result = <MovementRecord>[];
    for (final entry in entries) {
      result.add(await _save(entry.animalUuid, entry.record));
    }
    return result;
  });

  Future<MovementRecord> _save(
    String animalUuid,
    MovementRecord record, {
    bool editing = false,
  }) async {
    final uuid = editing ? record.id : record.recordUuid ?? const Uuid().v4();
    if (uuid == null) throw ArgumentError('Falta la identidad del registro.');
    final payload = <String, dynamic>{
      'animalUuid': animalUuid,
      'date': record.date.toIso8601String(),
      'fromLocation': record.fromLocation,
      'toLocation': record.toLocation,
      'clearsLocation': record.clearsLocation,
      'reason': record.reason.name,
      'notes': record.notes,
      'movedBy': record.movedBy,
      'latitude': record.latitude,
      'longitude': record.longitude,
      'accuracyMeters': record.accuracyMeters,
    };
    await access.requireWrite();
    final old = await existing(uuid, animalUuid, payload, editing: editing);
    if (old != null && !editing) return decode(old);
    final current = await animal(animalUuid, record.date, editing: editing);
    if (!record.clearsLocation) {
      final destination = await locations.getByUuid(record.toLocation);
      if (destination == null ||
          destination.archivedAt != null ||
          destination.status == LocationStatus.closed) {
        throw ArgumentError('Selecciona una ubicación de destino activa.');
      }
    }
    await baseline(current, {
      'currentLocationId': current.currentLocationId,
      'lastMovementDate': current.lastMovementDate?.toIso8601String(),
    });
    return write(uuid, payload);
  }

  @override
  Future<void> project(String animalUuid) async {
    final current = await animals.getByUuid(animalUuid);
    if (current == null) return;
    final original = await baseline(current, {
      'currentLocationId': current.currentLocationId,
      'lastMovementDate': current.lastMovementDate?.toIso8601String(),
    });
    final records = await history(animalUuid);
    final latest = records.isEmpty ? null : records.first;
    await animals.update(
      current.copyWith(
        currentLocationId: latest == null
            ? original['currentLocationId'] as String?
            : latest.clearsLocation
            ? null
            : latest.toLocation,
        lastMovementDate: latest?.date ?? _date(original['lastMovementDate']),
      ),
    );
  }

  @override
  Future<void> moveLotAtomically(String lotUuid, String? destinationId) =>
      access.transaction(() async {
        await access.requireWrite();
        final lot = await lots.getByUuid(lotUuid);
        if (lot == null || !lot.active)
          throw StateError('Selecciona un lote activo.');
        final now = DateTime.now();
        for (final member in await animals.getByBatchUuid(lotUuid)) {
          if (member.currentLocationId == destinationId) continue;
          await _save(
            member.uuid,
            MovementRecord(
              date: now,
              fromLocation: member.currentLocationId,
              toLocation: destinationId ?? '',
              clearsLocation: destinationId == null,
              reason: MovementReason.paddockRotation,
            ),
          );
        }
        await lots.upsert(lot.copyWith(currentLocationId: destinationId));
      });

  @override
  Future<void> deleteMovementRecord(String recordId) => delete(recordId);
  @override
  Future<MovementRecord> updateRecord(
    String animalUuid,
    MovementRecord record,
  ) => access.transaction(() => _save(animalUuid, record, editing: true));
}
