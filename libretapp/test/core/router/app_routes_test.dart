import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/router/app_routes.dart';

void main() {
  test('animal report filters are represented in the directory route', () {
    expect(
      AppRoutes.animalesPath(healthFilter: 'pending', clearFilters: true),
      '/directorio?tab=animales&clearFilters=true&health=pending',
    );
    expect(
      AppRoutes.animalesPath(healthFilter: 'unvaccinated', clearFilters: true),
      '/directorio?tab=animales&clearFilters=true&health=unvaccinated',
    );
  });

  test('unsupported animal health filters are omitted', () {
    expect(
      AppRoutes.animalesPath(healthFilter: 'other'),
      '/directorio?tab=animales',
    );
  });
}
