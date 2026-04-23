/// Shared UI timing and duration constants used across the app.
///
/// Centralizes magic numbers that were previously hardcoded in multiple places.
class UiConstants {
  UiConstants._();

  /// Debounce duration for search inputs (used in BLoC event transformers).
  static const Duration searchDebounceDuration = Duration(milliseconds: 260);

  /// Standard modal/page transition duration.
  static const Duration modalTransitionDuration = Duration(milliseconds: 260);

  /// Standard modal/page reverse transition duration.
  static const Duration modalReverseTransitionDuration = Duration(
    milliseconds: 220,
  );
}
