import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/utils/number_parsing.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/application/lote_weighing_cubit.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

import '../features/directorio/animales/advisor/rules/rule_test_fixtures.dart';

class _Animals implements AnimalRepository {
  @override
  Future<List<AnimalEntity>> getByBatchUuid(String uuid) async => [
    buildAnimal(uuid: 'a'),
    buildAnimal(uuid: 'b'),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Lotes implements LotesRepository {
  @override
  Future<LoteEntity?> getByUuid(String uuid) async => LoteEntity(
    uuid: uuid,
    name: 'Lote de prueba',
    animalUuids: const ['a', 'b'],
    createdAt: DateTime(2026, 1, 1),
    lastUpdateDate: DateTime(2026, 1, 1),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Weights implements WeightRecordRepository {
  final stored = <String>[];
  bool failSecond = false;
  Completer<void>? gate;
  int started = 0;

  @override
  Future<Map<String, List<WeightRecord>>> getWeightRecordsForAnimals(
    Set<String> uuids,
  ) async => {};

  @override
  Future<List<WeightRecord>> addWeightRecordsAtomically(
    List<WeightBatchEntry> entries,
  ) async {
    started++;
    if (gate != null) await gate!.future;
    if (failSecond && entries.any((e) => e.animalUuid == 'b'))
      throw StateError('fallo en b');
    stored.addAll(entries.map((e) => e.animalUuid));
    return entries.map((e) => e.record).toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<LoteWeighingCubit> open(_Weights weights) async {
    final cubit = LoteWeighingCubit(
      animalRepository: _Animals(),
      lotesRepository: _Lotes(),
      weightRepository: weights,
    );
    addTearDown(cubit.close);
    await cubit.load('lote');
    cubit.setWeight('a', '120');
    cubit.setWeight('b', '130');
    return cubit;
  }

  test('retry after batch failure saves exactly once', () async {
    final weights = _Weights()..failSecond = true;
    final cubit = await open(weights);
    await cubit.save();
    expect(cubit.state.status, LoteWeighingStatus.failure);
    expect(cubit.state.savedCount, 0);
    expect(weights.stored, isEmpty);

    weights.failSecond = false;
    await cubit.save();
    expect(cubit.state.status, LoteWeighingStatus.saved);
    expect(weights.stored, ['a', 'b']);
    // The second a is a new record: save() does not retain any recordUuid.
  });

  test('editing and double submit during save are blocked', () async {
    final weights = _Weights()..gate = Completer<void>();
    final cubit = await open(weights);
    final first = cubit.save();
    expect(cubit.state.isSaving, isTrue);
    cubit.setWeight('b', '135');
    expect(cubit.state.isSaving, isTrue);
    final second = cubit.save();
    expect(weights.started, 1);
    weights.gate!.complete();
    await Future.wait([first, second]);
    expect(weights.stored.where((uuid) => uuid == 'a').length, 1);
    expect(weights.stored.where((uuid) => uuid == 'b').length, 1);
  });

  test('numeric parser rejects non-finite values', () {
    for (final value in ['NaN', 'Infinity', '-Infinity', '1e309']) {
      expect(parseFormDouble(value), isNull);
    }
  });
}
