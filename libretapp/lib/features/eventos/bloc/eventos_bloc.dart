import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/eventos/bloc/eventos_event.dart';
import 'package:libretapp/features/eventos/bloc/eventos_state.dart';
import 'package:libretapp/features/eventos/data/eventos_repository.dart';

class EventosBloc extends Bloc<EventosEvent, EventosState> {
  EventosBloc(this.repository) : super(const EventosInitial()) {
    on<LoadEventos>(_onLoadEventos);
    on<AddEvento>(_onAddEvento);
    on<UpdateEvento>(_onUpdateEvento);
    on<DeleteEvento>(_onDeleteEvento);
    on<SearchEventos>(_onSearchEventos);
  }
  final EventosRepository repository;

  Future<void> _onLoadEventos(
    LoadEventos event,
    Emitter<EventosState> emit,
  ) async {
    emit(const EventosLoading());
    try {
      final eventos = await repository.fetchEventos();
      emit(EventosLoaded(eventos));
    } catch (e) {
      emit(EventosError(e.toString()));
    }
  }

  Future<void> _onAddEvento(AddEvento event, Emitter<EventosState> emit) async {
    try {
      await repository.saveEvento(event.evento);
      final eventos = await repository.fetchEventos();
      emit(EventosLoaded(eventos));
    } catch (e) {
      emit(EventosError(e.toString()));
    }
  }

  Future<void> _onUpdateEvento(
    UpdateEvento event,
    Emitter<EventosState> emit,
  ) async {
    try {
      await repository.updateEvento(event.evento);
      final eventos = await repository.fetchEventos();
      emit(EventosLoaded(eventos));
    } catch (e) {
      emit(EventosError(e.toString()));
    }
  }

  Future<void> _onDeleteEvento(
    DeleteEvento event,
    Emitter<EventosState> emit,
  ) async {
    try {
      await repository.deleteEvento(event.id);
      final eventos = await repository.fetchEventos();
      emit(EventosLoaded(eventos));
    } catch (e) {
      emit(EventosError(e.toString()));
    }
  }

  Future<void> _onSearchEventos(
    SearchEventos event,
    Emitter<EventosState> emit,
  ) async {
    try {
      final eventos = await repository.fetchEventos();
      final filtered = eventos
          .where(
            (e) => e.titulo.toLowerCase().contains(event.query.toLowerCase()),
          )
          .toList();
      emit(EventosLoaded(filtered));
    } catch (e) {
      emit(EventosError(e.toString()));
    }
  }
}
