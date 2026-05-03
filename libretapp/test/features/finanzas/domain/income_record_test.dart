import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';

void main() {
  group('IncomeType.label', () {
    test('milkSale', () => expect(IncomeType.milkSale.label, 'Venta de leche'));
    test('woolSale', () => expect(IncomeType.woolSale.label, 'Venta de lana'));
    test('service', () => expect(IncomeType.service.label, 'Servicio'));
    test('subsidy', () => expect(IncomeType.subsidy.label, 'Subsidio / Ayuda'));
    test('other', () => expect(IncomeType.other.label, 'Otro'));

    test('every enum value has a non-empty label', () {
      for (final type in IncomeType.values) {
        expect(
          type.label,
          isNotEmpty,
          reason: '${type.name} has an empty label',
        );
      }
    });
  });

  group('IncomeRecord.copyWith', () {
    final base = IncomeRecord(
      date: DateTime(2025, 3, 1),
      type: IncomeType.milkSale,
      amount: 100.0,
      currency: 'USD',
      animalUuid: 'uuid-abc',
      notes: 'original',
      id: '1',
    );

    test('returns an equal record when no overrides are given', () {
      expect(base.copyWith(), equals(base));
    });

    test('overrides amount while preserving other fields', () {
      final copy = base.copyWith(amount: 250.0);
      expect(copy.amount, 250.0);
      expect(copy.type, base.type);
      expect(copy.date, base.date);
      expect(copy.currency, base.currency);
    });

    test('overrides type correctly', () {
      final copy = base.copyWith(type: IncomeType.woolSale);
      expect(copy.type, IncomeType.woolSale);
      expect(copy.amount, base.amount);
    });

    test('overrides date correctly', () {
      final newDate = DateTime(2025, 12, 31);
      final copy = base.copyWith(date: newDate);
      expect(copy.date, newDate);
      expect(copy.amount, base.amount);
    });

    test('overrides animalUuid correctly', () {
      final copy = base.copyWith(animalUuid: 'uuid-xyz');
      expect(copy.animalUuid, 'uuid-xyz');
    });

    test('overrides notes correctly', () {
      final copy = base.copyWith(notes: 'updated');
      expect(copy.notes, 'updated');
    });
  });
}
