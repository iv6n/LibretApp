/// Determines whether startup should show the first-run welcome screen.
library;

import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';

class OnboardingStartupService {
  const OnboardingStartupService({
    required SharedPrefsService preferences,
    required AnimalRepository animalRepository,
    Future<bool> Function()? hasAnimals,
    Future<bool> Function()? hasOtherUserData,
  }) : _preferences = preferences,
       _animalRepository = animalRepository,
       _hasAnimals = hasAnimals,
       _hasOtherUserData = hasOtherUserData;

  final SharedPrefsService _preferences;
  final AnimalRepository _animalRepository;
  final Future<bool> Function()? _hasAnimals;
  final Future<bool> Function()? _hasOtherUserData;

  Future<bool> shouldShowWelcome() async {
    if (_preferences.getBool(PrefsKeys.onboardingCompletedV1) == true) {
      return false;
    }

    final presence = await Future.wait<bool>([
      _hasAnimals?.call() ??
          _animalRepository.getAllIncludingInactive().then(
            (animals) => animals.isNotEmpty,
          ),
      _hasOtherUserData?.call() ?? Future<bool>.value(false),
    ]);
    if (!presence[0] && !presence[1]) {
      return true;
    }

    // This is an upgrade, not a new installation. Mark the migration so the
    // check does not have to infer it again on every startup.
    await markCompleted();
    return false;
  }

  Future<void> markCompleted() =>
      _preferences.setBool(PrefsKeys.onboardingCompletedV1, true);
}
