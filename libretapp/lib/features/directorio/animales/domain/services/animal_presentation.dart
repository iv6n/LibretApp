/// Shared presentation helpers for animal labels.
library;

import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_registration_policy.dart';

bool hasPendingEarTag(AnimalEntity animal) =>
    AnimalRegistrationPolicy.forSpecies(
      animal.species,
    ).hasPendingEarTag(animal);

String identificationDisplay(AnimalEntity animal) {
  final identification = animal.earTagNumber.trim();
  if (identification.isNotEmpty) return identification;
  return hasPendingEarTag(animal) ? 'Arete pendiente' : 'Sin identificación';
}

String primaryAnimalLabel(AnimalEntity animal) {
  final customName = animal.customName?.trim();
  if (customName != null && customName.isNotEmpty) return customName;

  final visualId = animal.visualId?.trim();
  if (visualId != null && visualId.isNotEmpty) return visualId;

  final earTag = animal.earTagNumber.trim();
  if (earTag.isNotEmpty) return earTag;

  return animal.species.displayName;
}

String earTagDisplay(AnimalEntity animal) {
  return identificationDisplay(animal);
}

String breedSummary(AnimalEntity animal, {bool abbreviated = false}) {
  final primary = animal.breed.trim().isNotEmpty
      ? animal.breed.trim()
      : animal.species.displayName;
  final secondary = animal.crossBreed?.trim();

  if (secondary == null || secondary.isEmpty) {
    return primary;
  }

  final left = abbreviated ? abbreviateBreed(primary) : primary;
  final right = abbreviated ? abbreviateBreed(secondary) : secondary;
  return '$left x $right';
}

String abbreviateBreed(String name) {
  final cleaned = _normalizeBreed(name);
  if (cleaned.isEmpty) return 's/r';

  const known = <String, String>{
    'simmental': 'sim',
    'charolais': 'char',
    'charoles': 'char',
    'brahman': 'brah',
    'angus': 'ang',
    'hereford': 'her',
    'limousin': 'lim',
    'cebu': 'cebu',
    'criolla': 'crio',
    'criollo': 'crio',
    'brangus': 'brang',
    'beefmaster': 'beef',
    'santa gertrudis': 'sg',
    'holstein': 'hol',
    'jersey': 'jer',
    'pardo suizo': 'ps',
    'gyr': 'gyr',
    'nelore': 'nel',
    'desconocido': 's/r',
  };
  final mapped = known[cleaned];
  if (mapped != null) return mapped;

  final firstWord = cleaned.split(RegExp(r'\s+')).first;
  return firstWord.length <= 4 ? firstWord : firstWord.substring(0, 4);
}

String animalSearchPresentationText(AnimalEntity animal) {
  return [
    primaryAnimalLabel(animal),
    earTagDisplay(animal),
    breedSummary(animal),
    breedSummary(animal, abbreviated: true),
    animal.crossBreed,
    animal.sireBreed,
    animal.damBreed,
  ].whereType<String>().join(' ');
}

String _normalizeBreed(String value) {
  final lower = value.trim().toLowerCase();
  final withoutAccents = lower
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ñ', 'n');
  return withoutAccents
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
