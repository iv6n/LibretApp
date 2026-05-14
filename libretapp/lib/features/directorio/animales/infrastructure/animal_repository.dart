/// features › directorio › animales › infrastructure › animal_repository — abstract AnimalRepository port.
library;

import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';

/// Contrato para la persistencia y acceso de datos de animales.
abstract class AnimalRepository {
  Stream<List<AnimalEntity>> watchAll();
  Stream<void> watchChanges();
  Future<bool> refreshFromRemote({bool force = false});
  Future<List<AnimalEntity>> getAll();
  Future<List<AnimalEntity>> getPage({required int offset, required int limit});
  Future<AnimalEntity?> getByUuid(String uuid);
  Future<List<AnimalEntity>> getBySpecies(String speciesName);
  Future<List<AnimalEntity>> getByPaddock(String paddockId);
  Future<List<AnimalEntity>> getByBatchUuid(String batchUuid);
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
}
