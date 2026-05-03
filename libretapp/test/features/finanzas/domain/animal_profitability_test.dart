import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/finanzas/domain/entities/animal_profitability.dart';

AnimalProfitability _make({
  String uuid = 'uuid-test',
  String name = 'Animal Test',
  double purchaseCost = 0,
  double totalCosts = 0,
  double saleRevenue = 0,
}) {
  return AnimalProfitability(
    animalUuid: uuid,
    animalName: name,
    purchaseCost: purchaseCost,
    totalCosts: totalCosts,
    saleRevenue: saleRevenue,
  );
}

void main() {
  group('AnimalProfitability.netResult', () {
    test('is positive when saleRevenue exceeds purchaseCost + totalCosts', () {
      final p = _make(purchaseCost: 500, totalCosts: 200, saleRevenue: 1000);
      expect(p.netResult, 300.0); // 1000 - 500 - 200
    });

    test('is negative when costs exceed saleRevenue', () {
      final p = _make(purchaseCost: 800, totalCosts: 400, saleRevenue: 600);
      expect(p.netResult, -600.0); // 600 - 800 - 400
    });

    test('is zero at exact break-even', () {
      final p = _make(purchaseCost: 300, totalCosts: 100, saleRevenue: 400);
      expect(p.netResult, 0.0);
    });

    test('is zero when all amounts are zero', () {
      expect(_make().netResult, 0.0);
    });

    test('includes purchaseCost in the deduction', () {
      final withPurchase = _make(purchaseCost: 200, saleRevenue: 300);
      final withoutPurchase = _make(purchaseCost: 0, saleRevenue: 300);
      expect(withPurchase.netResult, lessThan(withoutPurchase.netResult));
    });
  });

  group('AnimalProfitability.isProfitable', () {
    test('is true when netResult is positive', () {
      expect(
        _make(purchaseCost: 100, totalCosts: 50, saleRevenue: 300).isProfitable,
        isTrue,
      );
    });

    test('is false when netResult is negative', () {
      expect(
        _make(
          purchaseCost: 500,
          totalCosts: 100,
          saleRevenue: 200,
        ).isProfitable,
        isFalse,
      );
    });

    test('is true at exact break-even (netResult == 0)', () {
      expect(
        _make(
          purchaseCost: 200,
          totalCosts: 100,
          saleRevenue: 300,
        ).isProfitable,
        isTrue,
      );
    });

    test('is false when only totalCosts makes it negative', () {
      expect(_make(totalCosts: 50, saleRevenue: 30).isProfitable, isFalse);
    });
  });

  group('AnimalProfitability equality', () {
    test('two instances with same values are equal', () {
      const a = AnimalProfitability(
        animalUuid: 'uuid-1',
        animalName: 'Vaca',
        purchaseCost: 100,
        totalCosts: 50,
        saleRevenue: 300,
      );
      const b = AnimalProfitability(
        animalUuid: 'uuid-1',
        animalName: 'Vaca',
        purchaseCost: 100,
        totalCosts: 50,
        saleRevenue: 300,
      );
      expect(a, equals(b));
    });

    test('different saleRevenue makes them unequal', () {
      const a = AnimalProfitability(
        animalUuid: 'u',
        animalName: 'x',
        purchaseCost: 0,
        totalCosts: 0,
        saleRevenue: 100,
      );
      const b = AnimalProfitability(
        animalUuid: 'u',
        animalName: 'x',
        purchaseCost: 0,
        totalCosts: 0,
        saleRevenue: 200,
      );
      expect(a, isNot(equals(b)));
    });
  });
}
