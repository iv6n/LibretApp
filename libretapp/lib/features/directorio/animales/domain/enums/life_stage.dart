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
  mule,
  kid,
  youngGoat,
  goat,
  breedingBuck,
  lamb,
  youngSheep,
  ewe,
  ram,
  piglet,
  youngPig,
  sow,
  boar,
  chick,
  pullet,
  hen,
  rooster,
  puppy,
  youngDog,
  workingDog,
  guardDog;

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
      case LifeStage.kid:
        return 'Cabrito';
      case LifeStage.youngGoat:
        return 'Chivo joven';
      case LifeStage.goat:
        return 'Cabra';
      case LifeStage.breedingBuck:
        return 'Macho reproductor';
      case LifeStage.lamb:
        return 'Cordero';
      case LifeStage.youngSheep:
        return 'Borrego';
      case LifeStage.ewe:
        return 'Oveja';
      case LifeStage.ram:
        return 'Carnero';
      case LifeStage.piglet:
        return 'Lechón';
      case LifeStage.youngPig:
        return 'Cerdo joven';
      case LifeStage.sow:
        return 'Cerda';
      case LifeStage.boar:
        return 'Verraco';
      case LifeStage.chick:
        return 'Pollito';
      case LifeStage.pullet:
        return 'Ave joven';
      case LifeStage.hen:
        return 'Gallina';
      case LifeStage.rooster:
        return 'Gallo';
      case LifeStage.puppy:
        return 'Cachorro';
      case LifeStage.youngDog:
        return 'Joven';
      case LifeStage.workingDog:
        return 'Adulto trabajo';
      case LifeStage.guardDog:
        return 'Adulto guardia';
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
      case LifeStage.kid:
      case LifeStage.lamb:
      case LifeStage.piglet:
      case LifeStage.chick:
      case LifeStage.puppy:
        return 0;
      case LifeStage.heifer:
      case LifeStage.youngBull:
      case LifeStage.steer:
      case LifeStage.youngGoat:
      case LifeStage.youngSheep:
      case LifeStage.youngPig:
      case LifeStage.pullet:
      case LifeStage.youngDog:
        return 12;
      case LifeStage.cow:
      case LifeStage.bull:
      case LifeStage.goat:
      case LifeStage.breedingBuck:
      case LifeStage.ewe:
      case LifeStage.ram:
      case LifeStage.sow:
      case LifeStage.boar:
      case LifeStage.hen:
      case LifeStage.rooster:
      case LifeStage.workingDog:
      case LifeStage.guardDog:
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
      case LifeStage.kid:
      case LifeStage.lamb:
      case LifeStage.piglet:
      case LifeStage.chick:
      case LifeStage.puppy:
        return 12;
      case LifeStage.heifer:
      case LifeStage.youngBull:
      case LifeStage.steer:
      case LifeStage.youngGoat:
      case LifeStage.youngSheep:
      case LifeStage.youngPig:
      case LifeStage.pullet:
      case LifeStage.youngDog:
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
      case LifeStage.goat:
      case LifeStage.breedingBuck:
      case LifeStage.ewe:
      case LifeStage.ram:
      case LifeStage.sow:
      case LifeStage.boar:
      case LifeStage.hen:
      case LifeStage.rooster:
      case LifeStage.workingDog:
      case LifeStage.guardDog:
        return null;
    }
  }
}
