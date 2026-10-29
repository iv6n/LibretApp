import 'package:flutter/material.dart';
import 'package:libretapp/core/experience/registration_preferences.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';

/// Kept to read and migrate workspace preferences written by older releases.
enum AppExperience { complete, lite }

/// Compatibility facade while older services migrate to registration settings.
/// The app now always presents the unified experience.
class AppExperienceController extends RegistrationPreferencesController {
  AppExperienceController(SharedPrefsService prefs, {bool demo = false})
    : _prefs = prefs,
      _demo = demo,
      super(prefs);

  static const experienceKey = 'experience.mode.v1';
  static const plantsKey = 'experience.lite.plants.v1';
  static const pendingKey = 'onboarding.experience.pending.v1';

  final SharedPrefsService _prefs;
  final bool _demo;

  /// Read-only compatibility access for old integrations and stored values.
  AppExperience get experience =>
      _prefs.getString(experienceKey) == AppExperience.lite.name
      ? AppExperience.lite
      : AppExperience.complete;
  bool get isLite => experience == AppExperience.lite;
  bool get showPlants => value.includePlants;

  Future<void> setExperience(AppExperience value) async {
    if (_demo) throw StateError('El espacio de demostración no se modifica.');
    final species = value == AppExperience.lite
        ? const {Species.canine, Species.feline}
        : RegistrationPreferences.allSpecies;
    await setPreferences(
      this.value.copyWith(
        preferredSpecies: species,
        includePlants: value == AppExperience.lite ? showPlants : true,
        configured: value == AppExperience.lite,
      ),
    );
    await _prefs.setString(experienceKey, value.name);
  }

  Future<void> setShowPlants(bool value) async => setPreferences(
    this.value.copyWith(includePlants: value, configured: true),
  );
}

class AppExperienceScope extends InheritedNotifier<AppExperienceController> {
  const AppExperienceScope({
    super.key,
    required AppExperienceController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppExperienceController of(BuildContext context) {
    final controller = maybeOf(context);
    if (controller == null) {
      throw StateError('No se encontró la configuración de este espacio.');
    }
    return controller;
  }

  static AppExperienceController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AppExperienceScope>()
      ?.notifier;
}
