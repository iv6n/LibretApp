import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/finanzas/domain/entities/general_expense_record.dart';

void main() {
  group('GeneralExpenseType.label', () {
    test('fuel', () => expect(GeneralExpenseType.fuel.label, 'Combustible'));
    test(
      'equipment',
      () =>
          expect(GeneralExpenseType.equipment.label, 'Equipos / Herramientas'),
    );
    test(
      'infrastructure',
      () => expect(GeneralExpenseType.infrastructure.label, 'Infraestructura'),
    );
    test(
      'utilities',
      () =>
          expect(GeneralExpenseType.utilities.label, 'Servicios / Utilidades'),
    );
    test('labor', () => expect(GeneralExpenseType.labor.label, 'Mano de obra'));
    test(
      'taxes',
      () => expect(GeneralExpenseType.taxes.label, 'Impuestos / Tasas'),
    );
    test('other', () => expect(GeneralExpenseType.other.label, 'Otro'));

    test('every enum value has a non-empty label', () {
      for (final type in GeneralExpenseType.values) {
        expect(
          type.label,
          isNotEmpty,
          reason: '${type.name} has an empty label',
        );
      }
    });
  });

  group('GeneralExpenseRecord.copyWith', () {
    final base = GeneralExpenseRecord(
      date: DateTime(2025, 5, 15),
      type: GeneralExpenseType.fuel,
      amount: 80.0,
      currency: 'USD',
      notes: 'gasoil',
      id: '42',
    );

    test('returns an equal record when no overrides are given', () {
      expect(base.copyWith(), equals(base));
    });

    test('overrides amount while preserving other fields', () {
      final copy = base.copyWith(amount: 150.0);
      expect(copy.amount, 150.0);
      expect(copy.type, base.type);
      expect(copy.date, base.date);
      expect(copy.currency, base.currency);
    });

    test('overrides type correctly', () {
      final copy = base.copyWith(type: GeneralExpenseType.labor);
      expect(copy.type, GeneralExpenseType.labor);
      expect(copy.amount, base.amount);
    });

    test('overrides date correctly', () {
      final newDate = DateTime(2026, 1, 1);
      final copy = base.copyWith(date: newDate);
      expect(copy.date, newDate);
      expect(copy.amount, base.amount);
    });

    test('overrides notes correctly', () {
      final copy = base.copyWith(notes: 'updated notes');
      expect(copy.notes, 'updated notes');
    });

    test('overrides currency correctly', () {
      final copy = base.copyWith(currency: 'EUR');
      expect(copy.currency, 'EUR');
    });
  });
}
