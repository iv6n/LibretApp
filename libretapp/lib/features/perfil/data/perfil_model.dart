import 'package:equatable/equatable.dart';

class Perfil extends Equatable {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String finca;
  final String direccion;

  const Perfil({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.finca,
    required this.direccion,
  });

  @override
  List<Object> get props => [
    id,
    nombre,
    apellido,
    email,
    telefono,
    finca,
    direccion,
  ];
}
