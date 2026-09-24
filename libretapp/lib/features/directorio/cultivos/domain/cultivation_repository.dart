/// Persistence port for independent cultivation records.
library;

import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';

abstract class CultivationRepository {
  Stream<List<CultivationEntity>> watchAll({bool includeArchived = false});
  Stream<List<CultivationEntity>> watchByLocation(
    String locationUuid, {
    bool includeArchived = false,
  });
  Future<List<CultivationEntity>> getAll({bool includeArchived = false});
  Future<CultivationEntity?> getByUuid(String uuid);
  Future<void> upsert(CultivationEntity cultivation);
  Future<void> archive(String uuid);
  Future<void> purge(String uuid);
  Future<void> addHarvest(String uuid, HarvestRecord record);
  Future<void> addWatering(String uuid, CropWateringRecord record);
  Future<void> addHealth(String uuid, CropHealthRecord record);
  Future<void> addTask(String uuid, CropTask task);
  Future<void> completeTask(String uuid, String taskUuid);
}
