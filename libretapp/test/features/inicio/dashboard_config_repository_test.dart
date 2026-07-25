import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/inicio/data/dashboard_config_repository.dart';
import 'package:libretapp/features/inicio/data/dashboard_widget_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DashboardConfigRepository', () {
    late DashboardConfigRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repo = DashboardConfigRepository(SharedPrefsService(prefs));
    });

    test('returns defaults when nothing saved', () async {
      final widgets = await repo.loadWidgets();
      expect(widgets.length, defaultDashboardWidgets().length);
      expect(widgets.first.type, DashboardWidgetType.healthAlerts);
    });

    test('persists widget enable toggle', () async {
      final widgets = await repo.loadWidgets();
      final updated = [
        for (final w in widgets)
          if (w.type == DashboardWidgetType.weather)
            w.copyWith(enabled: false)
          else
            w,
      ];
      await repo.saveWidgets(updated);
      final loaded = await repo.loadWidgets();
      final weather = loaded.firstWhere(
        (w) => w.type == DashboardWidgetType.weather,
      );
      expect(weather.enabled, isFalse);
    });
  });
}
