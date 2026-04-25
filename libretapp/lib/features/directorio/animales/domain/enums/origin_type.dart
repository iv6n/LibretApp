/// Tipo de origen del animal en el registro.
enum OriginType {
  own,
  purchased,
  gift;

  String get displayName {
    switch (this) {
      case OriginType.own:
        return 'Propio';
      case OriginType.purchased:
        return 'Comprado';
      case OriginType.gift:
        return 'Regalo / Intercambio';
    }
  }
}
