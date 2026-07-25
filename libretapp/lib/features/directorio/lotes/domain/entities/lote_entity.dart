/// features \u203a directorio \u203a lotes \u203a domain \u203a entities \u203a lote_entity \u2014 Lote domain entity.
library;

import 'package:equatable/equatable.dart';

/// A batch/group of animals managed together.
///
/// A lote is a logical grouping of animals for organisational purposes such as
/// vaccination tracking, production records, or health campaigns.
class LoteEntity extends Equatable {
  const LoteEntity({
    this.id,
    required this.uuid,
    required this.name,
    this.description,
    this.animalUuids = const [],
    required this.createdAt,
    this.closedAt,
    this.active = true,
    this.notes,
    this.currentLocationId,
    required this.lastUpdateDate,
    this.synced = false,
    this.remoteId,
    this.syncDate,
  });
  final int? id;
  final String uuid;
  final String name;
  final String? description;
  final List<String> animalUuids;
  final DateTime createdAt;
  final DateTime? closedAt;
  final bool active;
  final String? notes;

  /// UUID of the LocationEntity where this batch is currently located.
  final String? currentLocationId;
  final DateTime lastUpdateDate;
  final bool synced;
  final String? remoteId;
  final DateTime? syncDate;

  LoteEntity copyWith({
    int? id,
    String? uuid,
    String? name,
    String? description,
    List<String>? animalUuids,
    DateTime? createdAt,
    DateTime? closedAt,
    bool? active,
    String? notes,
    Object? currentLocationId = _sentinel,
    DateTime? lastUpdateDate,
    bool? synced,
    String? remoteId,
    DateTime? syncDate,
  }) {
    return LoteEntity(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      animalUuids: animalUuids ?? this.animalUuids,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
      active: active ?? this.active,
      notes: notes ?? this.notes,
      currentLocationId: currentLocationId == _sentinel
          ? this.currentLocationId
          : currentLocationId as String?,
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
    name,
    description,
    animalUuids,
    createdAt,
    closedAt,
    active,
    notes,
    currentLocationId,
    lastUpdateDate,
    synced,
    remoteId,
    syncDate,
  ];
}

// Sentinel object used to distinguish explicit null from omitted in copyWith.
const Object _sentinel = Object();
