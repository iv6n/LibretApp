import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:libretapp/core/experience/care_profile.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';

/// The workspace's registration priorities. They never filter saved records.
@immutable
class RegistrationPreferences {
  RegistrationPreferences({
    required Iterable<Species> preferredSpecies,
    required this.includePlants,
    this.configured = true,
    this.careProfile,
  }) : preferredSpecies = Set.unmodifiable(preferredSpecies);

  factory RegistrationPreferences.fromJson(Map<String, dynamic> json) {
    final rawSpecies = json['species'];
    final species = rawSpecies is List
        ? rawSpecies
              .whereType<String>()
              .map(
                (name) =>
                    Species.values.where((s) => s.name == name).firstOrNull,
              )
              .whereType<Species>()
        : const <Species>[];
    return RegistrationPreferences(
      preferredSpecies: species,
      includePlants: json['plants'] == true,
      configured: json['configured'] != false,
      careProfile: CareProfile.values
          .where((profile) => profile.name == json['careProfile'])
          .firstOrNull,
    );
  }

  factory RegistrationPreferences.decode(String? value) {
    if (value == null) return RegistrationPreferences.defaults;
    try {
      return RegistrationPreferences.fromJson(
        jsonDecode(value) as Map<String, dynamic>,
      );
    } catch (_) {
      return RegistrationPreferences.defaults;
    }
  }

  final Set<Species> preferredSpecies;
  final bool includePlants;
  final bool configured;
  final CareProfile? careProfile;

  static const storageKey = 'registration.preferences.v1';
  static const pendingKey = 'onboarding.registration.pending.v1';
  static const recordsMigrationKey = 'registration.preferences.records.v1';

  static final allSpecies = Set<Species>.unmodifiable(Species.values);
  static final defaults = RegistrationPreferences(
    preferredSpecies: allSpecies,
    includePlants: true,
    configured: false,
    careProfile: CareProfile.mixed,
  );

  Map<String, Object?> toJson() => {
    'version': 1,
    'species': Species.values
        .where(preferredSpecies.contains)
        .map((species) => species.name)
        .toList(),
    'plants': includePlants,
    'configured': configured,
    if (careProfile != null) 'careProfile': careProfile!.name,
  };

  String encode() => jsonEncode(toJson());

  RegistrationPreferences copyWith({
    Iterable<Species>? preferredSpecies,
    bool? includePlants,
    bool? configured,
    CareProfile? careProfile,
  }) => RegistrationPreferences(
    preferredSpecies: preferredSpecies ?? this.preferredSpecies,
    includePlants: includePlants ?? this.includePlants,
    configured: configured ?? this.configured,
    careProfile: careProfile ?? this.careProfile,
  );
}

class RegistrationPreferencesController extends ChangeNotifier {
  RegistrationPreferencesController(this._prefs)
    : _value = _readOrMigrate(_prefs);

  final SharedPrefsService _prefs;
  RegistrationPreferences _value;

  RegistrationPreferences get value => _value;

  Future<void> setPreferences(RegistrationPreferences value) async {
    await _prefs.setString(RegistrationPreferences.storageKey, value.encode());
    _value = value;
    notifyListeners();
  }

  static RegistrationPreferences _readOrMigrate(SharedPrefsService prefs) {
    final stored = prefs.getString(RegistrationPreferences.storageKey);
    if (stored != null) return RegistrationPreferences.decode(stored);

    // Preserve legacy workspace preferences as presentation priorities. New
    // workspaces default to every registration category without a setup step.
    final legacyMode = prefs.getString('experience.mode.v1');
    if (legacyMode != 'lite' && legacyMode != 'complete') {
      return RegistrationPreferences.defaults;
    }
    final lite = legacyMode == 'lite';
    final migrated = RegistrationPreferences(
      preferredSpecies: lite
          ? const {Species.canine, Species.feline}
          : RegistrationPreferences.allSpecies,
      includePlants: lite
          ? prefs.getBool('experience.lite.plants.v1') ?? true
          : true,
      configured: true,
    );
    return migrated;
  }
}
