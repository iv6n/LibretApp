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
