import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';

void main() {
  final start = DateTime(2025, 1, 1);
  final end = DateTime(2025, 1, 31);
  final range = DateRange(start: start, end: end);

  group('DateRange.contains', () {
    test('returns false for a date strictly before start', () {
      expect(range.contains(DateTime(2024, 12, 31)), isFalse);
    });

    test('returns true for exactly start (inclusive lower bound)', () {
      expect(range.contains(start), isTrue);
    });

    test('returns true for a date inside the range', () {
      expect(range.contains(DateTime(2025, 1, 15)), isTrue);
    });

    test('returns true for exactly end (inclusive upper bound)', () {
      expect(range.contains(end), isTrue);
    });

    test('returns false for a date strictly after end', () {
      expect(range.contains(DateTime(2025, 2, 1)), isFalse);
    });

    test('single-day range includes only that day', () {
      final single = DateRange(
        start: DateTime(2025, 6, 1),
        end: DateTime(2025, 6, 1),
      );
      expect(single.contains(DateTime(2025, 5, 31)), isFalse);
      expect(single.contains(DateTime(2025, 6, 1)), isTrue);
      expect(single.contains(DateTime(2025, 6, 2)), isFalse);
    });

    test('always returns false when start is after end (inverted range)', () {
      final inverted = DateRange(
        start: DateTime(2025, 12, 31),
        end: DateTime(2025, 1, 1),
      );
      expect(inverted.contains(DateTime(2025, 6, 15)), isFalse);
      expect(inverted.contains(DateTime(2025, 1, 1)), isFalse);
      expect(inverted.contains(DateTime(2025, 12, 31)), isFalse);
    });
  });

  group('DateRange equality', () {
    test('two ranges with same start and end are equal', () {
      final a = DateRange(start: start, end: end);
      final b = DateRange(start: start, end: end);
      expect(a, equals(b));
    });

    test('ranges with different start are not equal', () {
      expect(
        range,
        isNot(equals(DateRange(start: DateTime(2025, 2, 1), end: end))),
      );
    });

    test('ranges with different end are not equal', () {
      expect(
        range,
        isNot(equals(DateRange(start: start, end: DateTime(2025, 2, 28)))),
      );
    });
  });
}
