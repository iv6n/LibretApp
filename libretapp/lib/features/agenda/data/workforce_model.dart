/// Local workforce models used by operational agenda assignments.
library;

import 'package:equatable/equatable.dart';

class WorkerRole {
  static const owner = 'owner';
  static const supervisor = 'supervisor';
  static const worker = 'worker';
}

class WorkerProfile extends Equatable {

  factory WorkerProfile.fromJson(Map<String, dynamic> json) => WorkerProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    role: json['role'] as String,
    phone: json['phone'] as String?,
    active: json['active'] as bool? ?? true,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
  const WorkerProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.phone,
  });

  final String id;
  final String name;
  final String role;
  final String? phone;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkerProfile copyWith({
    String? name,
    String? role,
    String? phone,
    bool? active,
    DateTime? updatedAt,
  }) => WorkerProfile(
    id: id,
    name: name ?? this.name,
    role: role ?? this.role,
    phone: phone ?? this.phone,
    active: active ?? this.active,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    if (phone != null) 'phone': phone,
    'active': active,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, name, role, phone, active, createdAt, updatedAt];
}

class WorkTeam extends Equatable {

  factory WorkTeam.fromJson(Map<String, dynamic> json) => WorkTeam(
    id: json['id'] as String,
    name: json['name'] as String,
    memberIds: (json['memberIds'] as List<dynamic>? ?? const [])
        .cast<String>(),
    active: json['active'] as bool? ?? true,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
  const WorkTeam({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final List<String> memberIds;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkTeam copyWith({
    String? name,
    List<String>? memberIds,
    bool? active,
    DateTime? updatedAt,
  }) => WorkTeam(
    id: id,
    name: name ?? this.name,
    memberIds: memberIds ?? this.memberIds,
    active: active ?? this.active,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'memberIds': memberIds,
    'active': active,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, name, memberIds, active, createdAt, updatedAt];
}
