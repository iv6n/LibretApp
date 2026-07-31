/// Canonical normalization applied before persisting an animal registration.
library;

import '../entities/animal_entity.dart';

class AnimalRegistrationNormalizer {
  const AnimalRegistrationNormalizer._();

  static String identification(String? value) => value?.trim() ?? '';

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
      earTagNumber: identification(animal.earTagNumber),
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
    final normalized = identification(candidate).toLowerCase();
    if (normalized.isEmpty) return false;
    return animals.any(
      (animal) =>
          animal.uuid != excludingUuid &&
          identification(animal.earTagNumber).toLowerCase() == normalized,
    );
  }
}
