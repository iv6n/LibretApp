/// Categoría según edad y función del animal.
enum Category {
  calf,
  heifer,
  youngBull,
  steer,
  cow,
  bull,
  oxen,
  weaned,
  juvenile,
  grower,
  fattening,
  production,
  reproduction,
  work,
  guard,
  other;

  String get displayName {
    switch (this) {
      case Category.calf:
        return 'Cría';
      case Category.heifer:
        return 'Novilla';
      case Category.youngBull:
        return 'Torete';
      case Category.steer:
        return 'Novillo';
      case Category.cow:
        return 'Vaca';
      case Category.bull:
        return 'Toro';
      case Category.oxen:
        return 'Buey';
      case Category.weaned:
        return 'Destete';
      case Category.juvenile:
        return 'Cría';
      case Category.grower:
        return 'Recría';
      case Category.fattening:
        return 'Engorda';
      case Category.production:
        return 'Producción';
      case Category.reproduction:
        return 'Reproducción';
      case Category.work:
        return 'Trabajo';
      case Category.guard:
        return 'Guardia';
      case Category.other:
        return 'Otro';
    }
  }
}
