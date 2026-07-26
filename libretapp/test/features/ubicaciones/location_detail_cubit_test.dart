import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/ubicaciones/cubit/location_detail_cubit.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class _FakeLocationRepository implements LocationRepository {
  _FakeLocationRepository()
    : _controller = StreamController<List<LocationEntity>>.broadcast();

  final StreamController<List<LocationEntity>> _controller;

  void emitLocations(List<LocationEntity> locations) =>
      _controller.add(locations);

  @override
  Stream<List<LocationEntity>> watchAll() => _controller.stream;

  Future<void> dispose() => _controller.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAnimalRepository implements AnimalRepository {
  @override
  Stream<List<AnimalEntity>> watchAll() async* {
    yield const [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMovementRecordRepository implements MovementRecordRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LocationEntity _location(String uuid) {
  return LocationEntity(
    uuid: uuid,
    name: 'Potrero $uuid',
    type: LocationType.pasture,
    surfaceArea: 10,
    capacity: 20,
    waterSource: 'Pozo',
    terrainType: 'Plano',
  );
}

void main() {
  late _FakeLocationRepository locationRepository;
  late LocationDetailCubit cubit;

  setUp(() {
    locationRepository = _FakeLocationRepository();
    cubit = LocationDetailCubit(
      locationUuid: 'loc-1',
      locationRepository: locationRepository,
      animalRepository: _FakeAnimalRepository(),
      movementRepository: _FakeMovementRecordRepository(),
    );
  });

  tearDown(() async {
    await cubit.close();
    await locationRepository.dispose();
  });

  test('location becomes null (isNotFound) after it is deleted', () async {
    locationRepository.emitLocations([_location('loc-1'), _location('loc-2')]);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.location?.uuid, 'loc-1');
    expect(cubit.state.isNotFound, isFalse);

    // Location "loc-1" is gone from the next snapshot (deleted elsewhere).
    locationRepository.emitLocations([_location('loc-2')]);
    await Future<void>.delayed(Duration.zero);

    expect(
      cubit.state.location,
      isNull,
      reason:
          'copyWith must be able to reset location back to null once it '
          'disappears from the stream, not just keep the stale value',
    );
    expect(cubit.state.isNotFound, isTrue);
  });
}
