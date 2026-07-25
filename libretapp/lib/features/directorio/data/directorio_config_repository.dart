/// features > directorio > data > directorio_config_repository — persists directory tabs.
library;

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/bloc/directorio_state.dart';

const defaultDirectorioSectionConfig = DirectorioSectionConfig(
  orderedSections: defaultDirectorioSectionOrder,
  visibleSections: defaultDirectorioVisibleSections,
);

const _storageKey = 'directorio.section_config.v1';

class DirectorioSectionConfig extends Equatable {
  const DirectorioSectionConfig({
    required this.orderedSections,
    required this.visibleSections,
  });

  factory DirectorioSectionConfig.fromJson(Map<String, dynamic> json) {
    final order = _decodeSections(json['order']);
    final visible = _decodeSections(json['visible']).toSet();
    return DirectorioSectionConfig(
      orderedSections: order,
      visibleSections: visible,
    ).normalized();
  }

  final List<DirectorioSection> orderedSections;
  final Set<DirectorioSection> visibleSections;

  DirectorioSectionConfig normalized() {
    final ordered = <DirectorioSection>[];
    for (final section in orderedSections) {
      if (!ordered.contains(section)) ordered.add(section);
    }
    for (final section in defaultDirectorioSectionOrder) {
      if (!ordered.contains(section)) ordered.add(section);
    }

    final visible = visibleSections
        .where(ordered.contains)
        .toSet();

    return DirectorioSectionConfig(
      orderedSections: List<DirectorioSection>.unmodifiable(ordered),
      visibleSections: visible.isEmpty
          ? Set<DirectorioSection>.of(defaultDirectorioVisibleSections)
          : Set<DirectorioSection>.unmodifiable(visible),
    );
  }

  Map<String, dynamic> toJson() {
    final normalizedConfig = normalized();
    return <String, dynamic>{
      'order': normalizedConfig.orderedSections
          .map((section) => section.name)
          .toList(),
      'visible': normalizedConfig.visibleSections
          .map((section) => section.name)
          .toList(),
    };
  }

  static List<DirectorioSection> _decodeSections(Object? value) {
    if (value is! List) return const <DirectorioSection>[];
    return value
        .whereType<String>()
        .map(_sectionFromName)
        .whereType<DirectorioSection>()
        .toList(growable: false);
  }

  static DirectorioSection? _sectionFromName(String name) {
    for (final section in DirectorioSection.values) {
      if (section.name == name) return section;
    }
    return null;
  }

  @override
  List<Object?> get props => [orderedSections, visibleSections];
}

class DirectorioConfigRepository {
  DirectorioConfigRepository(this._prefs);

  final SharedPrefsService _prefs;

  Future<DirectorioSectionConfig> load() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return defaultDirectorioSectionConfig;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return DirectorioSectionConfig.fromJson(json);
    } catch (_) {
      return defaultDirectorioSectionConfig;
    }
  }

  Future<void> save(DirectorioSectionConfig config) async {
    await _prefs.setString(_storageKey, jsonEncode(config.toJson()));
  }

  Future<void> resetToDefaults() => save(defaultDirectorioSectionConfig);
}
