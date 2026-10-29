import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/experience/registration_preferences.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/bloc/directorio_state.dart';
import 'package:libretapp/features/directorio/data/directorio_config_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DirectorioConfigRepository', () {
    late DirectorioConfigRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      repository = DirectorioConfigRepository(SharedPrefsService(prefs));
    });

    test(
      'persists the animal directory view independently per workspace',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final firstWorkspace = DirectorioConfigRepository(
          SharedPrefsService(prefs, prefix: 'workspace.one.'),
        );
        final secondWorkspace = DirectorioConfigRepository(
          SharedPrefsService(prefs, prefix: 'workspace.two.'),
        );

        expect(
          await firstWorkspace.loadAnimalViewMode(),
          AnimalDirectoryViewMode.cards,
        );
        expect(
          await secondWorkspace.loadAnimalViewMode(),
          AnimalDirectoryViewMode.cards,
        );

        await firstWorkspace.saveAnimalViewMode(
          AnimalDirectoryViewMode.compact,
        );

        expect(
          await firstWorkspace.loadAnimalViewMode(),
          AnimalDirectoryViewMode.compact,
        );
        expect(
          await secondWorkspace.loadAnimalViewMode(),
          AnimalDirectoryViewMode.cards,
        );
      },
    );

    test(
      'falls back to cards for an unknown stored animal view mode',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'directorio.animales.view_mode.v1': 'unknown-mode',
        });
        final prefs = await SharedPreferences.getInstance();
        repository = DirectorioConfigRepository(SharedPrefsService(prefs));

        expect(
          await repository.loadAnimalViewMode(),
          AnimalDirectoryViewMode.cards,
        );
      },
    );

    test('starts with all four available directory sections', () async {
      final config = await repository.load();

      expect(config.orderedSections, defaultDirectorioSectionOrder);
      expect(config.visibleSections, defaultDirectorioVisibleSections);
    });

    test('defaults animal view to cards', () async {
      expect(
        await repository.loadAnimalViewMode(),
        AnimalDirectoryViewMode.cards,
      );
    });

    test('falls back to cards for an unknown animal view mode', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'directorio.animales.view_mode.v1': 'unknown-mode',
      });
      final prefs = await SharedPreferences.getInstance();
      repository = DirectorioConfigRepository(SharedPrefsService(prefs));

      expect(
        await repository.loadAnimalViewMode(),
        AnimalDirectoryViewMode.cards,
      );
    });

    test('saves and reloads either animal view mode', () async {
      for (final mode in AnimalDirectoryViewMode.values) {
        await repository.saveAnimalViewMode(mode);
        final prefs = await SharedPreferences.getInstance();
        final reloaded = DirectorioConfigRepository(SharedPrefsService(prefs));

        expect(await reloaded.loadAnimalViewMode(), mode);
      }
    });

    test('isolates animal view preferences between workspaces', () async {
      final prefs = await SharedPreferences.getInstance();
      final firstWorkspace = DirectorioConfigRepository(
        SharedPrefsService(prefs, prefix: 'workspace.first.'),
      );
      final secondWorkspace = DirectorioConfigRepository(
        SharedPrefsService(prefs, prefix: 'workspace.second.'),
      );

      await firstWorkspace.saveAnimalViewMode(AnimalDirectoryViewMode.compact);

      expect(
        await firstWorkspace.loadAnimalViewMode(),
        AnimalDirectoryViewMode.compact,
      );
      expect(
        await secondWorkspace.loadAnimalViewMode(),
        AnimalDirectoryViewMode.cards,
      );
      expect(
        await repository.loadAnimalViewMode(),
        AnimalDirectoryViewMode.cards,
      );
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

    test(
      'preserves explicitly hidden sections on existing configuration',
      () async {
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
        });
        expect(second, first);
      },
    );

    test('suggests sections from selected species and plants', () async {
      final prefs = await SharedPreferences.getInstance();
      await SharedPrefsService(prefs).setString(
        RegistrationPreferences.storageKey,
        RegistrationPreferences(
          preferredSpecies: const {Species.canine, Species.cattle},
          includePlants: true,
        ).encode(),
      );
      repository = DirectorioConfigRepository(SharedPrefsService(prefs));

      final config = await repository.load();

      expect(config.visibleSections, {
        DirectorioSection.animales,
        DirectorioSection.cultivos,
        DirectorioSection.lotes,
        DirectorioSection.ubicaciones,
      });
    });

    test(
      'makes every directory section available in an old Lite workspace',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'experience.mode.v1': 'lite',
          'experience.lite.plants.v1': false,
        });
        final prefs = await SharedPreferences.getInstance();
        repository = DirectorioConfigRepository(SharedPrefsService(prefs));

        expect((await repository.load()).visibleSections, {
          DirectorioSection.animales,
          DirectorioSection.lotes,
          DirectorioSection.cultivos,
          DirectorioSection.ubicaciones,
        });
      },
    );

    test('maps an old Complete workspace to all four sections', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'experience.mode.v1': 'complete',
      });
      final prefs = await SharedPreferences.getInstance();
      repository = DirectorioConfigRepository(SharedPrefsService(prefs));

      expect((await repository.load()).visibleSections, {
        DirectorioSection.animales,
        DirectorioSection.lotes,
        DirectorioSection.cultivos,
        DirectorioSection.ubicaciones,
      });
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
