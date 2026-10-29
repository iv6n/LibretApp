/// Approximate animal age represented as years and remaining months.
library;

import 'dart:math' as math;

class ApproximateAge {
  const ApproximateAge({
    required this.years,
    required this.months,
    this.isUnknown = false,
  }) : assert(years >= 0 && years <= maxYears),
       assert(months >= 0 && months <= 11);

  factory ApproximateAge.fromTotalMonths(int totalMonths) {
    if (totalMonths < 0) return const ApproximateAge.unknown();
    final safeMonths = totalMonths.clamp(0, maxTotalMonths);
    return ApproximateAge(years: safeMonths ~/ 12, months: safeMonths % 12);
  }

  const ApproximateAge.unknown() : years = 0, months = 0, isUnknown = true;

  static const int maxYears = 30;
  static const int maxTotalMonths = maxYears * 12 + 11;

  final int years;
  final int months;
  final bool isUnknown;

  int get totalMonths => isUnknown ? -1 : years * 12 + months;

  String get displayLabel {
    if (isUnknown) return 'No lo sé';
    if (totalMonths == 0) return 'Recién nacido';
    final parts = <String>[];
    if (years > 0) {
      parts.add('$years año${years == 1 ? '' : 's'}');
    }
    if (months > 0) {
      parts.add('$months mes${months == 1 ? '' : 'es'}');
    }
    return parts.join(' ');
  }

  DateTime estimatedBirthDate([DateTime? reference]) {
    final now = reference ?? DateTime.now();
    final targetYear = now.year - years;
    var targetMonth = now.month - months;
    var normalizedYear = targetYear;
    while (targetMonth <= 0) {
      targetMonth += 12;
      normalizedYear -= 1;
    }
    final lastDay = DateTime(normalizedYear, targetMonth + 1, 0).day;
    return DateTime(normalizedYear, targetMonth, math.min(now.day, lastDay));
  }

  @override
  bool operator ==(Object other) =>
      other is ApproximateAge &&
      other.years == years &&
      other.months == months &&
      other.isUnknown == isUnknown;

  @override
  int get hashCode => Object.hash(years, months, isUnknown);
}
