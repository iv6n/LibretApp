import 'package:libretapp/core/di/web/farm_record_access.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lote_dto.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:uuid/uuid.dart';

class WebLotesRepository implements LotesRepository {
  WebLotesRepository(this.access, this.animals);
  final FarmRecordAccess access;
  final AnimalRepository animals;
  static const _kind = 'lot';

  @override
  Stream<List<LoteEntity>> watchAll() => access
      .watch(_kind)
      .map(
        (rows) =>
            rows.map((r) => LoteDto.fromJson(r.payload).toEntity()).toList(),
      );
  @override
  Future<List<LoteEntity>> getAll() async => (await access.list(
    _kind,
  )).map((r) => LoteDto.fromJson(r.payload).toEntity()).toList();
  @override
  Future<LoteEntity?> getByUuid(String uuid) async {
    final row = await access.get(_kind, uuid);
    return row == null ? null : LoteDto.fromJson(row.payload).toEntity();
  }

  @override
  Future<void> upsert(LoteEntity lote) => access.transaction(() async {
    await access.requireWrite();
    if (lote.name.trim().isEmpty)
      throw ArgumentError('Indica el nombre del lote.');
    final saved = lote.copyWith(
      lastUpdateDate: DateTime.now().toUtc(),
      synced: false,
    );
    await access.put(
      _kind,
      saved.uuid,
      LoteDto.fromEntity(saved).toJson(),
      createdAt: saved.createdAt,
    );
  });
  @override
  Future<void> updateLote(LoteEntity lote) => upsert(lote);
  @override
  Future<LoteEntity> createLote({
    required String nombre,
    String? descripcion,
    String? notas,
    double? feedPricePerKg,
    double? dailyFeedKgPerHead,
    double? liveWeightPricePerKg,
  }) async {
    final now = DateTime.now();
    final lot = LoteEntity(
      uuid: const Uuid().v4(),
      name: nombre.trim(),
      description: descripcion,
      notes: notas,
      createdAt: now,
      lastUpdateDate: now,
      feedPricePerKg: feedPricePerKg,
      dailyFeedKgPerHead: dailyFeedKgPerHead,
      liveWeightPricePerKg: liveWeightPricePerKg,
    );
    await upsert(lot);
    return (await getByUuid(lot.uuid))!;
  }

  @override
  Future<void> deleteLote(String uuid) => access.transaction(() async {
    final lot = await getByUuid(uuid);
    if (lot != null)
      await upsert(lot.copyWith(active: false, closedAt: DateTime.now()));
  });
  @override
  Future<void> purge(String uuid) => access.transaction(() async {
    await access.requireWrite();
    for (final animal in await animals.getByBatchUuid(uuid)) {
      await animals.update(animal.copyWith(batchUuid: null));
    }
    await access.delete(_kind, uuid);
  });
  @override
  Future<void> clearAll() => access.transaction(() async {
    for (final lot in await getAll()) {
      await purge(lot.uuid);
    }
  });
  @override
  Future<List<LoteEntity>> getActiveLotes() async =>
      (await getAll()).where((l) => l.active).toList();
  @override
  Future<List<LoteEntity>> getInactiveLotes() async =>
      (await getAll()).where((l) => !l.active).toList();
  @override
  Future<String?> getLoteThatContainsAnimal(String animalUuid) async =>
      (await animals.getByUuid(animalUuid))?.batchUuid;
  @override
  Future<void> addAnimalToLote({
    required String loteUuid,
    required String animalUuid,
  }) => addAnimalsToLote(loteUuid: loteUuid, animalUuids: [animalUuid]);
  @override
  Future<void> addAnimalsToLote({
    required String loteUuid,
    required List<String> animalUuids,
  }) => access.transaction(() async {
    await access.requireWrite();
    final lot = await getByUuid(loteUuid);
    if (lot == null || !lot.active)
      throw StateError('Selecciona un lote activo.');
    for (final uuid in animalUuids.toSet()) {
      final animal = await animals.getByUuid(uuid);
      if (animal == null || !animal.status.isInActiveHerd)
        throw StateError('Animal no disponible.');
      if (animal.batchUuid != null && animal.batchUuid != loteUuid) {
        await removeAnimalFromLote(
          loteUuid: animal.batchUuid!,
          animalUuid: uuid,
        );
      }
      await animals.update(animal.copyWith(batchUuid: loteUuid));
    }
    await upsert(
      lot.copyWith(animalUuids: {...lot.animalUuids, ...animalUuids}.toList()),
    );
  });
  @override
  Future<void> removeAnimalFromLote({
    required String loteUuid,
    required String animalUuid,
  }) => removeAnimalsFromLote(loteUuid: loteUuid, animalUuids: [animalUuid]);
  @override
  Future<void> removeAnimalsFromLote({
    required String loteUuid,
    required List<String> animalUuids,
  }) => access.transaction(() async {
    await access.requireWrite();
    final lot = await getByUuid(loteUuid);
    if (lot == null) return;
    final ids = animalUuids.toSet();
    for (final uuid in ids) {
      final animal = await animals.getByUuid(uuid);
      if (animal != null && animal.batchUuid == loteUuid) {
        await animals.update(animal.copyWith(batchUuid: null));
      }
    }
    await upsert(
      lot.copyWith(
        animalUuids: lot.animalUuids.where((id) => !ids.contains(id)).toList(),
      ),
    );
  });
}
