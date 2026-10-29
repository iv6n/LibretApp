import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_purpose.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';

/// Presentation preference for the workspace. It does not filter records.
enum CareProfile { pets, livestock, mixed }

extension CareProfileLabels on CareProfile {
  String get label => switch (this) {
    CareProfile.pets => 'Mascotas',
    CareProfile.livestock => 'Ganado',
    CareProfile.mixed => 'Ambos',
  };
}

bool isPetSpecies(Species species) =>
    species == Species.canine || species == Species.feline;

/// Dogs and cats remain pets even when they have a work or guard purpose.
bool isPetAnimal(AnimalEntity animal) =>
    isPetSpecies(animal.species) ||
    animal.productionPurpose == ProductionPurpose.companion;

CareProfile? inferCareProfileFromAnimals(Iterable<AnimalEntity> animals) {
  var pets = false;
  var livestock = false;
  for (final animal in animals) {
    if (isPetAnimal(animal)) {
      pets = true;
    } else {
      livestock = true;
    }
    if (pets && livestock) return CareProfile.mixed;
  }
  if (pets) return CareProfile.pets;
  if (livestock) return CareProfile.livestock;
  return null;
}

CareProfile? inferCareProfileFromSpecies(Iterable<Species> species) {
  var pets = false;
  var livestock = false;
  for (final value in species) {
    if (isPetSpecies(value)) {
      pets = true;
    } else {
      livestock = true;
    }
    if (pets && livestock) return CareProfile.mixed;
  }
  if (pets) return CareProfile.pets;
  if (livestock) return CareProfile.livestock;
  return null;
}

CareProfile? resolveCareProfile({
  required CareProfile? selected,
  required Iterable<AnimalEntity> animals,
  required Iterable<Species> preferredSpecies,
}) =>
    selected ??
    inferCareProfileFromAnimals(animals) ??
    inferCareProfileFromSpecies(preferredSpecies);

CareProfile? resolveCareProfileFromCounts({
  required CareProfile? selected,
  required int pets,
  required int livestock,
  required Iterable<Species> preferredSpecies,
}) {
  if (selected != null) return selected;
  if (pets > 0 && livestock > 0) return CareProfile.mixed;
  if (pets > 0) return CareProfile.pets;
  if (livestock > 0) return CareProfile.livestock;
  return inferCareProfileFromSpecies(preferredSpecies);
}
