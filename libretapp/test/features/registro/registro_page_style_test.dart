import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/widgets/generated_asset_icon.dart';
import 'package:libretapp/features/registro/view/registro_page.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await locator.reset();
    locator.registerSingleton<LocationRepository>(_FakeLocationRepository());
  });

  tearDown(() async {
    await locator.reset();
  });

  testWidgets('los iconos principales son cuadrados y las flechas circulares', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const RegistroPage()),
    );
    await tester.pumpAndSettle();

    final mainIconContainers = _decoratedContainers(tester).where((container) {
      final decoration = container.decoration! as BoxDecoration;
      return decoration.shape == BoxShape.rectangle &&
          decoration.borderRadius != null;
    }).toList();
    final chevronContainers = _decoratedContainers(tester).where((container) {
      final decoration = container.decoration! as BoxDecoration;
      return decoration.shape == BoxShape.circle;
    }).toList();

    // The animal menu includes the commercial registration card in addition
    // to the original twelve cards.
    expect(mainIconContainers, hasLength(13));
    expect(
      mainIconContainers.where(
        (container) => _sizeOf(tester, container).width == 60,
      ),
      hasLength(3),
    );
    expect(
      mainIconContainers.where(
        (container) => _sizeOf(tester, container).width == 48,
      ),
      hasLength(10),
    );
    expect(chevronContainers, hasLength(13));

    final generatedIconSizes = tester
        .widgetList<GeneratedAssetIcon>(find.byType(GeneratedAssetIcon))
        .map((icon) => icon.size)
        .toList();
    expect(generatedIconSizes, contains(34));
    expect(generatedIconSizes, contains(26));

    final generatedAssetPaths = tester
        .widgetList<GeneratedAssetIcon>(find.byType(GeneratedAssetIcon))
        .map((icon) => icon.assetPath)
        .toSet();
    expect(generatedAssetPaths, contains('assets/images/record_animal.webp'));
    expect(generatedAssetPaths, contains('assets/images/record_lot.webp'));

    await tester.tap(find.text('Ubicacion'));
    await tester.pumpAndSettle();

    final locationIconContainers = _decoratedContainers(tester).where((
      container,
    ) {
      final decoration = container.decoration! as BoxDecoration;
      return decoration.shape == BoxShape.rectangle &&
          decoration.borderRadius != null;
    });
    expect(locationIconContainers, isNotEmpty);
    expect(
      locationIconContainers.every(
        (container) => _sizeOf(tester, container).width == 48,
      ),
      isTrue,
    );
  });
}

List<Container> _decoratedContainers(WidgetTester tester) => tester
    .widgetList<Container>(find.byType(Container))
    .where((container) => container.decoration is BoxDecoration)
    .toList();

Size _sizeOf(WidgetTester tester, Container container) =>
    tester.getSize(find.byWidget(container));

class _FakeLocationRepository implements LocationRepository {
  @override
  Future<List<LocationEntity>> getAll() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
