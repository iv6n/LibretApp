import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/isar/isar_lote.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

class LotesRepositoryIsar implements LotesRepository {
  LotesRepositoryIsar(this._database);

  final IsarDatabase _database;

  Future<Isar> get _isar async => _database.initialize();

  @override
  Stream<List<LoteEntity>> watchAll() async* {
    final isar = await _isar;
    await _seedIfEmpty(isar);
    yield* isar.isarLotes
        .where()
        .watch(fireImmediately: true)
        .map((lotes) => lotes.map((isarLote) => isarLote.toEntity()).toList());
  }

  @override
  Future<List<LoteEntity>> getAll() async {
    final isar = await _isar;
    await _seedIfEmpty(isar);
    final lotes = await isar.isarLotes.where().findAll();
    return lotes.map((l) => l.toEntity()).toList();
  }

  @override
  Future<LoteEntity?> getByUuid(String uuid) async {
    final isar = await _isar;
    final lote = await isar.isarLotes.where().uuidEqualTo(uuid).findFirst();
    return lote?.toEntity();
  }

  @override
  Future<LoteEntity> createLote({
    required String nombre,
    String? descripcion,
    String? notas,
  }) async {
    final isar = await _isar;
    final uuid =
        'lote-${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond}';
    final now = DateTime.now();

    final isarLote = IsarLote()
      ..uuid = uuid
      ..nombre = nombre
      ..descripcion = descripcion
      ..animalUuids = []
      ..fechaCreacion = now
      ..activo = true
      ..notas = notas
      ..lastUpdateDate = now
      ..synced = false;

    await isar.writeTxn(() async {
      await isar.isarLotes.put(isarLote);
    });

    return isarLote.toEntity();
  }

  @override
  Future<void> updateLote(LoteEntity lote) async {
    final isar = await _isar;
    final isarLote = lote.toIsarLote();

    await isar.writeTxn(() async {
      final existing = await isar.isarLotes
          .where()
          .uuidEqualTo(lote.uuid)
          .findFirst();

      if (existing != null) {
        isarLote.id = existing.id;
      }

      await isar.isarLotes.put(isarLote);
    });
  }

  @override
  Future<void> deleteLote(String uuid) async {
    final isar = await _isar;

    await isar.writeTxn(() async {
      await isar.isarLotes.where().uuidEqualTo(uuid).deleteFirst();
    });
  }

  @override
  Future<void> addAnimalToLote({
    required String loteUuid,
    required String animalUuid,
  }) async {
    final isar = await _isar;

    await isar.writeTxn(() async {
      final lote = await isar.isarLotes
          .where()
          .uuidEqualTo(loteUuid)
          .findFirst();

      if (lote != null) {
        final animalUuids = {...lote.animalUuids, animalUuid}.toList();
        lote.animalUuids = animalUuids;
        lote.lastUpdateDate = DateTime.now();
        await isar.isarLotes.put(lote);
      }
    });
  }

  @override
  Future<void> addAnimalsToLote({
    required String loteUuid,
    required List<String> animalUuids,
  }) async {
    final isar = await _isar;

    await isar.writeTxn(() async {
      final lote = await isar.isarLotes
          .where()
          .uuidEqualTo(loteUuid)
          .findFirst();

      if (lote != null) {
        final updated = {...lote.animalUuids, ...animalUuids}.toList();
        lote.animalUuids = updated;
        lote.lastUpdateDate = DateTime.now();
        await isar.isarLotes.put(lote);
      }
    });
  }

  @override
  Future<void> removeAnimalFromLote({
    required String loteUuid,
    required String animalUuid,
  }) async {
    final isar = await _isar;

    await isar.writeTxn(() async {
      final lote = await isar.isarLotes
          .where()
          .uuidEqualTo(loteUuid)
          .findFirst();

      if (lote != null) {
        final animalUuids = lote.animalUuids
            .where((uuid) => uuid != animalUuid)
            .toList();
        lote.animalUuids = animalUuids;
        lote.lastUpdateDate = DateTime.now();
        await isar.isarLotes.put(lote);
      }
    });
  }

  @override
  Future<void> removeAnimalsFromLote({
    required String loteUuid,
    required List<String> animalUuids,
  }) async {
    final isar = await _isar;

    await isar.writeTxn(() async {
      final lote = await isar.isarLotes
          .where()
          .uuidEqualTo(loteUuid)
          .findFirst();

      if (lote != null) {
        final uuidSet = animalUuids.toSet();
        final updated = lote.animalUuids
            .where((uuid) => !uuidSet.contains(uuid))
            .toList();
        lote.animalUuids = updated;
        lote.lastUpdateDate = DateTime.now();
        await isar.isarLotes.put(lote);
      }
    });
  }

  @override
  Future<List<LoteEntity>> getActiveLotes() async {
    final isar = await _isar;
    final lotes = await isar.isarLotes.filter().activoEqualTo(true).findAll();
    return lotes.map((l) => l.toEntity()).toList();
  }

  @override
  Future<List<LoteEntity>> getInactiveLotes() async {
    final isar = await _isar;
    final lotes = await isar.isarLotes.filter().activoEqualTo(false).findAll();
    return lotes.map((l) => l.toEntity()).toList();
  }

  @override
  Future<String?> getLoteThatContainsAnimal(String animalUuid) async {
    final isar = await _isar;
    final lotes = await isar.isarLotes.where().findAll();
    for (final lote in lotes) {
      if (lote.animalUuids.contains(animalUuid)) {
        return lote.uuid;
      }
    }
    return null;
  }

  Future<void> _seedIfEmpty(Isar isar) async {
    final existing = await isar.isarLotes.where().findAll();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    final loteSeeds = [
      LoteEntity(
        uuid: 'lote-ordeño-a',
        nombre: 'Lote A - Ordeño',
        descripcion: 'Lote de vacas en ordeño',
        animalUuids: const ['uuid-bessie', 'uuid-lola', 'uuid-estrella'],
        fechaCreacion: now.subtract(const Duration(days: 180)),
        fechaCierre: null,
        activo: true,
        notas: 'Lote productivo de vacas lecheras',
        lastUpdateDate: now,
        synced: false,
        remoteId: null,
        syncDate: null,
      ),
      LoteEntity(
        uuid: 'lote-engorde-b',
        nombre: 'Lote B - Engorde',
        descripcion: 'Lote de engorde y cría',
        animalUuids: const ['uuid-pampa', 'uuid-aurora', 'uuid-brisa'],
        fechaCreacion: now.subtract(const Duration(days: 150)),
        fechaCierre: null,
        activo: true,
        notas: 'Lote de hembras jóvenes en crecimiento',
        lastUpdateDate: now,
        synced: false,
        remoteId: null,
        syncDate: null,
      ),
      LoteEntity(
        uuid: 'lote-cria-c',
        nombre: 'Lote C - Cría',
        descripcion: 'Lote de reproducción',
        animalUuids: const ['uuid-gaia', 'uuid-rosario'],
        fechaCreacion: now.subtract(const Duration(days: 200)),
        fechaCierre: null,
        activo: true,
        notas: 'Lote de hembras en reproducción',
        lastUpdateDate: now,
        synced: false,
        remoteId: null,
        syncDate: null,
      ),
    ];

    await isar.writeTxn(() async {
      await isar.isarLotes.putAll(
        loteSeeds.map((l) => l.toIsarLote()).toList(),
      );
    });
  }
}
