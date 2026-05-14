/// features › ubicaciones › domain › enums › location_type — enum for the specific type of a location.
library;

enum LocationType {
  rancho,
  potrero,
  monte,
  corral,
  almacenamiento,
  aguada,
  siembra,
  casa,
}

extension LocationTypeX on LocationType {
  String get label {
    switch (this) {
      case LocationType.rancho:
        return 'Rancho';
      case LocationType.potrero:
        return 'Potrero';
      case LocationType.monte:
        return 'Monte';
      case LocationType.corral:
        return 'Corral';
      case LocationType.almacenamiento:
        return 'Almacenamiento / Bodega';
      case LocationType.aguada:
        return 'Aguada / Represa';
      case LocationType.siembra:
        return 'Siembra';
      case LocationType.casa:
        return 'Casa';
    }
  }

  bool get isRootType => this == LocationType.rancho;

  bool get supportsAnimals => const {
        LocationType.potrero,
        LocationType.monte,
        LocationType.corral,
      }.contains(this);

  bool get supportsInventory => const {
        LocationType.almacenamiento,
        LocationType.casa,
        LocationType.corral,
      }.contains(this);
}
