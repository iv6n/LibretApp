import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/bloc/directorio_state.dart';
import 'package:libretapp/features/directorio/data/directorio_config_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DirectorioConfigRepository', () {
    late DirectorioConfigRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      repository = DirectorioConfigRepository(SharedPrefsService(prefs));
    });

    test('loads all four directory sections by default', () async {
      final config = await repository.load();

      expect(config.orderedSections, defaultDirectorioSectionOrder);
      expect(config.visibleSections, defaultDirectorioVisibleSections);
      expect(config.visibleSections, {
        DirectorioSection.animales,
        DirectorioSection.lotes,
        DirectorioSection.cultivos,
        DirectorioSection.ubicaciones,
      });
    });

    test('saves and reloads custom order and visibility', () async {
      const custom = DirectorioSectionConfig(
        orderedSections: [
          DirectorioSection.ubicaciones,
          DirectorioSection.animales,
          DirectorioSection.lotes,
          DirectorioSection.cultivos,
        ],
        visibleSections: {
          DirectorioSection.ubicaciones,
          DirectorioSection.animales,
          DirectorioSection.lotes,
          DirectorioSection.cultivos,
        },
      );

      await repository.save(custom);
      final loaded = await repository.load();

      expect(loaded.orderedSections, custom.orderedSections);
      expect(loaded.visibleSections, custom.visibleSections);
    });

    test('adds Cultivos once to an existing custom configuration', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'directorio.section_config.v1':
            '{"order":["ubicaciones","animales","lotes"],"visible":["ubicaciones","animales"]}',
      });
      final prefs = await SharedPreferences.getInstance();
      repository = DirectorioConfigRepository(SharedPrefsService(prefs));

      final first = await repository.load();
      final second = await repository.load();

      expect(first.orderedSections, [
        DirectorioSection.ubicaciones,
        DirectorioSection.animales,
        DirectorioSection.lotes,
        DirectorioSection.cultivos,
      ]);
      expect(first.visibleSections, {
        DirectorioSection.ubicaciones,
        DirectorioSection.animales,
        DirectorioSection.cultivos,
      });
      expect(second, first);
    });

    test('falls back to defaults when stored json is corrupt', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'directorio.section_config.v1': '{bad json',
      });
      final prefs = await SharedPreferences.getInstance();
      repository = DirectorioConfigRepository(SharedPrefsService(prefs));

      final config = await repository.load();

      expect(config.orderedSections, defaultDirectorioSectionOrder);
      expect(config.visibleSections, defaultDirectorioVisibleSections);
    });
  });
}
