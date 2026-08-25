/// Determines whether startup should show the first-run welcome screen.
library;

import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';

class OnboardingStartupService {
  const OnboardingStartupService({
    required SharedPrefsService preferences,
    required AnimalRepository animalRepository,
  }) : _preferences = preferences,
       _animalRepository = animalRepository;

  final SharedPrefsService _preferences;
  final AnimalRepository _animalRepository;

  Future<bool> shouldShowWelcome() async {
    if (_preferences.getBool(PrefsKeys.onboardingCompletedV1) == true) {
      return false;
    }

    final existingAnimals = await _animalRepository.getAllIncludingInactive();
    if (existingAnimals.isEmpty) return true;

    // This is an upgrade, not a new installation. Mark the migration so the
    // check does not have to infer it again on every startup.
    await markCompleted();
    return false;
  }

  Future<void> markCompleted() =>
      _preferences.setBool(PrefsKeys.onboardingCompletedV1, true);
}
