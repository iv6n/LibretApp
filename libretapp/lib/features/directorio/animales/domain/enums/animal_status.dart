/// Estado comercial/vital del animal.
enum AnimalStatus {
  active,
  sold,
  dead;

  String get displayName {
    switch (this) {
      case AnimalStatus.active:
        return 'Activo';
      case AnimalStatus.sold:
        return 'Vendido';
      case AnimalStatus.dead:
        return 'Muerto';
    }
  }
}
