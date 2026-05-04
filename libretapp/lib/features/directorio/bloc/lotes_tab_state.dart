/// features \u203a directorio \u203a bloc \u203a lotes_tab_state \u2014 state for LotesTabBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';

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

  final List<LoteEntity> lotes;
  final List<LoteEntity>? filteredLotes;

  /// Devuelve los lotes a mostrar (filtrados o todos)
  List<LoteEntity> get displayLotes => filteredLotes ?? lotes;

  LotesTabLoaded copyWith({
    List<LoteEntity>? lotes,
    List<LoteEntity>? filteredLotes,
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
