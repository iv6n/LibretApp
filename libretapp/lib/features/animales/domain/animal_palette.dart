import 'package:flutter/material.dart';
import 'package:libretapp/features/animales/domain/animal_domain.dart';

/// Centralized stage colors to keep a single palette across the app.
class AnimalPalette {
  static const Color calf = Color(0xFFF3A55A); // naranja (becerro/potro)
  static const Color heifer = Color(0xFF7D5EE4); // violeta
  static const Color cow = Color(0xFFE65F94); // rosa
  static const Color bull = Color(0xFF1DA2C6); // azul
  static const Color youngBull = Color(0xFF25B0CE); // azul claro
  static const Color steer = Color(0xFF4FB27A); // verde
  static const Color horse = Color(0xFFF6C344); // amarillo
  static const Color donkey = Color(0xFF9AA3AE); // gris
  static const Color mule = Color(0xFFA67C52); // café
  static const Color fallback = Color(0xFF4FB27A);

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
