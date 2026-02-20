import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class UbicacionesBloc extends Bloc<UbicacionesEvent, UbicacionesState> {
  UbicacionesBloc(this.repository) : super(const UbicacionesInitial()) {
    on<LoadUbicaciones>(_onLoadUbicaciones);
    on<UbicacionesStreamUpdated>(_onStreamUpdated);
    on<UbicacionesStreamFailed>(_onStreamFailed);
    on<UpsertUbicacion>(_onUpsertUbicacion);
    on<DeleteUbicacion>(_onDeleteUbicacion);
    on<SearchUbicaciones>(_onSearchUbicaciones);
    on<AddVisitRecordEvent>(_onAddVisit);
    on<AddWaterRecordEvent>(_onAddWater);
    on<AddPastureRecordEvent>(_onAddPasture);
    on<AddSeedingRecordEvent>(_onAddSeeding);
    on<AddIrrigationRecordEvent>(_onAddIrrigation);
    on<AddRainRecordEvent>(_onAddRain);
    on<AddCostRecordEvent>(_onAddCost);
  }

  final LocationRepository repository;
  StreamSubscription<List<LocationEntity>>? _subscription;
  List<LocationEntity> _latest = const [];
  String _query = '';

  Future<void> _onLoadUbicaciones(
    LoadUbicaciones event,
    Emitter<UbicacionesState> emit,
  ) async {
    emit(const UbicacionesLoading());
    await _subscription?.cancel();
    _subscription = repository.watchAll().listen(
      (ubicaciones) => add(UbicacionesStreamUpdated(ubicaciones)),
      onError: (error, _) => add(UbicacionesStreamFailed(error.toString())),
    );
  }

  void _onStreamUpdated(
    UbicacionesStreamUpdated event,
    Emitter<UbicacionesState> emit,
  ) {
    _latest = event.ubicaciones;
    emit(UbicacionesLoaded(_applyFilter(_latest, _query)));
  }

  void _onStreamFailed(
    UbicacionesStreamFailed event,
    Emitter<UbicacionesState> emit,
  ) {
    emit(UbicacionesError(event.message));
  }

  Future<void> _onUpsertUbicacion(
    UpsertUbicacion event,
    Emitter<UbicacionesState> emit,
  ) async {
    try {
      emit(const UbicacionesLoading());
      await repository.upsert(event.ubicacion);
    } catch (e) {
      emit(UbicacionesError(e.toString()));
    }
  }

  Future<void> _onDeleteUbicacion(
    DeleteUbicacion event,
    Emitter<UbicacionesState> emit,
  ) async {
    try {
      emit(const UbicacionesLoading());
      await repository.deleteByUuid(event.uuid);
    } catch (e) {
      emit(UbicacionesError(e.toString()));
    }
  }

  Future<void> _onSearchUbicaciones(
    SearchUbicaciones event,
    Emitter<UbicacionesState> emit,
  ) async {
    _query = event.query.toLowerCase();
    emit(UbicacionesLoaded(_applyFilter(_latest, _query)));
  }

  Future<void> _onAddVisit(
    AddVisitRecordEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addVisit(event.uuid, event.record),
      emit,
    );
  }

  Future<void> _onAddWater(
    AddWaterRecordEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addWater(event.uuid, event.record),
      emit,
    );
  }

  Future<void> _onAddPasture(
    AddPastureRecordEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addPasture(event.uuid, event.record),
      emit,
    );
  }

  Future<void> _onAddSeeding(
    AddSeedingRecordEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addSeeding(event.uuid, event.record),
      emit,
    );
  }

  Future<void> _onAddIrrigation(
    AddIrrigationRecordEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addIrrigation(event.uuid, event.record),
      emit,
    );
  }

  Future<void> _onAddRain(
    AddRainRecordEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addRain(event.uuid, event.record),
      emit,
    );
  }

  Future<void> _onAddCost(
    AddCostRecordEvent event,
    Emitter<UbicacionesState> emit,
  ) async {
    await _wrapMutation(
      () => repository.addCost(event.uuid, event.record),
      emit,
    );
  }

  Future<void> _wrapMutation(
    Future<void> Function() action,
    Emitter<UbicacionesState> emit,
  ) async {
    try {
      await action();
    } catch (e) {
      emit(UbicacionesError(e.toString()));
    }
  }

  List<LocationEntity> _applyFilter(List<LocationEntity> source, String query) {
    if (query.isEmpty) return source;
    return source
        .where((u) => u.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
