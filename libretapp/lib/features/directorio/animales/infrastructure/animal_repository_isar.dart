import 'package:isar/isar.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/production_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/category.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/health_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_purpose.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/reproductive_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/risk_level.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/sex.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_lifecycle_calculator.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_remote_data_source.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_commercial_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_cost_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_health_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_movement_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_production_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_weight_record.dart';

class AnimalRepositoryIsar implements AnimalRepository {
  AnimalRepositoryIsar(this._database, this._prefs, this._remoteDataSource);

  static const _logTag = 'AnimalRepositoryIsar';
  final IsarDatabase _database;
  final SharedPrefsService _prefs;
  final AnimalRemoteDataSource _remoteDataSource;

  Future<Isar> get _isar async => _database.initialize();

  @override
  Future<bool> refreshFromRemote({bool force = false}) async {
    final remote = await _remoteDataSource.fetchAnimals();
    final lastHash = _prefs.getString(PrefsKeys.animalsHash);
    final shouldUpdate = force || lastHash != remote.hash;

    await _prefs.setString(PrefsKeys.animalsHash, remote.hash);
    await _prefs.setDateTime(PrefsKeys.animalsLastSync, remote.lastUpdated);

    if (!shouldUpdate) {
      LoggerService.i('Animales sin cambios desde remoto', tag: _logTag);
      return false;
    }

    final isar = await _isar;
    final existing = await isar.isarAnimals.where().findAll();
    final idsByUuid = {for (final record in existing) record.uuid: record.id};

    final models = remote.animals
        .map((dto) {
          final entity = dto.toEntity();
          final model = entity.toIsar();
          final existingId = idsByUuid[dto.uuid];
          if (existingId != null) {
            model.id = existingId;
          }
          return model;
        })
        .toList(growable: false);

    await isar.writeTxn(() async {
      await isar.isarAnimals.putAll(models);
    });

    LoggerService.i(
      'Animales actualizados desde remoto (${models.length})',
      tag: _logTag,
    );
    return true;
  }

  @override
  Stream<List<AnimalEntity>> watchAll() async* {
    final isar = await _isar;
    await _seedIfEmpty(isar);
    yield* isar.isarAnimals
        .where()
        .watch(fireImmediately: true)
        .map(
          (records) => records.map((e) => e.toEntity()).toList(growable: false),
        );
  }

