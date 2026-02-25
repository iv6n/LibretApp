import 'package:equatable/equatable.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';

abstract class UbicacionesEvent extends Equatable {
  const UbicacionesEvent();

  @override
  List<Object> get props => [];
}

class LoadUbicaciones extends UbicacionesEvent {
  const LoadUbicaciones();
}

class UpsertUbicacion extends UbicacionesEvent {
  final LocationEntity ubicacion;

  const UpsertUbicacion(this.ubicacion);

  @override
  List<Object> get props => [ubicacion];
}

class DeleteUbicacion extends UbicacionesEvent {
  final String uuid;

  const DeleteUbicacion(this.uuid);

  @override
  List<Object> get props => [uuid];
}

class SearchUbicaciones extends UbicacionesEvent {
  final String query;

  const SearchUbicaciones(this.query);

  @override
  List<Object> get props => [query];
}

class ToggleSearch extends UbicacionesEvent {
  final bool enabled;

  const ToggleSearch({required this.enabled});

  @override
  List<Object> get props => [enabled];
}

class SearchQueryChanged extends UbicacionesEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

class ClearSearch extends UbicacionesEvent {}

class UbicacionesStreamUpdated extends UbicacionesEvent {
  final List<LocationEntity> ubicaciones;

  const UbicacionesStreamUpdated(this.ubicaciones);

  @override
  List<Object> get props => [ubicaciones];
}

class UbicacionesStreamFailed extends UbicacionesEvent {
  final String message;

  const UbicacionesStreamFailed(this.message);

  @override
  List<Object> get props => [message];
}

class AddVisitRecordEvent extends UbicacionesEvent {
  final String uuid;
  final VisitRecord record;

  const AddVisitRecordEvent(this.uuid, this.record);

  @override
  List<Object> get props => [uuid, record];
}

class AddWaterRecordEvent extends UbicacionesEvent {
  final String uuid;
  final WaterRecord record;

  const AddWaterRecordEvent(this.uuid, this.record);

  @override
  List<Object> get props => [uuid, record];
}

class AddPastureRecordEvent extends UbicacionesEvent {
  final String uuid;
  final PastureRecord record;

  const AddPastureRecordEvent(this.uuid, this.record);

  @override
  List<Object> get props => [uuid, record];
}

class AddSeedingRecordEvent extends UbicacionesEvent {
  final String uuid;
  final SeedingRecord record;

  const AddSeedingRecordEvent(this.uuid, this.record);

  @override
  List<Object> get props => [uuid, record];
}

class AddIrrigationRecordEvent extends UbicacionesEvent {
  final String uuid;
  final IrrigationRecord record;

  const AddIrrigationRecordEvent(this.uuid, this.record);

  @override
  List<Object> get props => [uuid, record];
}

class AddRainRecordEvent extends UbicacionesEvent {
  final String uuid;
  final RainRecord record;

  const AddRainRecordEvent(this.uuid, this.record);

  @override
  List<Object> get props => [uuid, record];
}

class AddCostRecordEvent extends UbicacionesEvent {
  final String uuid;
  final CostRecord record;

  const AddCostRecordEvent(this.uuid, this.record);

  @override
  List<Object> get props => [uuid, record];
}
