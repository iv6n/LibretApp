import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_bloc.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_event.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_state.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/index.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';

void main() {
  group('AnimalesBloc AddAnimal', () {
    test('persists animal and emits loaded state', () async {
      final repository = _FakeAnimalRepository(initialAnimals: const []);
      final bloc = AnimalesBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const LoadAnimales());
      await _flushEvents();

      final animal = _buildAnimal(uuid: 'ani-1', earTag: 'TAG-001');
      bloc.add(AddAnimal(animal));
      await _flushEvents();

      expect(repository.saveCallCount, 1);
      expect(repository.getByUuidSync('ani-1'), isNotNull);
      expect(bloc.state, isA<AnimalesLoaded>());

      final loaded = bloc.state as AnimalesLoaded;
      expect(loaded.allAnimals.any((item) => item.uuid == 'ani-1'), isTrue);
    });

    test(
      'emits loaded state even when mutation stream update is delayed',
      () async {
        final repository = _FakeAnimalRepository(
          initialAnimals: const [],
          emitOnMutations: false,
        );
        final bloc = AnimalesBloc(repository);
        addTearDown(bloc.close);

        bloc.add(const LoadAnimales());
        await _flushEvents();

        final animal = _buildAnimal(uuid: 'ani-2', earTag: 'TAG-002');
        bloc.add(AddAnimal(animal));
        await _flushEvents();

        expect(repository.saveCallCount, 1);
        expect(bloc.state, isA<AnimalesLoaded>());

        final loaded = bloc.state as AnimalesLoaded;
        expect(loaded.allAnimals.any((item) => item.uuid == 'ani-2'), isTrue);
      },
    );

    test('updates animal and keeps loaded state', () async {
      final initialAnimal = _buildAnimal(uuid: 'ani-upd', earTag: 'TAG-OLD');
      final repository = _FakeAnimalRepository(initialAnimals: [initialAnimal]);
      final bloc = AnimalesBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const LoadAnimales());
      await _flushEvents();

      final updatedAnimal = initialAnimal.copyWith(earTagNumber: 'TAG-NEW');
      bloc.add(UpdateAnimal(updatedAnimal));
      await _flushEvents();

      expect(repository.updateCallCount, 1);
      expect(bloc.state, isA<AnimalesLoaded>());

      final loaded = bloc.state as AnimalesLoaded;
      final stored = loaded.allAnimals.firstWhere(
        (item) => item.uuid == 'ani-upd',
      );
      expect(stored.earTagNumber, 'TAG-NEW');
    });

    test('deletes animal and emits loaded state without it', () async {
      final repository = _FakeAnimalRepository(
        initialAnimals: [
          _buildAnimal(uuid: 'ani-del-1', earTag: 'TAG-DEL-1'),
          _buildAnimal(uuid: 'ani-del-2', earTag: 'TAG-DEL-2'),
        ],
      );
      final bloc = AnimalesBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const LoadAnimales());
      await _flushEvents();

      bloc.add(const DeleteAnimal('ani-del-1'));
      await _flushEvents();

      expect(repository.deleteCallCount, 1);
      expect(bloc.state, isA<AnimalesLoaded>());

      final loaded = bloc.state as AnimalesLoaded;
      expect(
        loaded.allAnimals.any((item) => item.uuid == 'ani-del-1'),
        isFalse,
      );
      expect(loaded.allAnimals.any((item) => item.uuid == 'ani-del-2'), isTrue);
    });

    test('emits error state when repository save fails', () async {
      final repository = _FakeAnimalRepository(
        initialAnimals: const [],
        throwOnSave: true,
      );
      final bloc = AnimalesBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const LoadAnimales());
      await _flushEvents();

      bloc.add(AddAnimal(_buildAnimal(uuid: 'ani-err', earTag: 'TAG-ERR')));
      await _flushEvents();

      expect(repository.saveCallCount, 1);
      expect(bloc.state, isA<AnimalesError>());
    });

    test('emits error state when repository update fails', () async {
      final repository = _FakeAnimalRepository(
        initialAnimals: [_buildAnimal(uuid: 'ani-err-upd', earTag: 'TAG-1')],
        throwOnUpdate: true,
      );
      final bloc = AnimalesBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const LoadAnimales());
      await _flushEvents();

      final updated = _buildAnimal(uuid: 'ani-err-upd', earTag: 'TAG-2');
      bloc.add(UpdateAnimal(updated));
      await _flushEvents();

      expect(repository.updateCallCount, 1);
      expect(bloc.state, isA<AnimalesError>());
    });

    test('emits error state when repository delete fails', () async {
      final repository = _FakeAnimalRepository(
        initialAnimals: [_buildAnimal(uuid: 'ani-err-del', earTag: 'TAG-DEL')],
        throwOnDelete: true,
      );
      final bloc = AnimalesBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const LoadAnimales());
      await _flushEvents();

      bloc.add(const DeleteAnimal('ani-err-del'));
      await _flushEvents();

      expect(repository.deleteCallCount, 1);
      expect(bloc.state, isA<AnimalesError>());
    });
  });
}