  @override
  Future<List<AnimalEntity>> getAll() async {
    final isar = await _isar;
    await _seedIfEmpty(isar);
    final records = await isar.isarAnimals.where().findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<AnimalEntity?> getByUuid(String uuid) async {
    final isar = await _isar;
    final record = await isar.isarAnimals
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();
    return record?.toEntity();
  }

  @override
  Future<List<AnimalEntity>> getBySpecies(String speciesName) async {
    final isar = await _isar;
    final records = await isar.isarAnimals
        .filter()
        .speciesEqualTo(speciesName)
        .findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<List<AnimalEntity>> getByPaddock(String paddockId) async {
    final isar = await _isar;
    final records = await isar.isarAnimals
        .filter()
        .currentPaddockIdEqualTo(paddockId)
        .findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<List<AnimalEntity>> getAnimalsRequiringAttention() async {
    final isar = await _isar;
    final records = await isar.isarAnimals
        .filter()
        .anyOf([
          RiskLevel.high.name,
          RiskLevel.critical.name,
        ], (q, level) => q.riskLevelEqualTo(level))
        .or()
        .requiresAttentionEqualTo(true)
        .or()
        .underObservationEqualTo(true)
        .or()
        .healthStatusEqualTo(HealthStatus.poor.name)
        .or()
        .healthStatusEqualTo(HealthStatus.critical.name)
        .findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<List<AnimalEntity>> getUnsynchronized() async {
    final isar = await _isar;
    final records = await isar.isarAnimals
        .filter()
        .syncedEqualTo(false)
        .findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<AnimalEntity> save(AnimalEntity animal) async {
    final isar = await _isar;
    final now = DateTime.now();
    final entity = animal.copyWith(
      creationDate: animal.creationDate,
      lastUpdateDate: now,
      synced: false,
    );

    final model = entity.toIsar();
    await isar.writeTxn(() async {
      await isar.isarAnimals.put(model);
    });
    LoggerService.i('Animal guardado ${entity.uuid}', tag: _logTag);
    return entity;
  }

  @override
  Future<AnimalEntity> update(AnimalEntity animal) async {
    final isar = await _isar;
    final now = DateTime.now();
    final updated = animal.copyWith(lastUpdateDate: now, synced: false);
    final existing = await isar.isarAnimals
        .filter()
        .uuidEqualTo(animal.uuid)
        .findFirst();
    final model = updated.toIsar();
    if (existing != null) {
      model.id = existing.id;
    }
    await isar.writeTxn(() async {
      await isar.isarAnimals.put(model);
    });
    LoggerService.i('Animal actualizado ${updated.uuid}', tag: _logTag);
    return updated;
  }

  @override
  Future<void> markAsSynced(String uuid, String remoteId) async {
    final isar = await _isar;
    final now = DateTime.now();
    await isar.writeTxn(() async {
      final record = await isar.isarAnimals
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (record != null) {
        record
          ..remoteId = remoteId
          ..synced = true
          ..syncDate = now
          ..lastUpdateDate = now;
        await isar.isarAnimals.put(record);
      }
    });
  }

  @override
  Future<void> markAsUnsynchronized(String uuid) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      final record = await isar.isarAnimals
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (record != null) {
        record
          ..synced = false
          ..syncDate = null
          ..lastUpdateDate = DateTime.now();
        await isar.isarAnimals.put(record);
      }
    });
  }

  @override
  Future<void> delete(String uuid) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      await isar.isarAnimals.filter().uuidEqualTo(uuid).deleteAll();
    });
    LoggerService.w('Animal eliminado $uuid', tag: _logTag);
  }

  @override
  Future<void> clearAll() async {
    final isar = await _isar;
    await isar.writeTxn(() => isar.isarAnimals.clear());
    LoggerService.w('Colección animales limpiada', tag: _logTag);
  }

  @override
  Future<int> count() async {
    final isar = await _isar;
    return isar.isarAnimals.count();
  }

  @override
  Future<Map<String, dynamic>> getStatistics() async {
    final isar = await _isar;
    final total = await isar.isarAnimals.count();
    final unsynced = await isar.isarAnimals
        .filter()
        .syncedEqualTo(false)
        .count();
    final attention = await isar.isarAnimals
        .filter()
        .requiresAttentionEqualTo(true)
        .or()
        .underObservationEqualTo(true)
        .count();

    return {'total': total, 'unsynced': unsynced, 'attention': attention};
  }

  @override
  Future<List<WeightRecord>> getWeightRecords(String animalUuid) async {
    final isar = await _isar;
    final records = await isar.isarWeightRecords
        .filter()
        .animalUuidEqualTo(animalUuid)
        .sortByDateDesc()
        .findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<WeightRecord> addWeightRecord(
    String animalUuid,
    WeightRecord record,
  ) async {
    final isar = await _isar;
    final model = record.toIsar(animalUuid);
    await isar.writeTxn(() async {
      final id = await isar.isarWeightRecords.put(model);
      model.id = id;
    });
    final saved = model.toEntity();
    LoggerService.i(
      'Peso registrado para $animalUuid (${saved.id})',
      tag: _logTag,
    );
    return saved;
  }

  @override
  Future<void> deleteWeightRecord(String recordId) async {
    final isar = await _isar;
    final id = int.tryParse(recordId);
    if (id == null) return;
    await isar.writeTxn(() async {
      await isar.isarWeightRecords.delete(id);
    });
  }

  @override
  Future<List<ProductionRecord>> getProductionRecords(String animalUuid) async {
    final isar = await _isar;
    final records = await isar.isarProductionRecords
        .filter()
        .animalUuidEqualTo(animalUuid)
        .sortByDateDesc()
        .findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<ProductionRecord> addProductionRecord(
    String animalUuid,
    ProductionRecord record,
  ) async {
    final isar = await _isar;
    final model = record.toIsar(animalUuid);
    await isar.writeTxn(() async {
      final id = await isar.isarProductionRecords.put(model);
      model.id = id;
    });
    final saved = model.toEntity();
    LoggerService.i(
      'Registro productivo guardado para $animalUuid (${saved.id})',
      tag: _logTag,
    );
    return saved;
  }

  @override
  Future<void> deleteProductionRecord(String recordId) async {
    final isar = await _isar;
    final id = int.tryParse(recordId);
    if (id == null) return;
    await isar.writeTxn(() async {
      await isar.isarProductionRecords.delete(id);
    });
  }

  @override
  Future<List<HealthRecord>> getHealthRecords(String animalUuid) async {
    final isar = await _isar;
    final records = await isar.isarHealthRecords
        .filter()
        .animalUuidEqualTo(animalUuid)
        .sortByDateDesc()
        .findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<HealthRecord> addHealthRecord(
    String animalUuid,
    HealthRecord record,
  ) async {
    final isar = await _isar;
    final model = record.toIsar(animalUuid);
    await isar.writeTxn(() async {
      final id = await isar.isarHealthRecords.put(model);
      model.id = id;
    });
    final saved = model.toEntity();
    LoggerService.i(
      'Registro sanitario guardado para $animalUuid (${saved.id})',
      tag: _logTag,
    );
    return saved;
  }

  @override
  Future<void> deleteHealthRecord(String recordId) async {
    final isar = await _isar;
    final id = int.tryParse(recordId);
    if (id == null) return;
    await isar.writeTxn(() async {
      await isar.isarHealthRecords.delete(id);
    });
  }

  @override
  Future<List<CommercialRecord>> getCommercialRecords(String animalUuid) async {
    final isar = await _isar;
    final records = await isar.isarCommercialRecords
        .filter()
        .animalUuidEqualTo(animalUuid)
        .sortByDateDesc()
        .findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<CommercialRecord> addCommercialRecord(
    String animalUuid,
    CommercialRecord record,
  ) async {
    final isar = await _isar;
    final model = record.toIsar(animalUuid);
    await isar.writeTxn(() async {
      final id = await isar.isarCommercialRecords.put(model);
      model.id = id;
    });
    final saved = model.toEntity();
    LoggerService.i(
      'Registro comercial guardado para $animalUuid (${saved.id})',
      tag: _logTag,
    );
    return saved;
  }

  @override
  Future<void> deleteCommercialRecord(String recordId) async {
    final isar = await _isar;
    final id = int.tryParse(recordId);
    if (id == null) return;
    await isar.writeTxn(() async {
      await isar.isarCommercialRecords.delete(id);
    });
  }

  @override
  Future<List<MovementRecord>> getMovementRecords(String animalUuid) async {
    final isar = await _isar;
    final records = await isar.isarMovementRecords
        .filter()
        .animalUuidEqualTo(animalUuid)
        .sortByDateDesc()
        .findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<MovementRecord> addMovementRecord(
    String animalUuid,
    MovementRecord record,
  ) async {
    final isar = await _isar;
    final model = record.toIsar(animalUuid);
    await isar.writeTxn(() async {
      final id = await isar.isarMovementRecords.put(model);
      model.id = id;
    });
    final saved = model.toEntity();
    LoggerService.i(
      'Movimiento guardado para $animalUuid (${saved.id})',
      tag: _logTag,
    );
    return saved;
  }

  @override
  Future<void> deleteMovementRecord(String recordId) async {
    final isar = await _isar;
    final id = int.tryParse(recordId);
    if (id == null) return;
    await isar.writeTxn(() async {
      await isar.isarMovementRecords.delete(id);
    });
  }

  @override
  Future<List<CostRecord>> getCostRecords(String animalUuid) async {
    final isar = await _isar;
    final records = await isar.isarCostRecords
        .filter()
        .animalUuidEqualTo(animalUuid)
        .sortByDateDesc()
        .findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<CostRecord> addCostRecord(String animalUuid, CostRecord record) async {
    final isar = await _isar;
    final model = record.toIsar(animalUuid);
    await isar.writeTxn(() async {
      final id = await isar.isarCostRecords.put(model);
      model.id = id;
    });
    final saved = model.toEntity();
    LoggerService.i(
      'Costo guardado para $animalUuid (${saved.id})',
      tag: _logTag,
    );
    return saved;
  }

  @override
  Future<void> deleteCostRecord(String recordId) async {
    final isar = await _isar;
    final id = int.tryParse(recordId);
    if (id == null) return;
    await isar.writeTxn(() async {
      await isar.isarCostRecords.delete(id);
    });
  }

  @override
  Future<List<ReproductionRecord>> getReproductionRecords(
    String animalUuid,
  ) async {
    final isar = await _isar;
    final records = await isar.isarReproductionRecords
        .filter()
        .animalUuidEqualTo(animalUuid)
        .sortByServiceDateDesc()
        .findAll();
    return records.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<ReproductionRecord> addReproductionRecord(
    String animalUuid,
    ReproductionRecord record,
  ) async {
    final isar = await _isar;
    final model = record.toIsar(animalUuid);
    await isar.writeTxn(() async {
      final id = await isar.isarReproductionRecords.put(model);
      model.id = id;
    });
    final saved = model.toEntity();
    LoggerService.i(
      'Evento reproductivo guardado para $animalUuid (${saved.id})',
      tag: _logTag,
    );
    return saved;
  }

  @override
  Future<void> deleteReproductionRecord(String recordId) async {
    final isar = await _isar;
    final id = int.tryParse(recordId);
    if (id == null) return;
    await isar.writeTxn(() async {
      await isar.isarReproductionRecords.delete(id);
    });
  }

  Future<void> _seedIfEmpty(Isar isar) async {
    final existing = await isar.isarAnimals.where().findAll();
    final existingUuids = existing.map((a) => a.uuid).toSet();

    // Seed if empty, or top-up missing demo animals when the dataset is tiny.
    if (existing.isNotEmpty && existing.length > 5) return;

    LoggerService.i('Sembrando datos iniciales de animales', tag: _logTag);
    final now = DateTime.now();
    final animalSeeds = _seedAnimals(referenceDate: now);
    final missingAnimals = animalSeeds
        .where((a) => !existingUuids.contains(a.uuid))
        .toList(growable: false);

    if (missingAnimals.isEmpty) return;

    final targetUuids = missingAnimals.map((a) => a.uuid).toSet();
    final weightSeeds = _seedWeightRecords(
      referenceDate: now,
    ).where((s) => targetUuids.contains(s.animalUuid)).toList(growable: false);
    final reproSeeds = _seedReproductionRecords(
      referenceDate: now,
    ).where((s) => targetUuids.contains(s.animalUuid)).toList(growable: false);
    final healthSeeds = _seedHealthRecords(
      referenceDate: now,
    ).where((s) => targetUuids.contains(s.animalUuid)).toList(growable: false);
    final productionSeeds = _seedProductionRecords(
      referenceDate: now,
    ).where((s) => targetUuids.contains(s.animalUuid)).toList(growable: false);
    final movementSeeds = _seedMovementRecords(
      referenceDate: now,
    ).where((s) => targetUuids.contains(s.animalUuid)).toList(growable: false);
    final commercialSeeds = _seedCommercialRecords(
      referenceDate: now,
    ).where((s) => targetUuids.contains(s.animalUuid)).toList(growable: false);

    await isar.writeTxn(() async {
      await isar.isarAnimals.putAll(
        missingAnimals.map((e) => e.toIsar()).toList(growable: false),
      );
      if (weightSeeds.isNotEmpty) {
        await isar.isarWeightRecords.putAll(
          weightSeeds
              .map((s) => s.record.toIsar(s.animalUuid))
              .toList(growable: false),
        );
      }
      if (reproSeeds.isNotEmpty) {
        await isar.isarReproductionRecords.putAll(
          reproSeeds
              .map((s) => s.record.toIsar(s.animalUuid))
              .toList(growable: false),
        );
      }
      if (healthSeeds.isNotEmpty) {
        await isar.isarHealthRecords.putAll(
          healthSeeds
              .map((s) => s.record.toIsar(s.animalUuid))
              .toList(growable: false),
        );
      }
      if (productionSeeds.isNotEmpty) {
        await isar.isarProductionRecords.putAll(
          productionSeeds
              .map((s) => s.record.toIsar(s.animalUuid))
              .toList(growable: false),
        );
      }
      if (movementSeeds.isNotEmpty) {
        await isar.isarMovementRecords.putAll(
          movementSeeds
              .map((s) => s.record.toIsar(s.animalUuid))
              .toList(growable: false),
        );
      }
      if (commercialSeeds.isNotEmpty) {
        await isar.isarCommercialRecords.putAll(
          commercialSeeds
              .map((s) => s.record.toIsar(s.animalUuid))
              .toList(growable: false),
        );
      }
    });
  }

  List<AnimalEntity> _seedAnimals({required DateTime referenceDate}) {
    return [
      _buildSeedAnimal(
        uuid: 'uuid-bessie',
        earTagNumber: 'A-100',
        visualId: 'Bessie',
        species: Species.cattle,
        sex: Sex.female,
        breed: 'Holstein',
        birthDate: DateTime(
          referenceDate.year - 5,
          referenceDate.month - 2,
          15,
        ),
        category: Category.cow,
        productionPurpose: ProductionPurpose.dairy,
        reproductiveStatus: ReproductiveStatus.lactating,
        paddockId: 'potrero-a',
        riskLevel: RiskLevel.low,
        bodyConditionScore: 6,
        lastMovementDate: referenceDate.subtract(const Duration(days: 3)),
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-rosario',
        earTagNumber: 'B-210',
        visualId: 'Rosario',
        species: Species.cattle,
        sex: Sex.female,
        breed: 'Angus',
        birthDate: DateTime(
          referenceDate.year - 1,
          referenceDate.month - 6,
          20,
        ),
        category: Category.heifer,
        productionPurpose: ProductionPurpose.meat,
        reproductiveStatus: ReproductiveStatus.virgin,
        paddockId: 'potrero-b',
        hasChronicIssues: true,
        chronicNotes: 'Cojea levemente en pata derecha',
        underObservation: true,
        requiresAttention: true,
        riskLevel: RiskLevel.medium,
        lastMovementDate: referenceDate.subtract(const Duration(days: 12)),
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-mateo',
        earTagNumber: 'C-055',
        visualId: 'Mateo',
        species: Species.cattle,
        sex: Sex.male,
        breed: 'Brahman',
        birthDate: DateTime(
          referenceDate.year - 4,
          referenceDate.month - 1,
          10,
        ),
        category: Category.bull,
        productionPurpose: ProductionPurpose.breeding,
        reproductiveStatus: ReproductiveStatus.active,
        paddockId: 'potrero-c',
        riskLevel: RiskLevel.low,
        dailyGainEstimate: 0.9,
        lastMovementDate: referenceDate.subtract(const Duration(days: 6)),
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-lola',
        earTagNumber: 'D-330',
        visualId: 'Lola',
        species: Species.cattle,
        sex: Sex.female,
        breed: 'Jersey',
        birthDate: DateTime(referenceDate.year - 3, referenceDate.month - 4, 5),
        category: Category.cow,
        productionPurpose: ProductionPurpose.dairy,
        reproductiveStatus: ReproductiveStatus.pregnant,
        expectedCalvingDate: referenceDate.add(const Duration(days: 120)),
        paddockId: 'potrero-a',
        riskLevel: RiskLevel.medium,
        underObservation: true,
        bodyConditionScore: 5,
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-nina',
        earTagNumber: 'E-015',
        visualId: 'Nina',
        species: Species.cattle,
        sex: Sex.female,
        breed: 'Gyr',
        birthDate: DateTime(referenceDate.year, referenceDate.month - 7, 1),
        category: Category.calf,
        productionPurpose: ProductionPurpose.dual,
        reproductiveStatus: ReproductiveStatus.virgin,
        paddockId: 'corral-crias',
        dailyGainEstimate: 0.5,
        riskLevel: RiskLevel.low,
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-roco',
        earTagNumber: 'E-016',
        visualId: 'Roco',
        species: Species.cattle,
        sex: Sex.male,
        breed: 'Gyr',
        birthDate: DateTime(referenceDate.year, referenceDate.month - 4, 18),
        category: Category.calf,
        productionPurpose: ProductionPurpose.meat,
        paddockId: 'corral-crias',
        dailyGainEstimate: 0.55,
        riskLevel: RiskLevel.low,
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-gaia',
        earTagNumber: 'F-401',
        visualId: 'Gaia',
        species: Species.cattle,
        sex: Sex.female,
        breed: 'Holstein x Jersey',
        birthDate: DateTime(
          referenceDate.year - 6,
          referenceDate.month - 3,
          12,
        ),
        category: Category.cow,
        productionPurpose: ProductionPurpose.dairy,
        reproductiveStatus: ReproductiveStatus.active,
        paddockId: 'potrero-d',
        riskLevel: RiskLevel.high,
        underObservation: true,
        requiresAttention: true,
        healthStatus: HealthStatus.poor,
        bodyConditionScore: 4,
        dailyGainEstimate: 0.35,
        feedType: 'Pasto + silo',
        lastMovementDate: referenceDate.subtract(const Duration(days: 2)),
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-tango',
        earTagNumber: 'G-178',
        visualId: 'Tango',
        species: Species.cattle,
        sex: Sex.male,
        breed: 'Angus',
        birthDate: DateTime(
          referenceDate.year - 2,
          referenceDate.month - 5,
          25,
        ),
        category: Category.steer,
        productionPurpose: ProductionPurpose.meat,
        reproductiveStatus: ReproductiveStatus.neutered,
        paddockId: 'feedlot-1',
        riskLevel: RiskLevel.medium,
        dailyGainEstimate: 1.1,
        feedType: 'Ración feedlot',
        bodyConditionScore: 7,
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-pampa',
        earTagNumber: 'H-201',
        visualId: 'Pampa',
        species: Species.cattle,
        sex: Sex.female,
        breed: 'Hereford',
        birthDate: DateTime(
          referenceDate.year - 2,
          referenceDate.month - 3,
          11,
        ),
        category: Category.heifer,
        productionPurpose: ProductionPurpose.meat,
        reproductiveStatus: ReproductiveStatus.pregnant,
        expectedCalvingDate: referenceDate.add(const Duration(days: 170)),
        paddockId: 'potrero-b',
        vaccinated: false,
        underObservation: true,
        requiresAttention: true,
        riskLevel: RiskLevel.medium,
        bodyConditionScore: 6,
        dailyGainEstimate: 0.8,
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-lucero',
        earTagNumber: 'H-350',
        visualId: 'Lucero',
        species: Species.cattle,
        sex: Sex.male,
        breed: 'Charolais',
        birthDate: DateTime(referenceDate.year - 4, referenceDate.month - 2, 4),
        category: Category.bull,
        productionPurpose: ProductionPurpose.breeding,
        reproductiveStatus: ReproductiveStatus.active,
        paddockId: 'potrero-c',
        riskLevel: RiskLevel.low,
        dailyGainEstimate: 1.0,
        lastMovementDate: referenceDate.subtract(const Duration(days: 8)),
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-estrella',
        earTagNumber: 'I-010',
        visualId: 'Estrella',
        species: Species.cattle,
        sex: Sex.female,
        breed: 'Holstein',
        birthDate: DateTime(referenceDate.year - 4, referenceDate.month - 8, 7),
        category: Category.cow,
        productionPurpose: ProductionPurpose.dairy,
        reproductiveStatus: ReproductiveStatus.lactating,
        paddockId: 'potrero-a',
        healthStatus: HealthStatus.excellent,
        riskLevel: RiskLevel.low,
        feedType: 'Pasto y concentrado',
        bodyConditionScore: 7,
        lastMovementDate: referenceDate.subtract(const Duration(days: 1)),
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-aurora',
        earTagNumber: 'I-011',
        visualId: 'Aurora',
        species: Species.cattle,
        sex: Sex.female,
        breed: 'Simmental',
        birthDate: DateTime(
          referenceDate.year - 3,
          referenceDate.month - 9,
          16,
        ),
        category: Category.heifer,
        productionPurpose: ProductionPurpose.breeding,
        reproductiveStatus: ReproductiveStatus.pregnant,
        expectedCalvingDate: referenceDate.add(const Duration(days: 190)),
        paddockId: 'potrero-d',
        riskLevel: RiskLevel.medium,
        underObservation: true,
        bodyConditionScore: 6,
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-brisa',
        earTagNumber: 'J-077',
        visualId: 'Brisa',
        species: Species.cattle,
        sex: Sex.female,
        breed: 'Beefmaster',
        birthDate: DateTime(referenceDate.year, referenceDate.month - 5, 2),
        category: Category.calf,
        productionPurpose: ProductionPurpose.dual,
        reproductiveStatus: ReproductiveStatus.virgin,
        paddockId: 'corral-crias',
        underObservation: true,
        riskLevel: RiskLevel.medium,
        dailyGainEstimate: 0.48,
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-zenon',
        earTagNumber: 'K-220',
        visualId: 'Zenon',
        species: Species.cattle,
        sex: Sex.male,
        breed: 'Criollo',
        birthDate: DateTime(referenceDate.year - 7, referenceDate.month - 1, 3),
        category: Category.oxen,
        productionPurpose: ProductionPurpose.work,
        reproductiveStatus: ReproductiveStatus.retired,
        paddockId: 'rancho-trabajo',
        riskLevel: RiskLevel.low,
        bodyConditionScore: 5,
        lastMovementDate: referenceDate.subtract(const Duration(days: 30)),
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-campero',
        earTagNumber: 'L-031',
        visualId: 'Campero',
        species: Species.goat,
        sex: Sex.male,
        breed: 'Boer',
        birthDate: DateTime(referenceDate.year - 3, referenceDate.month - 5, 4),
        category: Category.other,
        productionPurpose: ProductionPurpose.meat,
        reproductiveStatus: ReproductiveStatus.active,
        paddockId: 'potrero-c',
        riskLevel: RiskLevel.low,
        dailyGainEstimate: 0.4,
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-lira',
        earTagNumber: 'L-032',
        visualId: 'Lira',
        species: Species.goat,
        sex: Sex.female,
        breed: 'Alpina',
        birthDate: DateTime(
          referenceDate.year - 2,
          referenceDate.month - 7,
          16,
        ),
        category: Category.other,
        productionPurpose: ProductionPurpose.dual,
        reproductiveStatus: ReproductiveStatus.pregnant,
        expectedCalvingDate: referenceDate.add(const Duration(days: 110)),
        paddockId: 'potrero-c',
        riskLevel: RiskLevel.medium,
        bodyConditionScore: 6,
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-oveja-llanura',
        earTagNumber: 'M-014',
        visualId: 'Llanura',
        species: Species.sheep,
        sex: Sex.female,
        breed: 'Dorper',
        birthDate: DateTime(referenceDate.year - 3, referenceDate.month - 2, 9),
        category: Category.other,
        productionPurpose: ProductionPurpose.dual,
        reproductiveStatus: ReproductiveStatus.pregnant,
        expectedCalvingDate: referenceDate.add(const Duration(days: 100)),
        paddockId: 'potrero-b',
        vaccinated: false,
        riskLevel: RiskLevel.low,
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-carnero',
        earTagNumber: 'M-099',
        visualId: 'Carnero',
        species: Species.sheep,
        sex: Sex.male,
        breed: 'Katahdin',
        birthDate: DateTime(
          referenceDate.year - 4,
          referenceDate.month - 6,
          21,
        ),
        category: Category.other,
        productionPurpose: ProductionPurpose.breeding,
        reproductiveStatus: ReproductiveStatus.active,
        paddockId: 'potrero-b',
        riskLevel: RiskLevel.medium,
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-cerdita',
        earTagNumber: 'P-040',
        visualId: 'Luna',
        species: Species.pig,
        sex: Sex.female,
        breed: 'Large White',
        birthDate: DateTime(
          referenceDate.year - 2,
          referenceDate.month - 1,
          30,
        ),
        category: Category.other,
        productionPurpose: ProductionPurpose.meat,
        reproductiveStatus: ReproductiveStatus.pregnant,
        expectedCalvingDate: referenceDate.add(const Duration(days: 90)),
        paddockId: 'feedlot-1',
        feedType: 'Ración gestación',
        riskLevel: RiskLevel.medium,
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-lechon',
        earTagNumber: 'P-041',
        visualId: 'Chispa',
        species: Species.pig,
        sex: Sex.male,
        breed: 'Duroc',
        birthDate: DateTime(referenceDate.year, referenceDate.month - 2, 1),
        category: Category.weaned,
        productionPurpose: ProductionPurpose.meat,
        reproductiveStatus: ReproductiveStatus.virgin,
        paddockId: 'corral-crias',
        dailyGainEstimate: 0.6,
        riskLevel: RiskLevel.low,
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-potro',
        earTagNumber: 'Q-020',
        visualId: 'Trote',
        species: Species.equine,
        sex: Sex.male,
        breed: 'Criollo',
        birthDate: DateTime(referenceDate.year - 5, referenceDate.month - 3, 8),
        category: Category.other,
        productionPurpose: ProductionPurpose.work,
        reproductiveStatus: ReproductiveStatus.active,
        paddockId: 'rancho-trabajo',
        riskLevel: RiskLevel.low,
        bodyConditionScore: 6,
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-gallina',
        earTagNumber: 'A-901',
        visualId: 'Gallina Blanca',
        species: Species.poultry,
        sex: Sex.female,
        breed: 'Leghorn',
        birthDate: DateTime(
          referenceDate.year - 1,
          referenceDate.month - 4,
          14,
        ),
        category: Category.other,
        productionPurpose: ProductionPurpose.other,
        reproductiveStatus: ReproductiveStatus.active,
        paddockId: 'gallinero-central',
        riskLevel: RiskLevel.low,
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-pato',
        earTagNumber: 'A-902',
        visualId: 'Pato Azul',
        species: Species.poultry,
        sex: Sex.male,
        breed: 'Pekin',
        birthDate: DateTime(referenceDate.year - 1, referenceDate.month - 1, 3),
        category: Category.other,
        productionPurpose: ProductionPurpose.other,
        reproductiveStatus: ReproductiveStatus.active,
        paddockId: 'gallinero-central',
        riskLevel: RiskLevel.low,
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-yaku',
        earTagNumber: 'R-501',
        visualId: 'Yaku',
        species: Species.other,
        sex: Sex.male,
        breed: 'Búfalo de agua',
        birthDate: DateTime(
          referenceDate.year - 6,
          referenceDate.month - 6,
          19,
        ),
        category: Category.bull,
        productionPurpose: ProductionPurpose.meat,
        reproductiveStatus: ReproductiveStatus.active,
        paddockId: 'potrero-d',
        riskLevel: RiskLevel.medium,
        bodyConditionScore: 6,
        referenceDate: referenceDate,
      ),
      _buildSeedAnimal(
        uuid: 'uuid-trueno',
        earTagNumber: 'S-080',
        visualId: 'Trueno',
        species: Species.cattle,
        sex: Sex.male,
        breed: 'Angus Negro',
        birthDate: DateTime(
          referenceDate.year - 1,
          referenceDate.month - 10,
          27,
        ),
        category: Category.steer,
        productionPurpose: ProductionPurpose.meat,
        reproductiveStatus: ReproductiveStatus.neutered,
        paddockId: 'feedlot-1',
        riskLevel: RiskLevel.medium,
        dailyGainEstimate: 1.2,
        feedType: 'Ración terminación',
        bodyConditionScore: 6,
        underObservation: true,
        referenceDate: referenceDate,
      ),
    ];
  }

  List<_WeightSeed> _seedWeightRecords({required DateTime referenceDate}) {
    return [
      _WeightSeed(
        'uuid-bessie',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 60)),
          weight: 620,
          method: WeightMethod.scale,
          notes: 'Post-parto',
          measuredBy: 'Juan',
        ),
      ),
      _WeightSeed(
        'uuid-bessie',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 20)),
          weight: 635,
          method: WeightMethod.scale,
          notes: 'Buena condición',
        ),
      ),
      _WeightSeed(
        'uuid-mateo',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 45)),
          weight: 820,
          method: WeightMethod.scale,
          notes: 'Revisión anual',
        ),
      ),
      _WeightSeed(
        'uuid-mateo',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 5)),
          weight: 845,
          method: WeightMethod.scale,
          notes: 'Previo a servicio',
        ),
      ),
      _WeightSeed(
        'uuid-nina',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 30)),
          weight: 118,
          method: WeightMethod.estimated,
          notes: 'Destete',
        ),
      ),
      _WeightSeed(
        'uuid-nina',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 7)),
          weight: 132,
          method: WeightMethod.scale,
          notes: 'Control semanal',
        ),
      ),
      _WeightSeed(
        'uuid-tango',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 25)),
          weight: 410,
          method: WeightMethod.scale,
          notes: 'Ingreso a feedlot',
        ),
      ),
      _WeightSeed(
        'uuid-tango',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 3)),
          weight: 436,
          method: WeightMethod.scale,
          notes: 'Control diario',
        ),
      ),
      _WeightSeed(
        'uuid-rosario',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 50)),
          weight: 360,
          method: WeightMethod.scale,
          notes: 'Pos destete',
        ),
      ),
      _WeightSeed(
        'uuid-rosario',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 5)),
          weight: 372,
          method: WeightMethod.scale,
          notes: 'Listo para servicio',
        ),
      ),
      _WeightSeed(
        'uuid-pampa',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 60)),
          weight: 455,
          method: WeightMethod.scale,
          notes: 'Chequeo pre-gestación',
        ),
      ),
      _WeightSeed(
        'uuid-pampa',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 10)),
          weight: 470,
          method: WeightMethod.scale,
          notes: 'Seguimiento ganancia',
        ),
      ),
      _WeightSeed(
        'uuid-estrella',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 14)),
          weight: 545,
          method: WeightMethod.scale,
          notes: 'Control ordeño',
        ),
      ),
      _WeightSeed(
        'uuid-aurora',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 25)),
          weight: 420,
          method: WeightMethod.scale,
          notes: 'Chequeo prenatal',
        ),
      ),
      _WeightSeed(
        'uuid-lira',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 30)),
          weight: 62,
          method: WeightMethod.scale,
          notes: 'Control caprino',
        ),
      ),
      _WeightSeed(
        'uuid-campero',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 35)),
          weight: 70,
          method: WeightMethod.scale,
          notes: 'Limpieza pezuñas',
        ),
      ),
      _WeightSeed(
        'uuid-oveja-llanura',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 28)),
          weight: 56,
          method: WeightMethod.scale,
          notes: 'Pre servicio',
        ),
      ),
      _WeightSeed(
        'uuid-cerdita',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 18)),
          weight: 185,
          method: WeightMethod.scale,
          notes: 'Control gestación',
        ),
      ),
      _WeightSeed(
        'uuid-trueno',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 20)),
          weight: 480,
          method: WeightMethod.scale,
          notes: 'Ingreso al corral de terminación',
        ),
      ),
      _WeightSeed(
        'uuid-trueno',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 4)),
          weight: 505,
          method: WeightMethod.scale,
          notes: 'Proyección de venta',
        ),
      ),
      _WeightSeed(
        'uuid-potro',
        WeightRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 40)),
          weight: 395,
          method: WeightMethod.estimated,
          notes: 'Control herrado',
        ),
      ),
    ];
  }

  List<_ReproSeed> _seedReproductionRecords({required DateTime referenceDate}) {
    return [
      _ReproSeed(
        'uuid-bessie',
        ReproductionRecord(
          id: null,
          serviceDate: referenceDate.subtract(const Duration(days: 320)),
          serviceType: ServiceType.naturalService,
          maleSireIdentifier: 'Toro Bravo-21',
          expectedCalvingDate: referenceDate.subtract(const Duration(days: 20)),
          actualCalvingDate: referenceDate.subtract(const Duration(days: 22)),
          calvingResult: 'Ternero sano',
          notes: 'Parto asistido leve',
        ),
      ),
      _ReproSeed(
        'uuid-lola',
        ReproductionRecord(
          id: null,
          serviceDate: referenceDate.subtract(const Duration(days: 70)),
          serviceType: ServiceType.artificialInsemination,
          maleSireIdentifier: 'AI-Dorado-55',
          expectedCalvingDate: referenceDate.add(const Duration(days: 190)),
          notes: 'Inseminación con pajuelas importadas',
          pregnancyCheckDate: referenceDate.subtract(const Duration(days: 40)),
          pregnancyResult: PregnancyCheckResult.positive,
        ),
      ),
      _ReproSeed(
        'uuid-gaia',
        ReproductionRecord(
          id: null,
          serviceDate: referenceDate.subtract(const Duration(days: 40)),
          serviceType: ServiceType.naturalService,
          maleSireIdentifier: 'Toro Angus-Rojo',
          expectedCalvingDate: referenceDate.add(const Duration(days: 230)),
          notes: 'Condición corporal baja, vigilar',
        ),
      ),
      _ReproSeed(
        'uuid-pampa',
        ReproductionRecord(
          id: null,
          serviceDate: referenceDate.subtract(const Duration(days: 110)),
          serviceType: ServiceType.naturalService,
          maleSireIdentifier: 'Toro Caramelo',
          pregnancyCheckDate: referenceDate.subtract(const Duration(days: 45)),
          pregnancyResult: PregnancyCheckResult.positive,
          expectedCalvingDate: referenceDate.add(const Duration(days: 170)),
          notes: 'Hembra primeriza, plan de observación',
        ),
      ),
      _ReproSeed(
        'uuid-estrella',
        ReproductionRecord(
          id: null,
          serviceDate: referenceDate.subtract(const Duration(days: 310)),
          serviceType: ServiceType.naturalService,
          maleSireIdentifier: 'Toro Lechero-08',
          expectedCalvingDate: referenceDate.subtract(const Duration(days: 15)),
          actualCalvingDate: referenceDate.subtract(const Duration(days: 12)),
          calvingResult: 'Ternera sana',
          notes: 'Parto sin asistencia',
        ),
      ),
      _ReproSeed(
        'uuid-aurora',
        ReproductionRecord(
          id: null,
          serviceDate: referenceDate.subtract(const Duration(days: 90)),
          serviceType: ServiceType.artificialInsemination,
          maleSireIdentifier: 'AI-Euro-17',
          pregnancyCheckDate: referenceDate.subtract(const Duration(days: 40)),
          pregnancyResult: PregnancyCheckResult.positive,
          expectedCalvingDate: referenceDate.add(const Duration(days: 190)),
          notes: 'Gestación confirmada, seguimiento mensual',
        ),
      ),
      _ReproSeed(
        'uuid-lira',
        ReproductionRecord(
          id: null,
          serviceDate: referenceDate.subtract(const Duration(days: 45)),
          serviceType: ServiceType.naturalService,
          maleSireIdentifier: 'Macho-Alpha-01',
          pregnancyCheckDate: referenceDate.subtract(const Duration(days: 15)),
          pregnancyResult: PregnancyCheckResult.positive,
          expectedCalvingDate: referenceDate.add(const Duration(days: 110)),
          notes: 'Caprina gestante, revisar minerales',
        ),
      ),
      _ReproSeed(
        'uuid-oveja-llanura',
        ReproductionRecord(
          id: null,
          serviceDate: referenceDate.subtract(const Duration(days: 60)),
          serviceType: ServiceType.naturalService,
          maleSireIdentifier: 'Carnero-05',
          pregnancyCheckDate: referenceDate.subtract(const Duration(days: 25)),
          pregnancyResult: PregnancyCheckResult.positive,
          expectedCalvingDate: referenceDate.add(const Duration(days: 100)),
          notes: 'Condición 3.0, plan mineral',
        ),
      ),
      _ReproSeed(
        'uuid-cerdita',
        ReproductionRecord(
          id: null,
          serviceDate: referenceDate.subtract(const Duration(days: 25)),
          serviceType: ServiceType.naturalService,
          maleSireIdentifier: 'Verraco-12',
          pregnancyCheckDate: referenceDate.subtract(const Duration(days: 5)),
          pregnancyResult: PregnancyCheckResult.positive,
          expectedCalvingDate: referenceDate.add(const Duration(days: 90)),
          notes: 'Gestación por confirmar con eco en 15 días',
        ),
      ),
    ];
  }

  List<_HealthSeed> _seedHealthRecords({required DateTime referenceDate}) {
    return [
      _HealthSeed(
        'uuid-bessie',
        HealthRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 60)),
          type: HealthRecordType.vaccine,
          product: 'Fiebre Aftosa',
          dose: '5 ml',
          appliedBy: 'Dr. Gómez',
          nextDueDate: referenceDate.add(const Duration(days: 305)),
        ),
      ),
      _HealthSeed(
        'uuid-rosario',
        HealthRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 10)),
          type: HealthRecordType.treatment,
          product: 'Antibiótico largo',
          dose: '10 ml',
          appliedBy: 'Aux. Marta',
          notes: 'Chequeo cojeras',
          nextDueDate: referenceDate.add(const Duration(days: 20)),
        ),
      ),
      _HealthSeed(
        'uuid-gaia',
        HealthRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 15)),
          type: HealthRecordType.disease,
          product: 'Diagnóstico cetosis',
          notes: 'Ración energética y monitoreo',
          nextDueDate: referenceDate.add(const Duration(days: 7)),
        ),
      ),
      _HealthSeed(
        'uuid-tango',
        HealthRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 25)),
          type: HealthRecordType.deworming,
          product: 'Ivermectina 1%',
          dose: '1 ml/50kg',
          nextDueDate: referenceDate.add(const Duration(days: 60)),
        ),
      ),
      _HealthSeed(
        'uuid-pampa',
        HealthRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 5)),
          type: HealthRecordType.vaccine,
          product: 'Clostridiales',
          dose: '2 ml',
          appliedBy: 'Dr. Gómez',
          notes: 'Refuerzo, revisar reacción',
          nextDueDate: referenceDate.add(const Duration(days: 365)),
        ),
      ),
      _HealthSeed(
        'uuid-estrella',
        HealthRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 8)),
          type: HealthRecordType.tickBath,
          product: 'Baño garrapaticida',
          notes: 'Aplicar cada 21 días',
          nextDueDate: referenceDate.add(const Duration(days: 13)),
        ),
      ),
      _HealthSeed(
        'uuid-aurora',
        HealthRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 12)),
          type: HealthRecordType.vitamins,
          product: 'Complejo B + Selenio',
          notes: 'Gestante, repetir en 30 días',
          nextDueDate: referenceDate.add(const Duration(days: 18)),
        ),
      ),
      _HealthSeed(
        'uuid-lira',
        HealthRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 30)),
          type: HealthRecordType.vaccine,
          product: 'Enterotoxemia caprina',
          notes: 'Refuerzo anual',
          nextDueDate: referenceDate.add(const Duration(days: 210)),
        ),
      ),
      _HealthSeed(
        'uuid-cerdita',
        HealthRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 14)),
          type: HealthRecordType.treatment,
          product: 'Tratamiento mastitis',
          notes: 'Aplicar linimento 3 días',
          nextDueDate: referenceDate.add(const Duration(days: 15)),
        ),
      ),
      _HealthSeed(
        'uuid-trueno',
        HealthRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 18)),
          type: HealthRecordType.deworming,
          product: 'Levamisol',
          notes: 'Control parásitos internos',
          nextDueDate: referenceDate.add(const Duration(days: 40)),
        ),
      ),
      _HealthSeed(
        'uuid-nina',
        HealthRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 6)),
          type: HealthRecordType.vitamins,
          product: 'Vitaminas A-D-E',
          notes: 'Refuerzo tras destete',
        ),
      ),
      _HealthSeed(
        'uuid-yaku',
        HealthRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 3)),
          type: HealthRecordType.checkup,
          product: 'Chequeo general búfalo',
          notes: 'Sin hallazgos, repetir en 6 meses',
          nextDueDate: referenceDate.add(const Duration(days: 180)),
        ),
      ),
      _HealthSeed(
        'uuid-oveja-llanura',
        HealthRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 20)),
          type: HealthRecordType.vaccine,
          product: 'Brucelosis ovina',
          notes: 'Pendiente refuerzo',
          nextDueDate: referenceDate.add(const Duration(days: 200)),
        ),
      ),
    ];
  }

  List<_ProductionSeed> _seedProductionRecords({
    required DateTime referenceDate,
  }) {
    return [
      _ProductionSeed(
        'uuid-bessie',
        ProductionRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 2)),
          type: ProductionRecordType.production,
          value: 28,
          unit: 'L',
          notes: 'Ordeño de la mañana',
        ),
      ),
      _ProductionSeed(
        'uuid-estrella',
        ProductionRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 1)),
          type: ProductionRecordType.production,
          value: 31,
          unit: 'L',
          notes: 'Pico de lactancia',
        ),
      ),
      _ProductionSeed(
        'uuid-tango',
        ProductionRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 3)),
          type: ProductionRecordType.bodyConditionScore,
          score: 7,
          notes: 'Buen estado en feedlot',
        ),
      ),
      _ProductionSeed(
        'uuid-trueno',
        ProductionRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 4)),
          type: ProductionRecordType.weightGain,
          value: 1.8,
          unit: 'kg/día',
          notes: 'Ganancia diaria promedio',
        ),
      ),
      _ProductionSeed(
        'uuid-rosario',
        ProductionRecord(
          id: null,
          date: referenceDate.add(const Duration(days: 5)),
          type: ProductionRecordType.weighing,
          notes: 'Programado pesaje post destete',
        ),
      ),
      _ProductionSeed(
        'uuid-pampa',
        ProductionRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 30)),
          type: ProductionRecordType.fatteningStart,
          notes: 'Inicio engorde a pastoreo',
        ),
      ),
      _ProductionSeed(
        'uuid-aurora',
        ProductionRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 7)),
          type: ProductionRecordType.weighing,
          value: 418,
          unit: 'kg',
          notes: 'Control gestación 2º trimestre',
        ),
      ),
      _ProductionSeed(
        'uuid-lira',
        ProductionRecord(
          id: null,
          date: referenceDate.add(const Duration(days: 10)),
          type: ProductionRecordType.weighing,
          notes: 'Programar pre-parto caprino',
        ),
      ),
      _ProductionSeed(
        'uuid-cerdita',
        ProductionRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 6)),
          type: ProductionRecordType.production,
          value: 6.5,
          unit: 'kg alimento',
          notes: 'Consumo diario gestante',
        ),
      ),
      _ProductionSeed(
        'uuid-oveja-llanura',
        ProductionRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 12)),
          type: ProductionRecordType.production,
          value: 2.3,
          unit: 'kg lana',
          notes: 'Esquila previa',
        ),
      ),
      _ProductionSeed(
        'uuid-campero',
        ProductionRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 9)),
          type: ProductionRecordType.bodyConditionScore,
          score: 5,
          notes: 'Caprino en rotación',
        ),
      ),
    ];
  }

  List<_MovementSeed> _seedMovementRecords({required DateTime referenceDate}) {
    return [
      _MovementSeed(
        'uuid-rosario',
        MovementRecord(
          id: null,
          fromLocation: 'corral-crias',
          toLocation: 'potrero-b',
          date: referenceDate.subtract(const Duration(days: 15)),
          reason: MovementReason.paddockRotation,
          notes: 'Salió de recría a potrero',
        ),
      ),
      _MovementSeed(
        'uuid-bessie',
        MovementRecord(
          id: null,
          fromLocation: 'potrero-b',
          toLocation: 'potrero-a',
          date: referenceDate.subtract(const Duration(days: 8)),
          reason: MovementReason.paddockRotation,
        ),
      ),
      _MovementSeed(
        'uuid-tango',
        MovementRecord(
          id: null,
          fromLocation: 'potrero-b',
          toLocation: 'feedlot-1',
          date: referenceDate.subtract(const Duration(days: 20)),
          reason: MovementReason.feeding,
          notes: 'Ingreso a terminación',
        ),
      ),
      _MovementSeed(
        'uuid-mateo',
        MovementRecord(
          id: null,
          fromLocation: 'potrero-a',
          toLocation: 'potrero-c',
          date: referenceDate.subtract(const Duration(days: 12)),
          reason: MovementReason.breeding,
          notes: 'Servicio natural',
        ),
      ),
      _MovementSeed(
        'uuid-potro',
        MovementRecord(
          id: null,
          fromLocation: 'potrero-d',
          toLocation: 'rancho-trabajo',
          date: referenceDate.subtract(const Duration(days: 6)),
          reason: MovementReason.other,
          notes: 'Trabajo de soga',
        ),
      ),
      _MovementSeed(
        'uuid-campero',
        MovementRecord(
          id: null,
          fromLocation: 'potrero-c',
          toLocation: 'potrero-d',
          date: referenceDate.subtract(const Duration(days: 5)),
          reason: MovementReason.paddockRotation,
          notes: 'Rotación caprinos',
        ),
      ),
    ];
  }

  List<_CommercialSeed> _seedCommercialRecords({
    required DateTime referenceDate,
  }) {
    return [
      _CommercialSeed(
        'uuid-bessie',
        CommercialRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 180)),
          type: CommercialRecordType.purchase,
          amount: 1500,
          currency: 'USD',
          counterparty: 'Rancho La Esperanza',
          notes: 'Compra lote lechero',
        ),
      ),
      _CommercialSeed(
        'uuid-tango',
        CommercialRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 120)),
          type: CommercialRecordType.purchase,
          amount: 900,
          currency: 'USD',
          counterparty: 'Proveedor feedlot',
          notes: 'Ingreso recría',
        ),
      ),
      _CommercialSeed(
        'uuid-trueno',
        CommercialRecord(
          id: null,
          date: referenceDate.add(const Duration(days: 30)),
          type: CommercialRecordType.sale,
          amount: 1800,
          currency: 'USD',
          counterparty: 'Frigorífico Central',
          notes: 'Venta programada',
        ),
      ),
      _CommercialSeed(
        'uuid-campero',
        CommercialRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 400)),
          type: CommercialRecordType.purchase,
          amount: 220,
          currency: 'USD',
          counterparty: 'Feria caprina',
          notes: 'Compra reproductor',
        ),
      ),
      _CommercialSeed(
        'uuid-cerdita',
        CommercialRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 200)),
          type: CommercialRecordType.purchase,
          amount: 350,
          currency: 'USD',
          counterparty: 'Granja Porcina',
          notes: 'Ingreso a pie de cría',
        ),
      ),
      _CommercialSeed(
        'uuid-yaku',
        CommercialRecord(
          id: null,
          date: referenceDate.subtract(const Duration(days: 60)),
          type: CommercialRecordType.ownershipChange,
          amount: 0,
          currency: 'USD',
          counterparty: 'Reclasificación interna',
          notes: 'Cambio de hato a búfalos',
        ),
      ),
    ];
  }

  AnimalEntity _buildSeedAnimal({
    required String uuid,
    required String earTagNumber,
    required String visualId,
    required Species species,
    required Sex sex,
    required String breed,
    required DateTime birthDate,
    required Category category,
    required ProductionPurpose productionPurpose,
    ProductionStage productionStage = ProductionStage.unknown,
    ProductionSystem productionSystem = ProductionSystem.unknown,
    ReproductiveStatus reproductiveStatus = ReproductiveStatus.virgin,
    HealthStatus healthStatus = HealthStatus.good,
    RiskLevel riskLevel = RiskLevel.low,
    bool vaccinated = true,
    bool dewormed = true,
    bool hasVitamins = true,
    bool hasChronicIssues = false,
    String? chronicNotes,
    bool underObservation = false,
    bool requiresAttention = false,
    String? paddockId,
    double? dailyGainEstimate,
    int bodyConditionScore = 5,
    String feedType = 'Pasto y concentrado',
    DateTime? lastMovementDate,
    DateTime? expectedCalvingDate,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final lifecycle = AnimalLifecycleCalculator.calculate(
      birthDate: birthDate,
      species: species,
      sex: sex,
      now: now,
    );

    return AnimalEntity(
      id: null,
      uuid: uuid,
      earTagNumber: earTagNumber,
      visualId: visualId,
      brand: null,
      rfidTag: null,
      species: species,
      category: category,
      lifeStage: lifecycle.lifeStage,
      sex: sex,
      breed: breed,
      birthDate: birthDate,
      ageMonths: lifecycle.ageMonths,
      sireUuid: null,
      damUuid: null,
      generation: 1,
      healthStatus: healthStatus,
      bodyConditionScore: bodyConditionScore,
      vaccinated: vaccinated,
      dewormed: dewormed,
      hasVitamins: hasVitamins,
      hasChronicIssues: hasChronicIssues,
      chronicNotes: chronicNotes,
      reproductiveStatus: reproductiveStatus,
      firstServiceDate: null,
      lastServiceDate: null,
      expectedCalvingDate: expectedCalvingDate,
      productionPurpose: productionPurpose,
      productionStage: productionStage,
      productionSystem: productionSystem,
      feedType: feedType,
      dailyGainEstimate: dailyGainEstimate,
      currentPaddockId: paddockId,
      lastMovementDate:
          lastMovementDate ?? now.subtract(const Duration(days: 10)),
      underObservation: underObservation,
      requiresAttention: requiresAttention,
      riskLevel: riskLevel,
      profilePhoto: null,
      gallery: const [],
      synced: false,
      remoteId: null,
      syncDate: null,
      contentHash: null,
      creationDate: birthDate,
      lastUpdateDate: now,
    );
  }
}

class _WeightSeed {
  _WeightSeed(this.animalUuid, this.record);
  final String animalUuid;
  final WeightRecord record;
}

class _ReproSeed {
  _ReproSeed(this.animalUuid, this.record);
  final String animalUuid;
  final ReproductionRecord record;
}

class _HealthSeed {
  _HealthSeed(this.animalUuid, this.record);
  final String animalUuid;
  final HealthRecord record;
}

class _ProductionSeed {
  _ProductionSeed(this.animalUuid, this.record);
  final String animalUuid;
  final ProductionRecord record;
}

class _MovementSeed {
  _MovementSeed(this.animalUuid, this.record);
  final String animalUuid;
  final MovementRecord record;
}

class _CommercialSeed {
  _CommercialSeed(this.animalUuid, this.record);
  final String animalUuid;
  final CommercialRecord record;
}
