/// Canonical normalization applied before persisting an animal registration.
library;

import '../entities/animal_entity.dart';
import 'animal_registration_policy.dart';

class AnimalRegistrationNormalizer {
  const AnimalRegistrationNormalizer._();

  static String identification(String? value) => value?.trim() ?? '';

  static String earTag(String? value) =>
      identification(value).replaceAll(RegExp(r'\s+'), '');

  static String breed(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? 'Desconocido' : normalized;
  }

  static String? optionalText(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }

  static AnimalEntity normalizeEntity(AnimalEntity animal) {
    return animal.copyWith(
      earTagNumber:
          AnimalRegistrationPolicy.forSpecies(
                animal.species,
              ).identificationKind ==
              AnimalIdentificationKind.earTag
          ? earTag(animal.earTagNumber)
          : identification(animal.earTagNumber),
      customName: optionalText(animal.customName),
      visualId: optionalText(animal.visualId),
      breed: breed(animal.breed),
    );
  }

  static bool isDuplicateIdentification({
    required String? candidate,
    required Iterable<AnimalEntity> animals,
    String? excludingUuid,
  }) {
    if (identification(candidate).isEmpty) return false;
    return animals.any((animal) {
      if (animal.uuid == excludingUuid) return false;
      final compact =
          AnimalRegistrationPolicy.forSpecies(
            animal.species,
          ).identificationKind ==
          AnimalIdentificationKind.earTag;
      final normalize = compact ? earTag : identification;
      return normalize(animal.earTagNumber).toLowerCase() ==
          normalize(candidate).toLowerCase();
    });
  }
}
