/// registro › bloc › RegistroState
///
/// Immutable state for [RegistroBloc]. Tracks the submission lifecycle
/// for all registro form pages.
///
/// Layer: application (state management)
library;

import 'package:equatable/equatable.dart';

/// Possible statuses for a registro submission.
enum RegistroStatus {
  /// No submission in progress.
  idle,

  /// A save operation is running.
  loading,

  /// The record was persisted successfully.
  success,

  /// The save operation failed; see [RegistroState.errorMessage].
  failure,
}

/// State emitted by [RegistroBloc].
class RegistroState extends Equatable {
  /// Creates an idle [RegistroState].
  const RegistroState({this.status = RegistroStatus.idle, this.errorMessage});

  /// Current submission status.
  final RegistroStatus status;

  /// Human-readable error description when [status] is [RegistroStatus.failure].
  final String? errorMessage;

  /// Returns a copy of this state with the provided fields replaced.
  RegistroState copyWith({RegistroStatus? status, String? errorMessage}) {
    return RegistroState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Convenience factory for the idle (reset) state.
  factory RegistroState.initial() => const RegistroState();

  @override
  List<Object?> get props => [status, errorMessage];
}
