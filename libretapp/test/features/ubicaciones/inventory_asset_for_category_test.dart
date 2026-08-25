import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/inventory_item.dart';

void main() {
  group('InventoryCategoryX.assetPath', () {
    test('maps generated inventory categories to their specific assets', () {
      expect(
        InventoryCategory.feed.assetPath,
        'assets/images/inventory_feed.webp',
      );
      expect(
        InventoryCategory.medicine.assetPath,
        'assets/images/inventory_medicine.webp',
      );
      expect(
        InventoryCategory.tool.assetPath,
        'assets/images/inventory_tool.webp',
      );
    });

    test(
      'keeps Material fallback for categories without a generated asset',
      () {
        expect(InventoryCategory.equipment.assetPath, isNull);
        expect(InventoryCategory.other.assetPath, isNull);
      },
    );
  });
}
