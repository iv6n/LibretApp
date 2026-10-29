import 'package:equatable/equatable.dart';

/// Shared write-boundary guard, including embedded records and attributes.
void requireFiniteNumbers(Object? value) {
  if (value is num && !value.isFinite) {
    throw ArgumentError('Los valores numéricos deben ser finitos.');
  }
  if (value is Equatable) requireFiniteNumbers(value.props);
  if (value is Map) for (final child in value.values) { requireFiniteNumbers(child); }
  if (value is Iterable) for (final child in value) { requireFiniteNumbers(child); }
}
