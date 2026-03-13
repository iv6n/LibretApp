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
  const UpsertUbicacion(this.ubicacion);
  final LocationEntity ubicacion;

  @override
  List<Object> get props => [ubicacion];
}

class DeleteUbicacion extends UbicacionesEvent {
  const DeleteUbicacion(this.uuid);
  final String uuid;

  @override
  List<Object> get props => [uuid];
}

class SearchUbicaciones extends UbicacionesEvent {
  const SearchUbicaciones(this.query);
  final String query;

  @override
  List<Object> get props => [query];
}

class ToggleSearch extends UbicacionesEvent {
  const ToggleSearch({required this.enabled});
  final bool enabled;

  @override
  List<Object> get props => [enabled];
}

class SearchQueryChanged extends UbicacionesEvent {
  const SearchQueryChanged(this.query);
  final String query;

  @override
  List<Object> get props => [query];
}

class ClearSearch extends UbicacionesEvent {}

class UbicacionesStreamUpdated extends UbicacionesEvent {
  const UbicacionesStreamUpdated(this.ubicaciones);
  final List<LocationEntity> ubicaciones;

  @override
  List<Object> get props => [ubicaciones];
}

class UbicacionesStreamFailed extends UbicacionesEvent {
  const UbicacionesStreamFailed(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class AddVisitRecordEvent extends UbicacionesEvent {
  const AddVisitRecordEvent(this.uuid, this.record);
  final String uuid;
  final VisitRecord record;

  @override
  List<Object> get props => [uuid, record];
}

class AddWaterRecordEvent extends UbicacionesEvent {
  const AddWaterRecordEvent(this.uuid, this.record);
  final String uuid;
  final WaterRecord record;

  @override
  List<Object> get props => [uuid, record];
}

class AddSaltRecordEvent extends UbicacionesEvent {
  const AddSaltRecordEvent(this.uuid, this.record);
  final String uuid;
  final SaltRecord record;

  @override
  List<Object> get props => [uuid, record];
}

class AddShadeRecordEvent extends UbicacionesEvent {
  const AddShadeRecordEvent(this.uuid, this.record);
  final String uuid;
  final ShadeRecord record;

  @override
  List<Object> get props => [uuid, record];
}

class AddPastureRecordEvent extends UbicacionesEvent {
  const AddPastureRecordEvent(this.uuid, this.record);
  final String uuid;
  final PastureRecord record;

  @override
  List<Object> get props => [uuid, record];
}

class AddSeedingRecordEvent extends UbicacionesEvent {
  const AddSeedingRecordEvent(this.uuid, this.record);
  final String uuid;
  final SeedingRecord record;

  @override
  List<Object> get props => [uuid, record];
}

class AddIrrigationRecordEvent extends UbicacionesEvent {
  const AddIrrigationRecordEvent(this.uuid, this.record);
  final String uuid;
  final IrrigationRecord record;

  @override
  List<Object> get props => [uuid, record];
}

class AddRainRecordEvent extends UbicacionesEvent {
  const AddRainRecordEvent(this.uuid, this.record);
  final String uuid;
  final RainRecord record;

  @override
  List<Object> get props => [uuid, record];
}

class AddCostRecordEvent extends UbicacionesEvent {
  const AddCostRecordEvent(this.uuid, this.record);
  final String uuid;
  final CostRecord record;

  @override
  List<Object> get props => [uuid, record];
}
