import 'package:libretapp/core/utils/id_generator.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/animal_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/category.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/health_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/life_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_purpose.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/reproductive_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/risk_level.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/sex.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_taxonomy.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_edit_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';

class LitePetInput {
  const LitePetInput({
    required this.name,
    required this.species,
    this.breed = '',
    this.identification = '',
    this.sex = Sex.unknown,
    this.ageMonths,
    this.photo,
    this.notes = '',
  });
  final String name;
  final Species species;
  final String breed;
  final String identification;
  final Sex sex;
  final int? ageMonths;
  final String? photo;
  final String notes;
}

class LitePetService {
  const LitePetService(this.repository, {this.editService});
  final AnimalRepository repository;
  final AnimalEditService? editService;

  static bool isPet(AnimalEntity animal) =>
      animal.productionPurpose == ProductionPurpose.companion ||
      animal.species == Species.canine ||
      animal.species == Species.feline;

  Future<AnimalEntity> create(LitePetInput input) async {
    if (input.name.trim().isEmpty) {
      throw ArgumentError('Escribe el nombre de la mascota.');
    }
    if (input.ageMonths != null &&
        (input.ageMonths! < 0 || input.ageMonths! > 600)) {
      throw ArgumentError('Revisa la edad aproximada en meses.');
    }
    final now = DateTime.now();
    final age = input.ageMonths;
    final stage = age == null
        ? LifeStage.unknown
        : AnimalTaxonomy.resolveLifeStage(
            species: input.species,
            sex: input.sex,
            ageMonths: age,
          );
    return repository.save(
      AnimalEntity(
        uuid: 'ani-${generateId()}',
        earTagNumber: input.identification.trim(),
        customName: input.name.trim(),
        visualId: input.name.trim(),
        species: input.species,
        category: Category.other,
        lifeStage: stage,
        sex: input.sex,
        breed: input.breed.trim(),
        birthDate: age == null
            ? DateTime.fromMillisecondsSinceEpoch(0)
            : DateTime(now.year, now.month - age, now.day),
        birthDatePrecision: age == null
            ? BirthDatePrecision.unknown
            : BirthDatePrecision.estimated,
        ageMonths: age ?? -1,
        healthStatus: HealthStatus.good,
        vaccinated: false,
        dewormed: false,
        hasVitamins: false,
        hasChronicIssues: false,
        reproductiveStatus: ReproductiveStatus.unknown,
        productionPurpose: ProductionPurpose.companion,
        productionStage: ProductionStage.unknown,
        productionSystem: ProductionSystem.unknown,
        underObservation: false,
        requiresAttention: false,
        riskLevel: RiskLevel.low,
        profilePhoto: input.photo,
        notes: input.notes.trim().isEmpty ? null : input.notes.trim(),
        gallery: const [],
        status: AnimalStatus.active,
        synced: false,
        creationDate: now,
        lastUpdateDate: now,
      ),
    );
  }

  /// Reads the current row immediately before applying only visible edits.
  /// Fields hidden in Lite are never copied from a stale form snapshot.
  Future<AnimalEntity> patch(
    String uuid,
    LitePetInput before,
    LitePetInput after,
  ) async {
    if (after.ageMonths != null &&
        (after.ageMonths! < 0 || after.ageMonths! > 600)) {
      throw ArgumentError('Revisa la edad aproximada en meses.');
    }
    final current = await repository.getByUuid(uuid);
    if (current == null) throw StateError('La ficha ya no está disponible.');
    if (!isPet(current)) {
      throw StateError(
        'Esta ficha no está registrada como animal de compañía.',
      );
    }
    var updated = current;
    if (after.name.trim() != before.name.trim()) {
      if (after.name.trim().isEmpty)
        throw ArgumentError('El nombre es obligatorio.');
      updated = updated.copyWith(
        customName: after.name.trim(),
        visualId: after.name.trim(),
      );
    }
    if (after.breed.trim() != before.breed.trim())
      updated = updated.copyWith(breed: after.breed.trim());
    if (after.identification.trim() != before.identification.trim()) {
      updated = updated.copyWith(earTagNumber: after.identification.trim());
    }
    if (after.sex != before.sex) updated = updated.copyWith(sex: after.sex);
    if (after.photo != before.photo)
      updated = updated.copyWith(profilePhoto: after.photo);
    if (after.notes.trim() != before.notes.trim()) {
      updated = updated.copyWith(
        notes: after.notes.trim().isEmpty ? null : after.notes.trim(),
      );
    }
    if (after.sex != before.sex && updated.hasKnownAge) {
      updated = updated.copyWith(
        lifeStage: AnimalTaxonomy.resolveLifeStage(
          species: updated.species,
          sex: after.sex,
          ageMonths: updated.ageMonths,
        ),
      );
    }
    if (after.ageMonths != before.ageMonths) {
      final age = after.ageMonths;
      updated = updated.copyWith(
        ageMonths: age ?? -1,
        birthDate: age == null
            ? DateTime.fromMillisecondsSinceEpoch(0)
            : DateTime.now().subtract(Duration(days: age * 30)),
        birthDatePrecision: age == null
            ? BirthDatePrecision.unknown
            : BirthDatePrecision.estimated,
        lifeStage: age == null
            ? LifeStage.unknown
            : AnimalTaxonomy.resolveLifeStage(
                species: current.species,
                sex: updated.sex,
                ageMonths: age,
              ),
      );
    }
    final editor = editService;
    if (editor == null) return repository.update(updated);
    return editor.applyEdit(original: current, draft: updated);
  }
}
