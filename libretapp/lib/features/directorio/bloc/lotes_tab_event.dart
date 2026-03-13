import 'package:equatable/equatable.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';

abstract class LotesTabEvent extends Equatable {
  const LotesTabEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar los lotes
class LoadLotesTab extends LotesTabEvent {
  const LoadLotesTab();
}

/// Evento para filtrar lotes por búsqueda
class SearchLotesTab extends LotesTabEvent {
  const SearchLotesTab(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

/// Evento cuando el stream de lotes se actualiza
class LotesTabStreamUpdated extends LotesTabEvent {
  const LotesTabStreamUpdated(this.lotes);

  final List<LoteEntity> lotes;

  @override
  List<Object> get props => [lotes];
}

/// Evento cuando hay error en el stream
class LotesTabStreamFailed extends LotesTabEvent {
  const LotesTabStreamFailed(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
