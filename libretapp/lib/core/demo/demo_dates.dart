/// core › demo › demo_dates — date helpers shared by the demo builders.
///
/// Every relative date in the scenario (a vaccination six months ago, a
/// calving due in ten days) is derived from the caller-supplied reference
/// date, never from `DateTime.now()` directly — that is what makes the
/// scenario reproducible under a fixed `referenceDate` in tests. These
/// helpers exist so builders spell that arithmetic the same way everywhere.
library;

/// [reference] minus [months] calendar months, same day-of-month.
///
/// Dart's `DateTime` constructor normalizes an out-of-range month by rolling
/// the year, so `monthsBefore(DateTime(2026, 2, 1), 3)` correctly yields
/// `2025-11-01` without manual year-borrowing logic.
DateTime monthsBefore(DateTime reference, int months) {
  return DateTime(reference.year, reference.month - months, reference.day);
}

/// [reference] plus [months] calendar months, same day-of-month.
DateTime monthsAfter(DateTime reference, int months) =>
    monthsBefore(reference, -months);

/// [reference] minus [days], at local midnight — the shape every date in the
/// scenario uses so two records on "the same day" compare equal.
DateTime daysBefore(DateTime reference, int days) => DateTime(
  reference.year,
  reference.month,
  reference.day,
).subtract(Duration(days: days));

/// [reference] plus [days], at local midnight.
DateTime daysAfter(DateTime reference, int days) =>
    daysBefore(reference, -days);
