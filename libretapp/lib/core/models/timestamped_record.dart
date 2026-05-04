/// core › models › timestamped_record — mixin for records with created/updated timestamps.
library;

import 'package:equatable/equatable.dart';

/// Base class for all timestamped records (animal records, location records).
///
/// Every record in the system has at least a [date] field and optional [notes].
/// Most also have an optional [id] for persistence tracking.
///
/// Subclasses must override [props] and include `super.props` spread:
/// ```dart
/// @override
/// List<Object?> get props => [...super.props, type, amount];
/// ```
abstract class TimestampedRecord extends Equatable {
  const TimestampedRecord({required this.date, this.notes, this.id});

  final DateTime date;
  final String? notes;
  final String? id;

  @override
  List<Object?> get props => [date, notes, id];
}
