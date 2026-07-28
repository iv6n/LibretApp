import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/utils/number_parsing.dart';

void main() {
  group('parseFormDouble', () {
    test('parses a plain decimal', () {
      expect(parseFormDouble('12.5'), 12.5);
    });

    test('tolerates a comma decimal separator', () {
      expect(parseFormDouble('12,5'), 12.5);
    });

    test('trims surrounding whitespace', () {
      expect(parseFormDouble('  12.5  '), 12.5);
    });

    test('returns null for an empty value', () {
      expect(parseFormDouble(''), isNull);
      expect(parseFormDouble('   '), isNull);
    });

    test('returns null for an invalid value', () {
      expect(parseFormDouble('not a number'), isNull);
    });
  });

  group('parseFormInt', () {
    test('parses a plain integer', () {
      expect(parseFormInt('42'), 42);
    });

    test('trims surrounding whitespace', () {
      expect(parseFormInt('  42  '), 42);
    });

    test('returns null for an empty value', () {
      expect(parseFormInt(''), isNull);
      expect(parseFormInt('   '), isNull);
    });

    test('returns null for an invalid value', () {
      expect(parseFormInt('4.5'), isNull);
      expect(parseFormInt('not a number'), isNull);
    });
  });
}
