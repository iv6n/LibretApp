/// features \u203a ubicaciones \u203a domain \u203a repositories \u203a location_repository \u2014 abstract LocationRepository port.
library;

import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
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
  Future<void> addSalt(String uuid, SaltRecord record);
  Future<void> addShade(String uuid, ShadeRecord record);
  Future<void> addPasture(String uuid, PastureRecord record);
  Future<void> addSeeding(String uuid, SeedingRecord record);
  Future<void> addIrrigation(String uuid, IrrigationRecord record);
  Future<void> addRain(String uuid, RainRecord record);
  Future<void> addCost(String uuid, CostRecord record);

  // Crop management
  Future<void> addCrop(String locationUuid, CropRecord crop);
  Future<void> updateCrop(String locationUuid, CropRecord crop);
  Future<void> deleteCrop(String locationUuid, String cropUuid);
  Future<void> addHarvest(
    String locationUuid,
    String cropUuid,
    HarvestRecord record,
  );
  Future<void> addCropWatering(
    String locationUuid,
    String cropUuid,
    CropWateringRecord record,
  );
  Future<void> addCropHealth(
    String locationUuid,
    String cropUuid,
    CropHealthRecord record,
  );
  Future<void> addCropTask(String locationUuid, String cropUuid, CropTask task);
  Future<void> completeCropTask(
    String locationUuid,
    String cropUuid,
    String taskUuid,
  );
}
