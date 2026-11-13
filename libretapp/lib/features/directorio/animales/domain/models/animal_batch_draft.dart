import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_dto.dart';

/// A registration prepared by either form, but not yet written to the herd.
class AnimalBatchDraft {
  const AnimalBatchDraft({
    required this.animal,
    this.fullForm,
    this.healthRecords = const [],
    this.reproductionRecords = const [],
  });

  final AnimalEntity animal;
  final Map<String, dynamic>? fullForm;
  final List<Map<String, dynamic>> healthRecords;
  final List<Map<String, dynamic>> reproductionRecords;

  bool get isComplete => fullForm != null;

  Map<String, dynamic> toJson() => {
    'animal': AnimalDto.fromEntity(animal).toJson(),
    'fullForm': fullForm,
    'healthRecords': healthRecords,
    'reproductionRecords': reproductionRecords,
  };

  factory AnimalBatchDraft.fromJson(Map<String, dynamic> json) =>
      AnimalBatchDraft(
        animal: AnimalDto.fromJson(
          Map<String, dynamic>.from(json['animal'] as Map),
        ).toEntity(),
        fullForm: json['fullForm'] is Map
            ? Map<String, dynamic>.from(json['fullForm'] as Map)
            : null,
        healthRecords: (json['healthRecords'] as List? ?? const [])
            .map((value) => Map<String, dynamic>.from(value as Map))
            .toList(),
        reproductionRecords: (json['reproductionRecords'] as List? ?? const [])
            .map((value) => Map<String, dynamic>.from(value as Map))
            .toList(),
      );
}
