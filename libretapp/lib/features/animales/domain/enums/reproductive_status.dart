/// Estado reproductivo del animal.
enum ReproductiveStatus {
  virgin,
  active,
  pregnant,
  lactating,
  dry,
  neutered,
  retired,
  unknown;

  String get displayName {
    switch (this) {
      case ReproductiveStatus.virgin:
        return 'Virgen';
      case ReproductiveStatus.active:
        return 'Activa';
      case ReproductiveStatus.pregnant:
        return 'Gestante';
      case ReproductiveStatus.lactating:
        return 'Lactante';
      case ReproductiveStatus.dry:
        return 'Secada';
      case ReproductiveStatus.neutered:
        return 'Castrado/a';
      case ReproductiveStatus.retired:
        return 'Retirada';
      case ReproductiveStatus.unknown:
        return 'Desconocido';
    }
  }
}
