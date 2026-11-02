/// Shared, workspace-scoped read model for animal directory data.
library;

import 'dart:async';

import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/life_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_purpose.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';

class AnimalDirectoryReadModel {
  AnimalDirectoryReadModel(Iterable<AnimalEntity> source)
    : animals = List.unmodifiable(source) {
    final stages = <LifeStage, int>{};
    final companionStages = <LifeStage, int>{};
    final taxonomy = <Species, Map<LifeStage, int>>{};
    for (final animal in animals) {
      stages.update(animal.lifeStage, (count) => count + 1, ifAbsent: () => 1);
      if (animal.productionPurpose == ProductionPurpose.companion) {
        companionStages.update(
          animal.lifeStage,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
      taxonomy
          .putIfAbsent(animal.species, () => <LifeStage, int>{})
          .update(animal.lifeStage, (count) => count + 1, ifAbsent: () => 1);
    }
    stageCounts = Map.unmodifiable(stages);
    companionStageCounts = Map.unmodifiable(companionStages);
    taxonomyCounts = Map.unmodifiable({
      for (final entry in taxonomy.entries)
        entry.key: Map<LifeStage, int>.unmodifiable(entry.value),
    });
  }

  final List<AnimalEntity> animals;
  late final Map<LifeStage, int> stageCounts;
  late final Map<LifeStage, int> companionStageCounts;
  late final Map<Species, Map<LifeStage, int>> taxonomyCounts;
}

/// Coalesces simultaneous full-herd reads and keeps the result fresh until a
/// repository change or the local calendar day boundary.
class AnimalDirectoryReadModelCache {
  AnimalDirectoryReadModelCache(this._load);

  final Future<List<AnimalEntity>> Function() _load;
  AnimalDirectoryReadModel? _value;
  Future<AnimalDirectoryReadModel>? _pending;
  DateTime? _builtOn;
  int _generation = 0;

  Future<AnimalDirectoryReadModel> read() async {
    final today = DateTime.now();
    final cached = _value;
    final builtOn = _builtOn;
    if (cached != null &&
        builtOn != null &&
        builtOn.year == today.year &&
        builtOn.month == today.month &&
        builtOn.day == today.day) {
      return cached;
    }

    final running = _pending;
    if (running != null) return running;

    final generation = _generation;
    final future = _load().then(AnimalDirectoryReadModel.new);
    _pending = future;
    try {
      final result = await future;
      if (generation == _generation) {
        _value = result;
        _builtOn = today;
      }
      return result;
    } finally {
      if (identical(_pending, future)) _pending = null;
    }
  }

  void invalidate() {
    _generation++;
    _value = null;
    _builtOn = null;
    _pending = null;
  }
}
