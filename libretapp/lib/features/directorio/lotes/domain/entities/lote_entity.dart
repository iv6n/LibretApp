import 'package:equatable/equatable.dart';

/// Entidad que representa un lote de animales agrupados.
/// Un lote es una agrupación lógica de animales con propósitos organizacionales,
/// como seguimiento de vacunaciones, registros de producción, o campañas sanitarias.
class LoteEntity extends Equatable {
  final int? id;
  final String uuid;
  final String nombre;
  final String? descripcion;
  final List<String> animalUuids; // UUIDs de animales en el lote
  final DateTime fechaCreacion;
  final DateTime? fechaCierre;
  final bool activo;
  final String? notas;
  final DateTime lastUpdateDate;
  final bool synced;
  final String? remoteId;
  final DateTime? syncDate;

  const LoteEntity({
    this.id,
    required this.uuid,
    required this.nombre,
    this.descripcion,
    this.animalUuids = const [],
    required this.fechaCreacion,
    this.fechaCierre,
    this.activo = true,
    this.notas,
    required this.lastUpdateDate,
    this.synced = false,
    this.remoteId,
    this.syncDate,
  });

  /// Crea una copia con cambios especificados
  LoteEntity copyWith({
    int? id,
    String? uuid,
    String? nombre,
    String? descripcion,
    List<String>? animalUuids,
    DateTime? fechaCreacion,
    DateTime? fechaCierre,
    bool? activo,
    String? notas,
    DateTime? lastUpdateDate,
    bool? synced,
    String? remoteId,
    DateTime? syncDate,
  }) {
    return LoteEntity(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      animalUuids: animalUuids ?? this.animalUuids,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      activo: activo ?? this.activo,
      notas: notas ?? this.notas,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
      synced: synced ?? this.synced,
      remoteId: remoteId ?? this.remoteId,
      syncDate: syncDate ?? this.syncDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    uuid,
    nombre,
    descripcion,
    animalUuids,
    fechaCreacion,
    fechaCierre,
    activo,
    notas,
    lastUpdateDate,
    synced,
    remoteId,
    syncDate,
  ];
}
