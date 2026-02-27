import 'package:equatable/equatable.dart';

abstract class LotesTabState extends Equatable {
  const LotesTabState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class LotesTabInitial extends LotesTabState {
  const LotesTabInitial();
}

/// Estado cargando
class LotesTabLoading extends LotesTabState {
  const LotesTabLoading();
}

/// Estado cargado
class LotesTabLoaded extends LotesTabState {
  const LotesTabLoaded({required this.lotes, this.filteredLotes});

  final List<dynamic> lotes;
  final List<dynamic>? filteredLotes;

  /// Devuelve los lotes a mostrar (filtrados o todos)
  List<dynamic> get displayLotes => filteredLotes ?? lotes;

  LotesTabLoaded copyWith({
    List<dynamic>? lotes,
    List<dynamic>? filteredLotes,
  }) {
    return LotesTabLoaded(
      lotes: lotes ?? this.lotes,
      filteredLotes: filteredLotes ?? this.filteredLotes,
    );
  }

  @override
  List<Object?> get props => [lotes, filteredLotes];
}

/// Estado con error
class LotesTabError extends LotesTabState {
  const LotesTabError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