Future<void> _flushEvents() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(const Duration(milliseconds: 20));
}

AnimalEntity _buildAnimal({required String uuid, required String earTag}) {
  final now = DateTime(2025, 1, 1);
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: earTag,
    customName: 'Animal $uuid',
    visualId: 'VIS-$uuid',
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: 'Cebu',
    birthDate: DateTime(2020, 1, 1),
    ageMonths: 60,
    weight: 420,
    healthStatus: HealthStatus.good,
    vaccinated: true,
    dewormed: true,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.undefined,
    productionStage: ProductionStage.unknown,
    productionSystem: ProductionSystem.unknown,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.low,
    gallery: const [],
    synced: false,
    creationDate: now,
    lastUpdateDate: now,
  );
}

class _FakeAnimalRepository implements AnimalRepository {
  _FakeAnimalRepository({
    required List<AnimalEntity> initialAnimals,
    this.throwOnSave = false,
    this.throwOnUpdate = false,
    this.throwOnDelete = false,
    this.emitOnMutations = true,
  }) : _animals = <AnimalEntity>[...initialAnimals] {
    _controller.add(List<AnimalEntity>.unmodifiable(_animals));
  }

  final List<AnimalEntity> _animals;
  final bool throwOnSave;
  final bool throwOnUpdate;
  final bool throwOnDelete;
  final bool emitOnMutations;
  final StreamController<List<AnimalEntity>> _controller =
      StreamController<List<AnimalEntity>>.broadcast();

  int saveCallCount = 0;
  int updateCallCount = 0;
  int deleteCallCount = 0;

  AnimalEntity? getByUuidSync(String uuid) {
    for (final animal in _animals) {
      if (animal.uuid == uuid) {
        return animal;
      }
    }
    return null;
  }

  @override
  Stream<List<AnimalEntity>> watchAll() => _controller.stream;

  @override
  Future<bool> refreshFromRemote({bool force = false}) async => true;

  @override
  Future<List<AnimalEntity>> getAll() async {
    return List<AnimalEntity>.unmodifiable(_animals);
  }

  @override
  Future<AnimalEntity?> getByUuid(String uuid) async => getByUuidSync(uuid);

  @override
  Future<AnimalEntity> save(AnimalEntity animal) async {
    saveCallCount += 1;
    if (throwOnSave) {
      throw Exception('save failed');
    }
    _animals.add(animal);
    if (emitOnMutations) {
      _controller.add(List<AnimalEntity>.unmodifiable(_animals));
    }
    return animal;
  }

  @override
  Future<AnimalEntity> update(AnimalEntity animal) async {
    updateCallCount += 1;
    if (throwOnUpdate) {
      throw Exception('update failed');
    }
    final index = _animals.indexWhere((item) => item.uuid == animal.uuid);
    if (index >= 0) {
      _animals[index] = animal;
    }
    if (emitOnMutations) {
      _controller.add(List<AnimalEntity>.unmodifiable(_animals));
    }
    return animal;
  }

  @override
  Future<void> delete(String uuid) async {
    deleteCallCount += 1;
    if (throwOnDelete) {
      throw Exception('delete failed');
    }
    _animals.removeWhere((item) => item.uuid == uuid);
    if (emitOnMutations) {
      _controller.add(List<AnimalEntity>.unmodifiable(_animals));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #dispose) {
      _controller.close();
      return null;
    }
    return super.noSuchMethod(invocation);
  }
}
