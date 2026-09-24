library;

import 'package:libretapp/core/persistence/json_feature_repository.dart';
import 'package:libretapp/features/directorio/animales/reproduccion/protocol_models.dart';
import 'package:uuid/uuid.dart';

class ReproductionProtocolService {
  ReproductionProtocolService({required JsonFeatureRepository<ReproductionProtocol> protocols, required JsonFeatureRepository<ProtocolAssignment> assignments, required JsonFeatureRepository<ProtocolExecution> executions}) : _protocols = protocols, _assignments = assignments, _executions = executions;
  final JsonFeatureRepository<ReproductionProtocol> _protocols;
  final JsonFeatureRepository<ProtocolAssignment> _assignments;
  final JsonFeatureRepository<ProtocolExecution> _executions;

  Future<ReproductionProtocol> saveProtocol(ReproductionProtocol protocol) => _protocols.save(farmId: protocol.farmId, value: protocol, uuid: protocol.uuid);

  Future<ProtocolAssignment> assign({required String farmId, required ReproductionProtocol protocol, required String animalUuid, required DateTime start, String? uuid}) async {
    if (!protocol.active || protocol.steps.isEmpty) throw const FormatException('El protocolo debe estar activo y tener pasos.');
    final assignment = ProtocolAssignment(uuid: uuid ?? const Uuid().v4(), farmId: farmId, protocolId: protocol.uuid, animalUuid: animalUuid, startedAt: start.toUtc());
    return _assignments.save(farmId: farmId, value: assignment, uuid: assignment.uuid);
  }

  Future<List<ProtocolExecution>> schedule(ProtocolAssignment assignment, ReproductionProtocol protocol) async {
    final result = <ProtocolExecution>[];
    for (final step in protocol.steps) {
      final execution = ProtocolExecution(uuid: '${assignment.uuid}:${step.uuid}', farmId: assignment.farmId, assignmentId: assignment.uuid, stepId: step.uuid, scheduledFor: assignment.startedAt.add(Duration(days: step.dayOffset)));
      final current = await _executions.get(assignment.farmId, execution.uuid);
      result.add(current ?? await _executions.save(farmId: assignment.farmId, value: execution, uuid: execution.uuid));
    }
    return result;
  }

  Future<ProtocolExecution> complete({required ProtocolExecution execution, required String recordUuid, DateTime? executedAt, String? notes}) => _executions.save(farmId: execution.farmId, uuid: execution.uuid, value: ProtocolExecution(uuid: execution.uuid, farmId: execution.farmId, assignmentId: execution.assignmentId, stepId: execution.stepId, scheduledFor: execution.scheduledFor, executedAt: (executedAt ?? DateTime.now()).toUtc(), status: ProtocolExecutionStatus.completed, recordUuid: recordUuid, notes: notes));

  ProtocolExecution reschedule(ProtocolExecution execution, DateTime date) => ProtocolExecution(uuid: execution.uuid, farmId: execution.farmId, assignmentId: execution.assignmentId, stepId: execution.stepId, scheduledFor: date.toUtc(), executedAt: execution.executedAt, status: ProtocolExecutionStatus.delayed, recordUuid: execution.recordUuid, notes: execution.notes);
}
