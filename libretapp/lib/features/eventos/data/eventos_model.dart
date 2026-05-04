/// features \u203a eventos \u203a data \u203a eventos_model \u2014 Isar model and domain entity for an event.
library;

import 'package:equatable/equatable.dart';

class Evento extends Equatable {
  const Evento({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.tipo,
    required this.animalId,
    required this.ubicacion,
  });
  final String id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final String tipo;
  final String animalId;
  final String ubicacion;

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'fecha': fecha.toIso8601String(),
    'tipo': tipo,
    'animalId': animalId,
    'ubicacion': ubicacion,
  };

  static Evento fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      tipo: json['tipo'] as String,
      animalId: json['animalId'] as String,
      ubicacion: json['ubicacion'] as String,
    );
  }

  @override
  List<Object> get props => [
    id,
    titulo,
    descripcion,
    fecha,
    tipo,
    animalId,
    ubicacion,
  ];
}
