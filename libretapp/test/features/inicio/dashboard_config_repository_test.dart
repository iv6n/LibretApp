import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/inicio/data/dashboard_config_repository.dart';
import 'package:libretapp/features/inicio/data/dashboard_widget_config.dart';
import 'package:libretapp/core/experience/care_profile.dart';
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
      expect(widgets.first.type, DashboardWidgetType.pendingTasks);
      expect(widgets[1].type, DashboardWidgetType.animalSummary);
      for (final profile in CareProfile.values) {
        final profileWidgets = await repo.loadWidgets(profile: profile);
        expect(
          profileWidgets
              .firstWhere(
                (item) => item.type == DashboardWidgetType.animalSummary,
              )
              .enabled,
          isTrue,
        );
      }
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

    test('adds animal summary to older saved layouts', () async {
      await repo.saveWidgets(const [
        DashboardWidgetConfig(
          id: 'pendingTasks',
          title: 'Tareas pendientes',
          type: DashboardWidgetType.pendingTasks,
          enabled: true,
          order: 6,
        ),
      ]);

      final loaded = await repo.loadWidgets(profile: CareProfile.livestock);
      expect(loaded.map((item) => item.type), [
        DashboardWidgetType.pendingTasks,
        DashboardWidgetType.animalSummary,
      ]);
      expect(loaded.last.order, 7);
    });

    test('respects an explicitly hidden animal summary', () async {
      final widgets = defaultDashboardWidgets();
      await repo.saveWidgets([
        for (final item in widgets)
          item.type == DashboardWidgetType.animalSummary
              ? item.copyWith(enabled: false)
              : item,
      ]);

      final loaded = await repo.loadWidgets();
      expect(
        loaded
            .firstWhere(
              (item) => item.type == DashboardWidgetType.animalSummary,
            )
            .enabled,
        isFalse,
      );
    });
  });
}
