import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';

/// Centralized stage colors to keep a single palette across the app.
class AnimalPalette {
  static const Color calf = Color(0xFFE08A3F); // naranja más sólido
  static const Color heifer = Color(0xFF5C46C5); // violeta profundo
  static const Color cow = Color(0xFFD14F86); // rosa intenso
  static const Color bull = Color(0xFF157A9C); // azul ganado
  static const Color youngBull = Color(0xFF1D8FB0); // azul medio
  static const Color steer = Color(0xFF2F8C5E); // verde sólido
  static const Color horse = Color(0xFFE0AE1F); // amarillo más cálido
  static const Color donkey = Color(0xFF7A828C); // gris contrastado
  static const Color mule = Color(0xFF8B623A); // café profundo
  static const Color fallback = Color(0xFF2F8C5E);

  static Color stageColor(LifeStage stage) {
    switch (stage) {
      case LifeStage.calf:
      case LifeStage.calfMale:
      case LifeStage.calfFemale:
      case LifeStage.colt:
      case LifeStage.filly:
        return calf;
      case LifeStage.heifer:
        return heifer;
      case LifeStage.youngBull:
        return youngBull;
      case LifeStage.cow:
        return cow;
      case LifeStage.bull:
        return bull;
      case LifeStage.steer:
        return steer;
      case LifeStage.horse:
      case LifeStage.mare:
        return horse;
      case LifeStage.donkey:
      case LifeStage.donkeyFemale:
        return donkey;
      case LifeStage.mule:
        return mule;
    }
  }
}
