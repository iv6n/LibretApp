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

  /// El animal sigue formando parte del hato que se maneja y se cuenta.
  ///
  /// Vendidos, muertos y archivados conservan su historial y su lugar en la
  /// genealogía —una cría vendida sigue contando en el rendimiento de su
  /// madre— pero no comen del potrero ni deben entrar en los inventarios.
  bool get isInActiveHerd => this == AnimalStatus.active;
}
