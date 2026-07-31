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

  /// Reads a value persisted before this field was typed.
  ///
  /// The column has always been a plain string, and what landed in it depended
  /// on the app version that wrote it: enum names (`purchased`) from the
  /// registration wizard, but also Spanish labels (`Compra`, `Comprado`) from
  /// earlier builds. Parsing both here keeps the migration out of the mappers
  /// and means no stored row has to be rewritten.
  ///
  /// Returns null for empty or unrecognised input rather than guessing, so an
  /// unknown origin stays unknown instead of silently becoming `own`.
  static OriginType? fromStored(String? raw) {
    final value = raw?.trim().toLowerCase();
    if (value == null || value.isEmpty) return null;

    switch (value) {
      case 'own':
      case 'propio':
      case 'propia':
      case 'nacido en la finca':
        return OriginType.own;
      case 'purchased':
      case 'comprado':
      case 'compra':
      case 'comprada':
        return OriginType.purchased;
      case 'gift':
      case 'regalo':
      case 'intercambio':
      case 'regalo / intercambio':
        return OriginType.gift;
      default:
        return null;
    }
  }
}
