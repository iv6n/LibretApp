import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/inicio/data/dashboard_quick_action.dart';
import 'package:libretapp/core/experience/care_profile.dart';

void main() {
  group('DashboardQuickAction JSON round trip', () {
    for (final action in defaultQuickActions()) {
      test('${action.id} preserves its icon through toJson/fromJson', () {
        final restored = DashboardQuickAction.fromJson(action.toJson());

        expect(restored, action);
        expect(restored.icon, action.icon);
      });
    }

    test('profile suggestions include pet intake and all-functions access', () {
      final pets = defaultQuickActions(profile: CareProfile.pets);
      expect(pets.first.queryParameters, {'kind': 'pet'});
      expect(pets.map((action) => action.label), contains('Programar cuidado'));
      expect(
        pets.map((action) => action.label),
        contains('Ver todas las funciones'),
      );

      final mixed = defaultQuickActions(profile: CareProfile.mixed);
      expect(mixed.map((action) => action.label), contains('Añadir ganado'));
      expect(mixed.map((action) => action.label), contains('Añadir mascota'));
    });

    test('navigation context is compatible with stored quick actions', () {
      const action = DashboardQuickAction(
        id: 'pet-health',
        label: 'Registrar atención',
        icon: Icons.health_and_safety_outlined,
        routeName: 'registro_sanitario',
        enabled: true,
        order: 0,
        queryParameters: {'animalUuid': 'pet-1'},
      );
      final restored = DashboardQuickAction.fromJson(action.toJson());
      expect(restored.queryParameters, {'animalUuid': 'pet-1'});
    });

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
