/// Etapa de vida del animal.
enum LifeStage {
  calf,
  calfMale,
  calfFemale,
  heifer,
  youngBull,
  steer,
  cow,
  bull,
  colt,
  filly,
  horse,
  mare,
  donkey,
  donkeyFemale,
  mule;

  String get displayName {
    switch (this) {
      case LifeStage.calf:
        return 'Becerro';
      case LifeStage.calfMale:
        return 'Becerro';
      case LifeStage.calfFemale:
        return 'Becerra';
      case LifeStage.heifer:
        return 'Vaquilla';
      case LifeStage.youngBull:
        return 'Torete';
      case LifeStage.steer:
        return 'Novillo';
      case LifeStage.cow:
        return 'Vaca';
      case LifeStage.bull:
        return 'Toro';
      case LifeStage.colt:
        return 'Potro';
      case LifeStage.filly:
        return 'Potranca';
      case LifeStage.horse:
        return 'Caballo';
      case LifeStage.mare:
        return 'Yegua';
      case LifeStage.donkey:
        return 'Burro';
      case LifeStage.donkeyFemale:
        return 'Burra';
      case LifeStage.mule:
        return 'Mula';
    }
  }

  int get minAgeMonths {
    switch (this) {
      case LifeStage.calf:
      case LifeStage.calfMale:
      case LifeStage.calfFemale:
      case LifeStage.colt:
      case LifeStage.filly:
      case LifeStage.donkey:
      case LifeStage.donkeyFemale:
      case LifeStage.mule:
        return 0;
      case LifeStage.heifer:
      case LifeStage.youngBull:
      case LifeStage.steer:
        return 12;
      case LifeStage.cow:
      case LifeStage.bull:
        return 24;
      case LifeStage.horse:
      case LifeStage.mare:
        return 36;
    }
  }

  int? get maxAgeMonths {
    switch (this) {
      case LifeStage.calf:
      case LifeStage.calfMale:
      case LifeStage.calfFemale:
        return 12;
      case LifeStage.heifer:
      case LifeStage.youngBull:
      case LifeStage.steer:
        return 24;
      case LifeStage.colt:
      case LifeStage.filly:
        return 36;
      case LifeStage.cow:
      case LifeStage.bull:
      case LifeStage.horse:
      case LifeStage.mare:
      case LifeStage.donkey:
      case LifeStage.donkeyFemale:
      case LifeStage.mule:
        return null;
    }
  }
}
