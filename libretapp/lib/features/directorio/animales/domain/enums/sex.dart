/// Sexo del animal.
enum Sex {
  female,
  male,
  unknown;

  String get displayName {
    switch (this) {
      case Sex.female:
        return 'Hembra';
      case Sex.male:
        return 'Macho';
      case Sex.unknown:
        return 'Sin dato';
    }
  }

  String get abbreviation {
    switch (this) {
      case Sex.female:
        return 'H';
      case Sex.male:
        return 'M';
      case Sex.unknown:
        return '—';
    }
  }
}
