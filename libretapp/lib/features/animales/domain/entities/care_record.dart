import 'package:equatable/equatable.dart';
import 'package:libretapp/features/animales/domain/entities/care_rule.dart';

/// Registro de la ejecución de una tarea de cuidado.
class CareRecord extends Equatable {
  final String id;
  final String animalId;
  final String ruleId;
  final CareType type;
  final DateTime performedAt;
  final String? notes;
  final String? performedBy;

  const CareRecord({
    required this.id,
    required this.animalId,
    required this.ruleId,
    required this.type,
    required this.performedAt,
    this.notes,
    this.performedBy,
  });

  @override
  List<Object?> get props => [
    id,
    animalId,
    ruleId,
    type,
    performedAt,
    notes,
    performedBy,
  ];
}
