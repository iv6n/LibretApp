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
      case Category.other:
        return 'Otro';
    }
  }
}
