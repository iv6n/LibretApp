/// features \u203a directorio \u203a lotes \u203a bloc \u203a lotes_state \u2014 state for LotesBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';

abstract class LotesState extends Equatable {
  const LotesState();

  @override
  List<Object> get props => [];
}

/// Estado inicial del Bloc de lotes
class LotesInitial extends LotesState {
  const LotesInitial();
}

/// Estado cuando se están cargando los lotes
class LotesLoading extends LotesState {
  const LotesLoading();
}

/// Estado cuando los lotes se han cargado exitosamente
class LotesLoaded extends LotesState {
  const LotesLoaded({required this.lotes, this.selectedLoteUuid});

  /// Lista de todos los lotes disponibles
  final List<LoteEntity> lotes;

  /// UUID del lote seleccionado actualmente (si aplica)
  final String? selectedLoteUuid;

  /// Obtiene el lote seleccionado si existe
  LoteEntity? get selectedLote {
    if (selectedLoteUuid == null) return null;
    try {
      return lotes.firstWhere((l) => l.uuid == selectedLoteUuid);
    } catch (e) {
      return null;
    }
  }

  /// Filtra los lotes activos
  List<LoteEntity> get activeLotes => lotes.where((l) => l.activo).toList();

  /// Filtra los lotes inactivos/cerrados
  List<LoteEntity> get inactiveLotes => lotes.where((l) => !l.activo).toList();

  LotesLoaded copyWith({List<LoteEntity>? lotes, String? selectedLoteUuid}) {
    return LotesLoaded(
      lotes: lotes ?? this.lotes,
      selectedLoteUuid: selectedLoteUuid ?? this.selectedLoteUuid,
    );
  }

  @override
  List<Object> get props => [lotes, selectedLoteUuid ?? ''];
}

/// Estado cuando ocurre un error al procesar lotes
class LotesError extends LotesState {
  const LotesError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

/// Estado cuando se está realizando una acción (crear, actualizar, eliminar)
class LotesActionInProgress extends LotesState {
  const LotesActionInProgress({required this.action, required this.lotes});

  /// Descripción de la acción en progreso
  final String action;

  /// Lista de lotes actual mientras se ejecuta la acción
  final List<LoteEntity> lotes;

  @override
  List<Object> get props => [action, lotes];
}

/// Estado cuando se completó una acción exitosamente
class LotesActionSuccess extends LotesState {
  const LotesActionSuccess({
    required this.action,
    required this.lotes,
    this.message,
  });

  /// Descripción de la acción completada
  final String action;

  /// Lista de lotes actualizada
  final List<LoteEntity> lotes;

  /// Mensaje de éxito (opcional)
  final String? message;

  @override
  List<Object> get props => [action, lotes, message ?? ''];
}
