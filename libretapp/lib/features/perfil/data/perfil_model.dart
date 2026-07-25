/// features › perfil › data › perfil_model — data model for the user profile.
library;

import 'package:equatable/equatable.dart';

class Perfil extends Equatable {
  const Perfil({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.finca,
    required this.direccion,
    this.upp = '',
  });
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String finca;
  final String direccion;
  final String upp;

  String get fullName => '$nombre $apellido'.trim();

  Perfil copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    String? finca,
    String? direccion,
    String? upp,
  }) {
    return Perfil(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      finca: finca ?? this.finca,
      direccion: direccion ?? this.direccion,
      upp: upp ?? this.upp,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'apellido': apellido,
    'email': email,
    'telefono': telefono,
    'finca': finca,
    'direccion': direccion,
    'upp': upp,
  };

  factory Perfil.fromJson(Map<String, dynamic> json) => Perfil(
    id: json['id'] as String? ?? '',
    nombre: json['nombre'] as String? ?? '',
    apellido: json['apellido'] as String? ?? '',
    email: json['email'] as String? ?? '',
    telefono: json['telefono'] as String? ?? '',
    finca: json['finca'] as String? ?? '',
    direccion: json['direccion'] as String? ?? '',
    upp: json['upp'] as String? ?? '',
  );

  @override
  List<Object> get props => [
    id,
    nombre,
    apellido,
    email,
    telefono,
    finca,
    direccion,
    upp,
  ];
}
