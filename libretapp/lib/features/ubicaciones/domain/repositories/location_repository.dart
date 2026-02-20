import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';

abstract class LocationRepository {
  Stream<List<LocationEntity>> watchAll();
  Future<List<LocationEntity>> getAll();
  Future<LocationEntity?> getByUuid(String uuid);
  Future<void> upsert(LocationEntity location);
  Future<void> deleteByUuid(String uuid);
  Future<void> addVisit(String uuid, VisitRecord record);
  Future<void> addWater(String uuid, WaterRecord record);
  Future<void> addPasture(String uuid, PastureRecord record);
  Future<void> addSeeding(String uuid, SeedingRecord record);
  Future<void> addIrrigation(String uuid, IrrigationRecord record);
  Future<void> addRain(String uuid, RainRecord record);
  Future<void> addCost(String uuid, CostRecord record);
}
