/// Configurable and versioned IATF/reproduction protocols.
library;

enum ReproductionProtocolStepType { application, ultrasound, breeding, pregnancyCheck, calving, weaning }
enum ProtocolExecutionStatus { pending, completed, delayed, suspended, cancelled }
enum GeneticMaterialType { semen, embryo }

class ReproductionProtocolStep {
  const ReproductionProtocolStep({required this.uuid, required this.dayOffset, required this.type, required this.name, this.responsibleRole, this.notes});
  final String uuid;
  final int dayOffset;
  final ReproductionProtocolStepType type;
  final String name;
  final String? responsibleRole;
  final String? notes;
  Map<String, dynamic> toJson() => {'uuid': uuid, 'dayOffset': dayOffset, 'type': type.name, 'name': name, 'responsibleRole': responsibleRole, 'notes': notes};
  factory ReproductionProtocolStep.fromJson(Map<String, dynamic> json) => ReproductionProtocolStep(uuid: json['uuid'] as String, dayOffset: (json['dayOffset'] as num).toInt(), type: ReproductionProtocolStepType.values.byName(json['type'] as String), name: json['name'] as String, responsibleRole: json['responsibleRole'] as String?, notes: json['notes'] as String?);
}

class ReproductionProtocol {
  const ReproductionProtocol({required this.uuid, required this.farmId, required this.name, required this.version, required this.steps, this.active = true});
  final String uuid;
  final String farmId;
  final String name;
  final int version;
  final List<ReproductionProtocolStep> steps;
  final bool active;
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'name': name, 'version': version, 'steps': steps.map((s) => s.toJson()).toList(), 'active': active};
  factory ReproductionProtocol.fromJson(Map<String, dynamic> json) => ReproductionProtocol(uuid: json['uuid'] as String, farmId: json['farmId'] as String, name: json['name'] as String, version: (json['version'] as num).toInt(), steps: ((json['steps'] as List?) ?? const []).map((s) => ReproductionProtocolStep.fromJson(Map<String, dynamic>.from(s as Map))).toList(), active: json['active'] as bool? ?? true);
}

class ProtocolAssignment {
  const ProtocolAssignment({required this.uuid, required this.farmId, required this.protocolId, required this.animalUuid, required this.startedAt, this.status = ProtocolExecutionStatus.pending, this.suspendedAt, this.notes});
  final String uuid;
  final String farmId;
  final String protocolId;
  final String animalUuid;
  final DateTime startedAt;
  final ProtocolExecutionStatus status;
  final DateTime? suspendedAt;
  final String? notes;
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'protocolId': protocolId, 'animalUuid': animalUuid, 'startedAt': startedAt.toUtc().toIso8601String(), 'status': status.name, 'suspendedAt': suspendedAt?.toUtc().toIso8601String(), 'notes': notes};
  factory ProtocolAssignment.fromJson(Map<String, dynamic> json) => ProtocolAssignment(uuid: json['uuid'] as String, farmId: json['farmId'] as String, protocolId: json['protocolId'] as String, animalUuid: json['animalUuid'] as String, startedAt: DateTime.parse(json['startedAt'] as String).toUtc(), status: ProtocolExecutionStatus.values.byName(json['status'] as String? ?? 'pending'), suspendedAt: (json['suspendedAt'] as String?) == null ? null : DateTime.parse(json['suspendedAt'] as String).toUtc(), notes: json['notes'] as String?);
}

class ProtocolExecution {
  const ProtocolExecution({required this.uuid, required this.farmId, required this.assignmentId, required this.stepId, required this.scheduledFor, this.executedAt, this.status = ProtocolExecutionStatus.pending, this.recordUuid, this.notes});
  final String uuid;
  final String farmId;
  final String assignmentId;
  final String stepId;
  final DateTime scheduledFor;
  final DateTime? executedAt;
  final ProtocolExecutionStatus status;
  final String? recordUuid;
  final String? notes;
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'assignmentId': assignmentId, 'stepId': stepId, 'scheduledFor': scheduledFor.toUtc().toIso8601String(), 'executedAt': executedAt?.toUtc().toIso8601String(), 'status': status.name, 'recordUuid': recordUuid, 'notes': notes};
  factory ProtocolExecution.fromJson(Map<String, dynamic> json) => ProtocolExecution(uuid: json['uuid'] as String, farmId: json['farmId'] as String, assignmentId: json['assignmentId'] as String, stepId: json['stepId'] as String, scheduledFor: DateTime.parse(json['scheduledFor'] as String).toUtc(), executedAt: (json['executedAt'] as String?) == null ? null : DateTime.parse(json['executedAt'] as String).toUtc(), status: ProtocolExecutionStatus.values.byName(json['status'] as String? ?? 'pending'), recordUuid: json['recordUuid'] as String?, notes: json['notes'] as String?);
}

class GeneticMaterial {
  const GeneticMaterial({required this.uuid, required this.farmId, required this.type, required this.identifier, this.donorUuid, this.recipientUuid, this.quantity = 1, this.expiryDate, this.notes});
  final String uuid;
  final String farmId;
  final GeneticMaterialType type;
  final String identifier;
  final String? donorUuid;
  final String? recipientUuid;
  final double quantity;
  final DateTime? expiryDate;
  final String? notes;
  Map<String, dynamic> toJson() => {'uuid': uuid, 'farmId': farmId, 'type': type.name, 'identifier': identifier, 'donorUuid': donorUuid, 'recipientUuid': recipientUuid, 'quantity': quantity, 'expiryDate': expiryDate?.toUtc().toIso8601String(), 'notes': notes};
  factory GeneticMaterial.fromJson(Map<String, dynamic> json) => GeneticMaterial(uuid: json['uuid'] as String, farmId: json['farmId'] as String, type: GeneticMaterialType.values.byName(json['type'] as String), identifier: json['identifier'] as String, donorUuid: json['donorUuid'] as String?, recipientUuid: json['recipientUuid'] as String?, quantity: (json['quantity'] as num?)?.toDouble() ?? 1, expiryDate: (json['expiryDate'] as String?) == null ? null : DateTime.parse(json['expiryDate'] as String).toUtc(), notes: json['notes'] as String?);
}
