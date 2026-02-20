/// Sexo del animal.
enum Sex {
  female,
  male;

  String get displayName {
    switch (this) {
      case Sex.female:
        return 'Hembra';
      case Sex.male:
        return 'Macho';
    }
  }

  String get abbreviation {
    switch (this) {
      case Sex.female:
        return 'H';
      case Sex.male:
        return 'M';
    }
  }
}
