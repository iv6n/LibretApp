/// core › utils › number_parsing — locale-tolerant numeric field parsing shared by registro forms.
library;

/// Parses a form field as a double, tolerating a comma decimal separator
/// and surrounding whitespace. Returns `null` for an empty or invalid value.
double? parseFormDouble(String raw) {
  final normalized = raw.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

/// Parses a form field as an int, tolerating surrounding whitespace.
/// Returns `null` for an empty or invalid value.
int? parseFormInt(String raw) {
  final normalized = raw.trim();
  if (normalized.isEmpty) return null;
  return int.tryParse(normalized);
}
