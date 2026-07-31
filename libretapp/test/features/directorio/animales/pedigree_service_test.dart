/// Unit tests for [PedigreeService] — pure domain, no Isar.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';

final _birth = DateTime(2020, 1, 1);

AnimalEntity _animal(
  String uuid, {
  Sex sex = Sex.female,
  String? sireUuid,
  String? damUuid,
  DateTime? birthDate,
  Species species = Species.cattle,
}) {
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: uuid,
    species: species,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: sex,
    breed: 'Brahman',
    birthDate: birthDate ?? _birth,
    ageMonths: 48,
    sireUuid: sireUuid,
    damUuid: damUuid,
    healthStatus: HealthStatus.good,
    vaccinated: true,
    dewormed: true,
    hasVitamins: true,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.breeding,
    productionStage: ProductionStage.reproductive,
    productionSystem: ProductionSystem.extensive,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.none,
    gallery: const [],
    status: AnimalStatus.active,
    synced: true,
    creationDate: _birth,
    lastUpdateDate: _birth,
  );
}

void main() {
  const service = PedigreeService();

  group('ancestorsOf', () {
    test('walks up three generations', () {
      final herd = [
        _animal('abuelo', sex: Sex.male),
        _animal('abuela'),
        _animal('padre', sex: Sex.male, sireUuid: 'abuelo', damUuid: 'abuela'),
        _animal('madre'),
        _animal('cria', sireUuid: 'padre', damUuid: 'madre'),
      ];
      final index = PedigreeService.indexByUuid(herd);

      final tree = service.ancestorsOf(herd.last, herd: index);

      expect(tree.uuid, 'cria');
      expect(tree.sire!.uuid, 'padre');
      expect(tree.dam!.uuid, 'madre');
      expect(tree.sire!.sire!.uuid, 'abuelo');
      expect(tree.sire!.dam!.uuid, 'abuela');
      expect(tree.sire!.sire!.generation, 2);
    });

    test('emits an unknown node for a sire outside the herd', () {
      final cria = _animal('cria', sireUuid: 'semental-externo');
      final index = PedigreeService.indexByUuid([cria]);

      final tree = service.ancestorsOf(cria, herd: index);

      expect(tree.sire, isNotNull);
      expect(tree.sire!.uuid, 'semental-externo');
      expect(tree.sire!.isKnown, isFalse);
      expect(tree.dam, isNull);
    });

    test('stops instead of looping when parent links form a cycle', () {
      // Corrupt data: each animal recorded as the other's sire.
      final herd = [
        _animal('a', sex: Sex.male, sireUuid: 'b'),
        _animal('b', sex: Sex.male, sireUuid: 'a'),
      ];
      final index = PedigreeService.indexByUuid(herd);

      final tree = service.ancestorsOf(herd.first, herd: index, depth: 10);

      expect(tree.uuid, 'a');
      expect(tree.sire!.uuid, 'b');
    });
  });

  group('offspringOf', () {
    test('matches either parent and sorts newest first', () {
      final herd = [
        _animal('madre'),
        _animal('hijo-viejo', damUuid: 'madre', birthDate: DateTime(2021, 1, 1)),
        _animal(
          'hijo-nuevo',
          damUuid: 'madre',
          birthDate: DateTime(2023, 1, 1),
        ),
        _animal('ajeno', damUuid: 'otra'),
      ];

      final offspring = service.offspringOf('madre', herd: herd);

      expect(
        offspring.map((a) => a.uuid),
        ['hijo-nuevo', 'hijo-viejo'],
      );
    });
  });

  group('siblingsOf', () {
    test('separates full siblings from half siblings', () {
      final target = _animal('yo', sireUuid: 'padre', damUuid: 'madre');
      final herd = [
        target,
        _animal('hermano-completo', sireUuid: 'padre', damUuid: 'madre'),
        _animal('medio-por-padre', sireUuid: 'padre', damUuid: 'otra'),
        _animal('medio-por-madre', sireUuid: 'otro', damUuid: 'madre'),
        _animal('sin-relacion', sireUuid: 'x', damUuid: 'y'),
      ];

      final siblings = service.siblingsOf(target, herd: herd);

      expect(siblings.full.map((a) => a.uuid), ['hermano-completo']);
      expect(
        siblings.half.map((a) => a.uuid),
        containsAll(['medio-por-padre', 'medio-por-madre']),
      );
      expect(siblings.half, hasLength(2));
    });

    test('two animals with no recorded parents are not siblings', () {
      final target = _animal('yo');
      final herd = [target, _animal('otro')];

      final siblings = service.siblingsOf(target, herd: herd);

      expect(siblings.full, isEmpty);
      expect(siblings.half, isEmpty);
    });
  });

  group('relatednessWarning', () {
    test('flags a sire mated to his own daughter', () {
      final herd = [
        _animal('padre', sex: Sex.male),
        _animal('hija', sireUuid: 'padre'),
      ];
      final index = PedigreeService.indexByUuid(herd);

      final result = service.relatednessWarning(
        sireUuid: 'padre',
        damUuid: 'hija',
        herd: index,
      );

      expect(result.isRelated, isTrue);
      expect(result.commonAncestorUuid, 'padre');
      expect(result.closeness, 1);
    });

    test('flags full siblings through their shared parents', () {
      final herd = [
        _animal('padre', sex: Sex.male),
        _animal('madre'),
        _animal('hermano', sex: Sex.male, sireUuid: 'padre', damUuid: 'madre'),
        _animal('hermana', sireUuid: 'padre', damUuid: 'madre'),
      ];
      final index = PedigreeService.indexByUuid(herd);

      final result = service.relatednessWarning(
        sireUuid: 'hermano',
        damUuid: 'hermana',
        herd: index,
      );

      expect(result.isRelated, isTrue);
      expect(result.closeness, 2);
    });

    test('returns unrelated for two animals with disjoint pedigrees', () {
      final herd = [
        _animal('toro', sex: Sex.male, sireUuid: 'a', damUuid: 'b'),
        _animal('vaca', sireUuid: 'c', damUuid: 'd'),
      ];
      final index = PedigreeService.indexByUuid(herd);

      final result = service.relatednessWarning(
        sireUuid: 'toro',
        damUuid: 'vaca',
        herd: index,
      );

      expect(result.isRelated, isFalse);
      expect(result.closeness, isNull);
    });

    test('is unrelated when either parent is unknown', () {
      final result = service.relatednessWarning(
        sireUuid: null,
        damUuid: 'vaca',
        herd: const {},
      );

      expect(result.isRelated, isFalse);
    });

    test('ignores a shared ancestor beyond the requested depth', () {
      // Common ancestor sits 3 generations up on both sides.
      final herd = [
        _animal('raiz', sex: Sex.male),
        _animal('p1', sex: Sex.male, sireUuid: 'raiz'),
        _animal('p2', sex: Sex.male, sireUuid: 'raiz'),
        _animal('toro', sex: Sex.male, sireUuid: 'p1'),
        _animal('vaca', sireUuid: 'p2'),
      ];
      final index = PedigreeService.indexByUuid(herd);

      final shallow = service.relatednessWarning(
        sireUuid: 'toro',
        damUuid: 'vaca',
        herd: index,
        depth: 1,
      );
      final deep = service.relatednessWarning(
        sireUuid: 'toro',
        damUuid: 'vaca',
        herd: index,
        depth: 3,
      );

      expect(shallow.isRelated, isFalse);
      expect(deep.isRelated, isTrue);
      expect(deep.commonAncestorUuid, 'raiz');
    });
  });

  group('candidateParents', () {
    test('excludes the animal itself and its descendants', () {
      final vaca = _animal('vaca');
      final herd = [
        vaca,
        _animal('hija', damUuid: 'vaca'),
        _animal('nieta', damUuid: 'hija'),
        _animal('sin-relacion'),
      ];

      final candidates = service.candidateParents(
        herd: herd,
        sex: Sex.female,
        excluding: vaca,
      );

      expect(candidates.map((a) => a.uuid), ['sin-relacion']);
    });

    test('filters by sex and species', () {
      final vaca = _animal('vaca');
      final herd = [
        vaca,
        _animal('toro', sex: Sex.male),
        _animal('vaca-2'),
        _animal('semental-equino', sex: Sex.male, species: Species.equine),
      ];

      final candidates = service.candidateParents(
        herd: herd,
        sex: Sex.male,
        excluding: vaca,
      );

      expect(candidates.map((a) => a.uuid), ['toro']);
    });
  });
}
