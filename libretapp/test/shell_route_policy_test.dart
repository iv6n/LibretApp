import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/app/shell_route_policy.dart';

void main() {
  group('shouldHideShellChrome', () {
    test('keeps chrome visible on primary routes', () {
      const visibleRoutes = <String>[
        '/',
        '/directorio',
        '/directorio?tab=ubicaciones',
        '/agenda',
        '/reportes',
        '/perfil',
        '/finanzas',
        '/exportar',
      ];

      for (final route in visibleRoutes) {
        expect(shouldHideShellChrome(Uri.parse(route)), isFalse, reason: route);
      }
    });

    test('hides chrome on animal forms, details, and records', () {
      const overlayRoutes = <String>[
        '/directorio/animales/nuevo',
        '/directorio/animales/nuevo-rapido',
        '/directorio/animales/animal-1',
        '/directorio/animales/animal-1/editar',
        '/directorio/animales/animal-1/registros/peso',
        '/directorio/animales/animal-1/registros/reproduccion',
        '/directorio/animales/animal-1/registros/salud',
        '/directorio/animales/animal-1/registros/produccion',
        '/directorio/animales/animal-1/registros/movimiento',
        '/directorio/animales/animal-1/registros/comercial',
        '/directorio/animales/animal-1/registros/costo',
      ];

      for (final route in overlayRoutes) {
        expect(shouldHideShellChrome(Uri.parse(route)), isTrue, reason: route);
      }
    });

    test('hides chrome on lot and location descendants', () {
      const overlayRoutes = <String>[
        '/directorio/lotes/nuevo',
        '/directorio/lotes/lote-1',
        '/directorio/lotes/lote-1/editar',
        '/directorio/ubicaciones/nueva',
        '/directorio/ubicaciones/location-1',
        '/directorio/ubicaciones/location-1/editar',
      ];

      for (final route in overlayRoutes) {
        expect(shouldHideShellChrome(Uri.parse(route)), isTrue, reason: route);
      }
    });

    test('hides chrome on agenda and register overlays', () {
      const overlayRoutes = <String>[
        '/agenda/nuevo',
        '/registro',
        '/registro/sanitario',
        '/registro/peso',
        '/registro/produccion',
        '/registro/ordena',
        '/registro/reproduccion',
        '/registro/comercial',
        '/registro/movimiento',
        '/registro/costo',
        '/registro/ingreso',
        '/registro/gasto-general',
        '/registro/tratar-lote',
      ];

      for (final route in overlayRoutes) {
        expect(shouldHideShellChrome(Uri.parse(route)), isTrue, reason: route);
      }
    });

    test('ignores query parameters and fragments when classifying routes', () {
      expect(
        shouldHideShellChrome(
          Uri.parse('/directorio/animales/animal-1?from=dashboard#records'),
        ),
        isTrue,
      );
      expect(
        shouldHideShellChrome(Uri.parse('/directorio?tab=ubicaciones')),
        isFalse,
      );
    });

    test('does not match partial or unrelated segments', () {
      const visibleRoutes = <String>[
        '/registro-extra',
        '/agendaextra/nuevo',
        '/perfil/animales/demo',
        '/directorio/mis-animales/demo',
        '/directorio/animales',
        '/directorio/lotes',
        '/directorio/ubicaciones',
      ];

      for (final route in visibleRoutes) {
        expect(shouldHideShellChrome(Uri.parse(route)), isFalse, reason: route);
      }
    });
  });
}
