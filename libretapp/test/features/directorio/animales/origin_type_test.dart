/// Guards the migration from the old free-text `originType` column.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/origin_type.dart';

void main() {
  group('OriginType.fromStored', () {
    test('reads the enum names the registration wizard writes', () {
      expect(OriginType.fromStored('own'), OriginType.own);
      expect(OriginType.fromStored('purchased'), OriginType.purchased);
      expect(OriginType.fromStored('gift'), OriginType.gift);
    });

    test('reads the Spanish labels older builds stored', () {
      // 'Compra' is the value that actually shows up in existing fixtures.
      expect(OriginType.fromStored('Compra'), OriginType.purchased);
      expect(OriginType.fromStored('Comprado'), OriginType.purchased);
      expect(OriginType.fromStored('Propio'), OriginType.own);
      expect(OriginType.fromStored('Regalo'), OriginType.gift);
      expect(
        OriginType.fromStored('Regalo / Intercambio'),
        OriginType.gift,
      );
    });

    test('ignores casing and surrounding whitespace', () {
      expect(OriginType.fromStored('  PURCHASED '), OriginType.purchased);
      expect(OriginType.fromStored('propio'), OriginType.own);
    });

    test('returns null instead of guessing an origin', () {
      // Defaulting to `own` here would silently relabel a purchased animal as
      // farm-born, which is exactly the claim traceability depends on.
      expect(OriginType.fromStored(null), isNull);
      expect(OriginType.fromStored(''), isNull);
      expect(OriginType.fromStored('   '), isNull);
      expect(OriginType.fromStored('cualquier cosa'), isNull);
    });

    test('round trips through the stored name', () {
      for (final value in OriginType.values) {
        expect(OriginType.fromStored(value.name), value);
      }
    });
  });
}
