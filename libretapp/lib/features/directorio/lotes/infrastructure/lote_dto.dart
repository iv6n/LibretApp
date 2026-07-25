/// features > directorio > lotes > infrastructure > lote_dto - JSON DTO for lote backups.
///
/// Dart fields use English names; JSON keys preserve old Spanish names for
/// backward-compatible backup/restore (existing export files continue to work).
library;

import 'dart:convert';

import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';

class LoteDto {
  const LoteDto({
    this.id,
    required this.uuid,
    required this.name,
    this.description,
    required this.animalUuids,
    required this.createdAt,
    this.closedAt,
    required this.active,
    this.notes,
    required this.lastUpdateDate,
    required this.synced,
    this.remoteId,
    this.syncDate,
  });

  final int? id;
  final String uuid;
  final String name;
  final String? description;
  final List<String> animalUuids;
  final String createdAt;
  final String? closedAt;
  final bool active;
  final String? notes;
  final String lastUpdateDate;
  final bool synced;
  final String? remoteId;
  final String? syncDate;

  factory LoteDto.fromEntity(LoteEntity entity) {
    return LoteDto(
      id: entity.id,
      uuid: entity.uuid,
      name: entity.name,
      description: entity.description,
      animalUuids: List<String>.unmodifiable(entity.animalUuids),
      createdAt: entity.createdAt.toIso8601String(),
      closedAt: entity.closedAt?.toIso8601String(),
      active: entity.active,
      notes: entity.notes,
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
      // Support both old Spanish key and new English key for restore compat.
      name: (json['nombre'] ?? json['name']) as String,
      description: (json['descripcion'] ?? json['description']) as String?,
      animalUuids: (json['animalUuids'] as List<dynamic>? ?? const <dynamic>[])
          .cast<String>(),
      createdAt: (json['fechaCreacion'] ?? json['createdAt']) as String,
      closedAt: (json['fechaCierre'] ?? json['closedAt']) as String?,
      active: (json['activo'] ?? json['active']) as bool? ?? true,
      notes: (json['notas'] ?? json['notes']) as String?,
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
      name: name,
      description: description,
      animalUuids: List<String>.unmodifiable(animalUuids),
      createdAt: DateTime.parse(createdAt),
      closedAt: _parseDate(closedAt),
      active: active,
      notes: notes,
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
      'nombre': name, // keep Spanish key for export backward-compat
      'descripcion': description,
      'animalUuids': animalUuids,
      'fechaCreacion': createdAt,
      'fechaCierre': closedAt,
      'activo': active,
      'notas': notes,
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
