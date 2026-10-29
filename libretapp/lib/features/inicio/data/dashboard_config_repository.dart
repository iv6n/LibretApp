/// features › inicio › data › dashboard_config_repository — persists dashboard layout.
library;

import 'dart:convert';

import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/experience/care_profile.dart';
import 'package:libretapp/core/experience/registration_preferences.dart';
import 'package:libretapp/features/inicio/data/dashboard_quick_action.dart';
import 'package:libretapp/features/inicio/data/dashboard_widget_config.dart';

const _widgetsKey = 'dashboard_config_widgets_v1';
const _actionsKey = 'dashboard_config_actions_v1';

class DashboardConfigRepository {
  DashboardConfigRepository(this._prefs);

  final SharedPrefsService _prefs;

  CareProfile? resolveProfile({required int pets, required int livestock}) {
    final preferences = RegistrationPreferences.decode(
      _prefs.getString(RegistrationPreferences.storageKey),
    );
    return resolveCareProfileFromCounts(
      selected: preferences.careProfile,
      pets: pets,
      livestock: livestock,
      preferredSpecies: preferences.preferredSpecies,
    );
  }

  Future<List<DashboardWidgetConfig>> loadWidgets({
    CareProfile? profile,
  }) async {
    final raw = _prefs.getString(_widgetsKey);
    if (raw == null || raw.isEmpty)
      return defaultDashboardWidgets(profile: profile);
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final configs =
          list
              .map(
                (e) =>
                    DashboardWidgetConfig.fromJson(e as Map<String, dynamic>),
              )
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));
      return configs;
    } catch (_) {
      return defaultDashboardWidgets(profile: profile);
    }
  }

  Future<void> saveWidgets(List<DashboardWidgetConfig> widgets) async {
    final encoded = jsonEncode(widgets.map((w) => w.toJson()).toList());
    await _prefs.setString(_widgetsKey, encoded);
  }

  Future<List<DashboardQuickAction>> loadQuickActions({
    CareProfile? profile,
  }) async {
    final raw = _prefs.getString(_actionsKey);
    if (raw == null || raw.isEmpty)
      return defaultQuickActions(profile: profile);
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final actions =
          list
              .map(
                (e) => DashboardQuickAction.fromJson(e as Map<String, dynamic>),
              )
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));
      return actions;
    } catch (_) {
      return defaultQuickActions(profile: profile);
    }
  }

  Future<void> saveQuickActions(List<DashboardQuickAction> actions) async {
    final encoded = jsonEncode(actions.map((a) => a.toJson()).toList());
    await _prefs.setString(_actionsKey, encoded);
  }

  Future<void> resetToDefaults({CareProfile? profile}) async {
    await saveWidgets(defaultDashboardWidgets(profile: profile));
    await saveQuickActions(defaultQuickActions(profile: profile));
  }
}
