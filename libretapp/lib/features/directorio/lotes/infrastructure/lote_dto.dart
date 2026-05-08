/// features > directorio > lotes > infrastructure > lote_dto - JSON DTO for lote backups.
library;

import 'dart:convert';

import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';

class LoteDto {
  const LoteDto({
    this.id,
    required this.uuid,
    required this.nombre,
    this.descripcion,
    required this.animalUuids,
    required this.fechaCreacion,
    this.fechaCierre,
    required this.activo,
    this.notas,
    required this.lastUpdateDate,
    required this.synced,
    this.remoteId,
    this.syncDate,
  });

  final int? id;
  final String uuid;
  final String nombre;
  final String? descripcion;
  final List<String> animalUuids;
  final String fechaCreacion;
  final String? fechaCierre;
  final bool activo;
  final String? notas;
  final String lastUpdateDate;
  final bool synced;
  final String? remoteId;
  final String? syncDate;

  factory LoteDto.fromEntity(LoteEntity entity) {
    return LoteDto(
      id: entity.id,
      uuid: entity.uuid,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      animalUuids: List<String>.unmodifiable(entity.animalUuids),
      fechaCreacion: entity.fechaCreacion.toIso8601String(),
      fechaCierre: entity.fechaCierre?.toIso8601String(),
      activo: entity.activo,
      notas: entity.notas,
      lastUpdateDate: entity.lastUpdateDate.toIso8601String(),
      synced: entity.synced,
      remoteId: entity.remoteId,
      syncDate: entity.syncDate?.toIso8601String(),
    );
  }

  factory LoteDto.fromJson(Map<String, dynamic> json) {
    return LoteDto(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      animalUuids: (json['animalUuids'] as List<dynamic>? ?? const <dynamic>[])
          .cast<String>(),
      fechaCreacion: json['fechaCreacion'] as String,
      fechaCierre: json['fechaCierre'] as String?,
      activo: json['activo'] as bool? ?? true,
      notas: json['notas'] as String?,
      lastUpdateDate: json['lastUpdateDate'] as String,
      synced: json['synced'] as bool? ?? false,
      remoteId: json['remoteId'] as String?,
      syncDate: json['syncDate'] as String?,
    );
  }

  factory LoteDto.fromJsonString(String value) =>
      LoteDto.fromJson(jsonDecode(value) as Map<String, dynamic>);

  LoteEntity toEntity() {
    return LoteEntity(
      id: id,
      uuid: uuid,
      nombre: nombre,
      descripcion: descripcion,
      animalUuids: List<String>.unmodifiable(animalUuids),
      fechaCreacion: DateTime.parse(fechaCreacion),
      fechaCierre: _parseDate(fechaCierre),
      activo: activo,
      notas: notas,
      lastUpdateDate: DateTime.parse(lastUpdateDate),
      synced: synced,
      remoteId: remoteId,
      syncDate: _parseDate(syncDate),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'nombre': nombre,
      'descripcion': descripcion,
      'animalUuids': animalUuids,
      'fechaCreacion': fechaCreacion,
      'fechaCierre': fechaCierre,
      'activo': activo,
      'notas': notas,
      'lastUpdateDate': lastUpdateDate,
      'synced': synced,
      'remoteId': remoteId,
      'syncDate': syncDate,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.parse(value);
  }
}
