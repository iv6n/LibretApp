/// features > biblioteca > data > region_catalog — Dart mirror of
/// `regions/mexico-regions.json` from the content repo, bundled at
/// `assets/library/mexico-regions.json`. Shared taxonomy of states, climate
/// regions, and production settings used to resolve adaptive book content
/// and to populate the profile's region/production-setting pickers.
library;

class RegionState {
  const RegionState({
    required this.id,
    required this.name,
    required this.regions,
    required this.productionSettings,
  });

  factory RegionState.fromJson(Map<String, dynamic> json) => RegionState(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    regions: List<String>.from(json['regions'] as List? ?? const []),
    productionSettings: List<String>.from(
      json['production_settings'] as List? ?? const [],
    ),
  );

  final String id;
  final String name;
  final List<String> regions;
  final List<String> productionSettings;
}

class RegionInfo {
  const RegionInfo({
    required this.id,
    required this.name,
    required this.states,
    required this.risks,
    required this.description,
  });

  factory RegionInfo.fromJson(Map<String, dynamic> json) => RegionInfo(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    states: List<String>.from(json['states'] as List? ?? const []),
    risks: List<String>.from(json['risks'] as List? ?? const []),
    description: json['description'] as String? ?? '',
  );

  final String id;
  final String name;
  final List<String> states;
  final List<String> risks;
  final String description;
}

class ProductionSettingInfo {
  const ProductionSettingInfo({required this.id, required this.name});

  factory ProductionSettingInfo.fromJson(Map<String, dynamic> json) =>
      ProductionSettingInfo(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
      );

  final String id;
  final String name;
}

class RegionCatalog {
  const RegionCatalog({
    required this.country,
    required this.defaultState,
    required this.defaultProductionSetting,
    required this.states,
    required this.regions,
    required this.productionSettings,
  });

  factory RegionCatalog.fromJson(Map<String, dynamic> json) => RegionCatalog(
    country: json['country'] as String? ?? '',
    defaultState: json['default_state'] as String? ?? 'general',
    defaultProductionSetting:
        json['default_production_setting'] as String? ?? 'general',
    states: (json['states'] as List<dynamic>? ?? const [])
        .map((e) => RegionState.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    regions: (json['regions'] as List<dynamic>? ?? const [])
        .map((e) => RegionInfo.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    productionSettings:
        (json['production_settings'] as List<dynamic>? ?? const [])
            .map((e) => ProductionSettingInfo.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
  );

  final String country;
  final String defaultState;
  final String defaultProductionSetting;
  final List<RegionState> states;
  final List<RegionInfo> regions;
  final List<ProductionSettingInfo> productionSettings;

  RegionState? stateById(String id) {
    for (final state in states) {
      if (state.id == id) return state;
    }
    return null;
  }

  /// Climate/agronomic regions a given state's producers fall under, e.g.
  /// `sonora` -> `[northwest_arid, northern_rangelands]`. Falls back to
  /// `[general]` when the state is unknown or unset.
  List<String> climateRegionsForState(String stateId) {
    final regions = stateById(stateId)?.regions ?? const [];
    return regions.isEmpty ? const ['general'] : regions;
  }
}
