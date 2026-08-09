import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/biblioteca/data/book_content.dart';
import 'package:libretapp/features/biblioteca/data/region_catalog.dart';
import 'package:libretapp/features/biblioteca/domain/adaptive_resolver.dart';

void main() {
  late BookContent bovinos;
  late RegionCatalog regions;
  const resolver = AdaptiveResolver();

  setUpAll(() {
    bovinos = BookContent.fromJson(
      jsonDecode(
            File('assets/library/bovinos/content/book-content.json')
                .readAsStringSync(),
          )
          as Map<String, dynamic>,
    );
    regions = RegionCatalog.fromJson(
      jsonDecode(File('assets/library/mexico-regions.json').readAsStringSync())
          as Map<String, dynamic>,
    );
  });

  test('region catalog resolves Sonora to its two pilot climate regions', () {
    expect(
      regions.climateRegionsForState('sonora'),
      ['northwest_arid', 'northern_rangelands'],
    );
    expect(regions.climateRegionsForState('unknown_state'), ['general']);
  });

  test('a Sonora rangeland profile resolves the Sonora adaptation, not general', () {
    final chapter = bovinos.adaptive!.regionalAdaptations.forChapter('ch-01.md')!;
    final sonoraProfile = ReaderProfile(
      state: 'sonora',
      climateRegions: regions.climateRegionsForState('sonora'),
      productionSetting: 'rangeland',
    );

    final resolved = resolver.resolveAdaptation(chapter, sonoraProfile);

    expect(resolved, isNotNull);
    expect(resolved!.states, contains('sonora'));
    expect(resolved.id, 'bovinos_ch_01_sonora');
  });

  test('an unset/general profile resolves the general fallback', () {
    final chapter = bovinos.adaptive!.regionalAdaptations.forChapter('ch-01.md')!;

    final resolved = resolver.resolveAdaptation(chapter, ReaderProfile.general);

    expect(resolved, isNotNull);
    expect(resolved!.states, contains('general'));
  });

  test('a profile from an unrelated state still falls back to general', () {
    final chapter = bovinos.adaptive!.regionalAdaptations.forChapter('ch-01.md')!;
    final unrelatedProfile = ReaderProfile(
      state: 'yucatan',
      climateRegions: const ['yucatan_peninsula'],
      productionSetting: 'humid_lowland',
    );

    final resolved = resolver.resolveAdaptation(chapter, unrelatedProfile);

    expect(resolved, isNotNull);
    expect(resolved!.states, contains('general'));
  });

  test('every chapter resolves to a non-null adaptation for both profiles', () {
    for (final chapter
        in bovinos.adaptive!.regionalAdaptations.adaptationsByChapter) {
      expect(
        resolver.resolveAdaptation(chapter, ReaderProfile.general),
        isNotNull,
        reason: chapter.chapter,
      );
      expect(
        resolver.resolveAdaptation(
          chapter,
          ReaderProfile(
            state: 'sonora',
            climateRegions: regions.climateRegionsForState('sonora'),
            productionSetting: 'desert_coastal',
          ),
        ),
        isNotNull,
        reason: chapter.chapter,
      );
    }
  });

  test('resolveTaskTips keeps only tips relevant to the Sonora profile', () {
    final chapterTips = bovinos.adaptive!.taskTips.forChapter('ch-01.md');
    expect(chapterTips, isNotEmpty);

    final sonoraProfile = ReaderProfile(
      state: 'sonora',
      climateRegions: regions.climateRegionsForState('sonora'),
      productionSetting: 'rangeland',
    );
    final resolved = resolver.resolveTaskTips(chapterTips, sonoraProfile);

    expect(resolved, isNotEmpty);
    for (final tip in resolved) {
      expect(tip.appliesTo.states, contains('sonora'));
    }
  });
}
