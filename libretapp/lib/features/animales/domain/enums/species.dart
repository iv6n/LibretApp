/// Especies principales en ganadería.
enum Species {
  cattle,
  goat,
  sheep,
  pig,
  equine,
  poultry,
  other;

  String get displayName {
    switch (this) {
      case Species.cattle:
        return 'Bovino';
      case Species.goat:
        return 'Caprino';
      case Species.sheep:
        return 'Ovino';
      case Species.pig:
        return 'Porcino';
      case Species.equine:
        return 'Équido';
      case Species.poultry:
        return 'Ave';
      case Species.other:
        return 'Otro';
    }
  }
}
