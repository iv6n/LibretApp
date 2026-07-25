/// Estado comercial/vital del animal.
enum AnimalStatus {
  active,
  sold,
  dead,
  archived;

  String get displayName {
    switch (this) {
      case AnimalStatus.active:
        return 'Activo';
      case AnimalStatus.sold:
        return 'Vendido';
      case AnimalStatus.dead:
        return 'Muerto';
      case AnimalStatus.archived:
        return 'Archivado';
    }
  }
}
