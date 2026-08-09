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
    this.regionState = 'general',
    this.productionSetting = 'general',
  });
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String finca;
  final String direccion;
  final String upp;

  /// State id from the shared region catalog (regions/mexico-regions.json
  /// in the content repo, bundled at assets/library/mexico-regions.json).
  /// Drives which book adaptations/task tips the reader sees — see
  /// lib/features/biblioteca/domain/adaptive_resolver.dart. `'general'`
  /// means no state selected.
  final String regionState;

  /// Production setting id from the same catalog (e.g. `rangeland`,
  /// `irrigated_valley`). `'general'` means none selected.
  final String productionSetting;

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
    String? regionState,
    String? productionSetting,
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
      regionState: regionState ?? this.regionState,
      productionSetting: productionSetting ?? this.productionSetting,
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
    'region_state': regionState,
    'production_setting': productionSetting,
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
    regionState: json['region_state'] as String? ?? 'general',
    productionSetting: json['production_setting'] as String? ?? 'general',
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
    regionState,
    productionSetting,
  ];
}
