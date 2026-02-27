import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/production_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';

/// Contrato para la persistencia y acceso de datos de animales.
abstract class AnimalRepository {
  Stream<List<AnimalEntity>> watchAll();
  Future<bool> refreshFromRemote({bool force = false});
  Future<List<AnimalEntity>> getAll();
  Future<AnimalEntity?> getByUuid(String uuid);
  Future<List<AnimalEntity>> getBySpecies(String speciesName);
  Future<List<AnimalEntity>> getByPaddock(String paddockId);
  Future<List<AnimalEntity>> getAnimalsRequiringAttention();
  Future<List<AnimalEntity>> getUnsynchronized();
  Future<AnimalEntity> save(AnimalEntity animal);
  Future<AnimalEntity> update(AnimalEntity animal);
  Future<void> markAsSynced(String uuid, String remoteId);
  Future<void> markAsUnsynchronized(String uuid);
  Future<void> delete(String uuid);
  Future<void> clearAll();
  Future<int> count();
  Future<Map<String, dynamic>> getStatistics();

  // Pesos
  Future<List<WeightRecord>> getWeightRecords(String animalUuid);
  Future<WeightRecord> addWeightRecord(String animalUuid, WeightRecord record);
  Future<void> deleteWeightRecord(String recordId);

  // Producción
  Future<List<ProductionRecord>> getProductionRecords(String animalUuid);
  Future<ProductionRecord> addProductionRecord(
    String animalUuid,
    ProductionRecord record,
  );
  Future<void> deleteProductionRecord(String recordId);

  // Salud
  Future<List<HealthRecord>> getHealthRecords(String animalUuid);
  Future<HealthRecord> addHealthRecord(String animalUuid, HealthRecord record);
  Future<void> deleteHealthRecord(String recordId);

  // Comercial
  Future<List<CommercialRecord>> getCommercialRecords(String animalUuid);
  Future<CommercialRecord> addCommercialRecord(
    String animalUuid,
    CommercialRecord record,
  );
  Future<void> deleteCommercialRecord(String recordId);

  // Movimientos
  Future<List<MovementRecord>> getMovementRecords(String animalUuid);
  Future<MovementRecord> addMovementRecord(
    String animalUuid,
    MovementRecord record,
  );
  Future<void> deleteMovementRecord(String recordId);

  // Costos
  Future<List<CostRecord>> getCostRecords(String animalUuid);
  Future<CostRecord> addCostRecord(String animalUuid, CostRecord record);
  Future<void> deleteCostRecord(String recordId);

  // Reproducción
  Future<List<ReproductionRecord>> getReproductionRecords(String animalUuid);
  Future<ReproductionRecord> addReproductionRecord(
    String animalUuid,
    ReproductionRecord record,
  );
  Future<void> deleteReproductionRecord(String recordId);
}
