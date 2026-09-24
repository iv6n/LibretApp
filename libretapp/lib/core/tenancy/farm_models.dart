/// Finca context and access-control contracts shared by every feature.
library;

import 'package:equatable/equatable.dart';

enum FarmRole { owner, manager, veterinarian, worker, client }

extension FarmRolePermissions on FarmRole {
  bool get managesFarm => this == FarmRole.owner;
  bool get canOperate => this != FarmRole.client;
  bool get canViewFinance => this == FarmRole.owner || this == FarmRole.manager;
  bool get canManageHealth => this == FarmRole.owner || this == FarmRole.manager || this == FarmRole.veterinarian;
  bool get canCaptureTasks => this != FarmRole.client;
  bool get isClient => this == FarmRole.client;
}

class Farm extends Equatable {
  const Farm({
    required this.uuid,
    required this.name,
    this.legalName,
    this.ownerName,
    this.upp,
    this.timeZone = 'America/Hermosillo',
    this.defaultCurrency = 'MXN',
    this.createdAt,
    this.updatedAt,
  });

  final String uuid;
  final String name;
  final String? legalName;
  final String? ownerName;
  final String? upp;
  final String timeZone;
  final String defaultCurrency;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'uuid': uuid, 'name': name, 'legalName': legalName, 'ownerName': ownerName,
    'upp': upp, 'timeZone': timeZone, 'defaultCurrency': defaultCurrency,
    'createdAt': createdAt?.toUtc().toIso8601String(),
    'updatedAt': updatedAt?.toUtc().toIso8601String(),
  };

  factory Farm.fromJson(Map<String, dynamic> json) => Farm(
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    legalName: json['legalName'] as String?,
    ownerName: json['ownerName'] as String?,
    upp: json['upp'] as String?,
    timeZone: json['timeZone'] as String? ?? 'America/Hermosillo',
    defaultCurrency: json['defaultCurrency'] as String? ?? 'MXN',
    createdAt: _date(json['createdAt']),
    updatedAt: _date(json['updatedAt']),
  );

  @override
  List<Object?> get props => [uuid, name, legalName, ownerName, upp, timeZone, defaultCurrency, createdAt, updatedAt];
}

class FarmMembership extends Equatable {
  const FarmMembership({
    required this.uuid,
    required this.farmId,
    required this.userId,
    required this.role,
    this.workerId,
    this.clientAnimalIds = const <String>{},
    this.active = true,
  });

  final String uuid;
  final String farmId;
  final String userId;
  final FarmRole role;
  final String? workerId;
  final Set<String> clientAnimalIds;
  final bool active;

  bool canAccessAnimal(String animalId) => role != FarmRole.client || clientAnimalIds.contains(animalId);

  Map<String, dynamic> toJson() => {
    'uuid': uuid, 'farmId': farmId, 'userId': userId, 'role': role.name,
    'workerId': workerId, 'clientAnimalIds': clientAnimalIds.toList(), 'active': active,
  };

  factory FarmMembership.fromJson(Map<String, dynamic> json) => FarmMembership(
    uuid: json['uuid'] as String,
    farmId: json['farmId'] as String,
    userId: json['userId'] as String,
    role: FarmRole.values.byName(json['role'] as String),
    workerId: json['workerId'] as String?,
    clientAnimalIds: ((json['clientAnimalIds'] as List?) ?? const []).cast<String>().toSet(),
    active: json['active'] as bool? ?? true,
  );

  @override
  List<Object?> get props => [uuid, farmId, userId, role, workerId, clientAnimalIds, active];
}

class FarmContext extends Equatable {
  const FarmContext({required this.farm, required this.membership});

  final Farm farm;
  final FarmMembership membership;

  String get farmId => farm.uuid;
  FarmRole get role => membership.role;

  @override
  List<Object?> get props => [farm, membership];
}

DateTime? _date(Object? raw) => raw is String ? DateTime.tryParse(raw)?.toUtc() : null;
