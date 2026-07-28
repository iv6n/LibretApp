import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/inicio/data/dashboard_quick_action.dart';

void main() {
  group('DashboardQuickAction JSON round trip', () {
    for (final action in defaultQuickActions()) {
      test('${action.id} preserves its icon through toJson/fromJson', () {
        final restored = DashboardQuickAction.fromJson(action.toJson());

        expect(restored, action);
        expect(restored.icon, action.icon);
      });
    }

    test('falls back to touch_app for an unrecognized icon codepoint', () {
      final restored = DashboardQuickAction.fromJson({
        'id': 'legacy',
        'label': 'Acceso antiguo',
        'iconCodePoint': 0x0,
        'routeName': 'inicio',
        'enabled': true,
        'order': 0,
      });

      expect(restored.icon, Icons.touch_app);
    });

    test('falls back to touch_app when the codepoint is missing', () {
      final restored = DashboardQuickAction.fromJson({
        'id': 'legacy',
        'label': 'Acceso antiguo',
        'routeName': 'inicio',
        'enabled': true,
        'order': 0,
      });

      expect(restored.icon, Icons.touch_app);
    });
  });
}
