import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/experience/registration_preferences.dart';
import 'package:libretapp/core/experience/care_profile.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'new workspace exposes every species and plants before configuration',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = SharedPrefsService(await SharedPreferences.getInstance());
      final controller = RegistrationPreferencesController(prefs);

      expect(controller.value.configured, isFalse);
      expect(
        controller.value.preferredSpecies,
        RegistrationPreferences.allSpecies,
      );
      expect(controller.value.includePlants, isTrue);
      expect(controller.value.careProfile, CareProfile.mixed);
      controller.dispose();
    },
  );

  test(
    'migrates Lite preferences to pets and the former plant choice',
    () async {
      SharedPreferences.setMockInitialValues({
        'experience.mode.v1': 'lite',
        'experience.lite.plants.v1': false,
      });
      final prefs = SharedPrefsService(await SharedPreferences.getInstance());
      final controller = RegistrationPreferencesController(prefs);

      expect(controller.value.preferredSpecies, {
        Species.canine,
        Species.feline,
      });
      expect(controller.value.includePlants, isFalse);
      expect(controller.value.configured, isTrue);
      controller.dispose();
    },
  );

  test('migrates Complete to all current species and plants', () async {
    SharedPreferences.setMockInitialValues({'experience.mode.v1': 'complete'});
    final prefs = SharedPrefsService(await SharedPreferences.getInstance());
    final controller = RegistrationPreferencesController(prefs);

    expect(
      controller.value.preferredSpecies,
      RegistrationPreferences.allSpecies,
    );
    expect(controller.value.includePlants, isTrue);
    expect(controller.value.configured, isTrue);
    controller.dispose();
  });

  test('writes selected species and plant preference as JSON', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = SharedPrefsService(await SharedPreferences.getInstance());
    final controller = RegistrationPreferencesController(prefs);
    final selection = RegistrationPreferences(
      preferredSpecies: const {Species.other},
      includePlants: true,
    );

    await controller.setPreferences(selection);

    expect(
      RegistrationPreferences.decode(
        prefs.getString(RegistrationPreferences.storageKey),
      ).toJson(),
      selection.toJson(),
    );
    expect(controller.value, selection);
    controller.dispose();
  });

  test(
    'reads old JSON without a profile and round-trips a selected profile',
    () {
      final legacy = RegistrationPreferences.decode(
        '{"version":1,"species":["canine"],"plants":false}',
      );
      expect(legacy.careProfile, isNull);
      expect(legacy.preferredSpecies, {Species.canine});

      final selected = legacy.copyWith(careProfile: CareProfile.mixed);
      expect(
        RegistrationPreferences.decode(selected.encode()).careProfile,
        CareProfile.mixed,
      );
    },
  );
}
