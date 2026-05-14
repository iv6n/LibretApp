/// features › agenda › data › agenda_model — domain entity for an agenda entry (task/event).
library;

import 'package:equatable/equatable.dart';

/// Task/event status constants.
class AgendaEstado {
  static const pendiente = 'pendiente';
  static const enProgreso = 'en_progreso';
  static const completado = 'completado';
}

class AgendaEntry extends Equatable {
  const AgendaEntry({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.tipo,
    required this.animalIds,
    required this.loteIds,
    required this.ubicacion,
    required this.estado,
    required this.completedAnimalIds,
    required this.notas,
    this.fechaCompletado,
    this.locationUuid,
  });

  final String id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final String tipo;

  /// IDs of animals assigned to this task. May be empty for general tasks.
  final List<String> animalIds;

  /// Lote names assigned to this task. Expanded to individual animals on execution.
  final List<String> loteIds;

  final String ubicacion;

  /// One of [AgendaEstado.pendiente], [AgendaEstado.enProgreso], [AgendaEstado.completado].
  final String estado;

  /// Subset of [animalIds] that have been individually completed.
  final List<String> completedAnimalIds;

  final String notas;
  final DateTime? fechaCompletado;

  /// UUID of the [LocationEntity] this entry is linked to. May be null for
  /// entries that predate location linking or have a free-text [ubicacion].
  final String? locationUuid;

  static const _sentinel = Object();

  AgendaEntry copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    DateTime? fecha,
    String? tipo,
    List<String>? animalIds,
    List<String>? loteIds,
    String? ubicacion,
    String? estado,
    List<String>? completedAnimalIds,
    String? notas,
    DateTime? fechaCompletado,
    Object? locationUuid = _sentinel,
  }) {
    return AgendaEntry(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      animalIds: animalIds ?? this.animalIds,
      loteIds: loteIds ?? this.loteIds,
      ubicacion: ubicacion ?? this.ubicacion,
      estado: estado ?? this.estado,
      completedAnimalIds: completedAnimalIds ?? this.completedAnimalIds,
      notas: notas ?? this.notas,
      fechaCompletado: fechaCompletado ?? this.fechaCompletado,
      locationUuid: locationUuid == _sentinel
          ? this.locationUuid
          : locationUuid as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'fecha': fecha.toIso8601String(),
    'tipo': tipo,
    'animalIds': animalIds,
    'loteIds': loteIds,
    'ubicacion': ubicacion,
    'estado': estado,
    'completedAnimalIds': completedAnimalIds,
    'notas': notas,
    'fechaCompletado': fechaCompletado?.toIso8601String(),
    if (locationUuid != null) 'locationUuid': locationUuid,
  };

  static AgendaEntry fromJson(Map<String, dynamic> json) {
    // Backward-compat: old records stored a single 'animalId' string.
    List<String> parseAnimalIds() {
      if (json.containsKey('animalIds')) {
        return (json['animalIds'] as List<dynamic>)
            .map((e) => e as String)
            .toList();
      }
      final legacy = json['animalId'] as String? ?? '';
      return legacy.isNotEmpty && legacy != 'Sin asignar' ? [legacy] : [];
    }

    return AgendaEntry(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      fecha: DateTime.parse(json['fecha'] as String),
      tipo: json['tipo'] as String,
      animalIds: parseAnimalIds(),
      loteIds:
          (json['loteIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      ubicacion: json['ubicacion'] as String? ?? 'Sin ubicación',
      estado: json['estado'] as String? ?? AgendaEstado.pendiente,
      completedAnimalIds:
          (json['completedAnimalIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      notas: json['notas'] as String? ?? '',
      fechaCompletado: json['fechaCompletado'] != null
          ? DateTime.parse(json['fechaCompletado'] as String)
          : null,
      locationUuid: json['locationUuid'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    titulo,
    descripcion,
    fecha,
    tipo,
    animalIds,
    loteIds,
    ubicacion,
    estado,
    completedAnimalIds,
    notas,
    fechaCompletado,
    locationUuid,
  ];
}
