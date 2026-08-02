/// features › directorio › animales › infrastructure › animal_repository — abstract AnimalRepository port.
library;

import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/life_stage.dart';

/// Contrato para la persistencia y acceso de datos de animales.
abstract class AnimalRepository {
  Stream<List<AnimalEntity>> watchAll();
  Stream<void> watchChanges();
  Future<bool> refreshFromRemote({bool force = false});

  /// The active herd: excludes sold, dead and archived animals.
  Future<List<AnimalEntity>> getAll();

  /// Every animal ever recorded, whatever its status.
  ///
  /// Finance and history need this: the month you sell an animal is exactly
  /// the month its sale must appear, and filtering it out of the herd must not
  /// erase it from the books.
  Future<List<AnimalEntity>> getAllIncludingInactive();
  Future<List<AnimalEntity>> getPage({required int offset, required int limit});
  Future<AnimalEntity?> getByUuid(String uuid);
  Future<List<AnimalEntity>> getBySpecies(String speciesName);
  Future<List<AnimalEntity>> getByPaddock(String paddockId);
  Future<List<AnimalEntity>> getByBatchUuid(String batchUuid);

  /// Direct offspring of [parentUuid], matched against either parent. Backed
  /// by the `sireUuid`/`damUuid` indexes so walking a pedigree does not scan
  /// the whole collection at every node.
  Future<List<AnimalEntity>> getByParentUuid(String parentUuid);

  Future<List<AnimalEntity>> getAnimalsRequiringAttention();
  Future<List<AnimalEntity>> getUnsynchronized();

  /// Active-herd size broken down by life stage, counted in the database.
  ///
  /// The directory list loads in pages, so tallying the animals it currently
  /// holds would report "20 animales" until scrolling filled the rest in —
  /// and the per-stage chips alongside it would climb the same way. This
  /// answers for the whole herd no matter how much of it is on screen. Summing
  /// the values gives the herd total, since every active animal has exactly
  /// one life stage.
  Future<Map<LifeStage, int>> getActiveStageCounts();
  Future<AnimalEntity> save(AnimalEntity animal);
  Future<AnimalEntity> update(AnimalEntity animal);
  Future<void> markAsSynced(String uuid, String remoteId);
  Future<void> markAsUnsynchronized(String uuid);

  /// Takes the animal out of the directory by archiving it. The row stays:
  /// its genealogy, costs and history remain readable, and
  /// [getAllIncludingInactive] still returns it.
  Future<void> delete(String uuid);

  /// Erases the row outright, with no archived copy left behind.
  ///
  /// Deliberately distinct from [delete]: for a real animal, forgetting it
  /// ever existed is the wrong outcome — its calves would lose a parent and
  /// the books would lose a line. This exists for rows the app itself owns
  /// and can legitimately take back, such as tearing down the demo scenario.
  /// Child records are not cascaded; the caller decides their fate.
  Future<void> purge(String uuid);
  Future<void> clearAll();
  Future<int> count();
  Future<Map<String, dynamic>> getStatistics();
}
