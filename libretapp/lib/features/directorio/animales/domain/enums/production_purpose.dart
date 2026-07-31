/// Propósito de producción del animal.
enum ProductionPurpose {
  breeding,
  dairy,
  meat,
  dual,
  work,
  companion,
  sport,
  eggs,
  fiber,
  guard,
  undefined,
  other;

  String get displayName {
    switch (this) {
      case ProductionPurpose.breeding:
        return 'Reproducción';
      case ProductionPurpose.dairy:
        return 'Lechería';
      case ProductionPurpose.meat:
        return 'Carne';
      case ProductionPurpose.dual:
        return 'Doble Propósito';
      case ProductionPurpose.work:
        return 'Trabajo';
      case ProductionPurpose.companion:
        return 'Compañía';
      case ProductionPurpose.sport:
        return 'Deporte';
      case ProductionPurpose.eggs:
        return 'Postura';
      case ProductionPurpose.fiber:
        return 'Fibra / Lana';
      case ProductionPurpose.guard:
        return 'Guardia';
      case ProductionPurpose.undefined:
        return 'Por Definir';
      case ProductionPurpose.other:
        return 'Otro';
    }
  }
}
