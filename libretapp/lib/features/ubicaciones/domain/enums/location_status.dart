/// features › ubicaciones › domain › enums › location_status — status of a location.
library;

import 'package:flutter/material.dart';

enum LocationStatus { disponible, enUso, enDescanso, clausurado, enPreparacion }

extension LocationStatusX on LocationStatus {
  String get label {
    switch (this) {
      case LocationStatus.disponible:
        return 'Disponible';
      case LocationStatus.enUso:
        return 'En uso';
      case LocationStatus.enDescanso:
        return 'En descanso';
      case LocationStatus.clausurado:
        return 'Clausurado';
      case LocationStatus.enPreparacion:
        return 'En preparación';
    }
  }

  Color get color {
    switch (this) {
      case LocationStatus.disponible:
        return const Color(0xFF2E7D32); // green
      case LocationStatus.enUso:
        return const Color(0xFF1565C0); // blue
      case LocationStatus.enDescanso:
        return const Color(0xFFE65100); // orange
      case LocationStatus.clausurado:
        return const Color(0xFFC62828); // red
      case LocationStatus.enPreparacion:
        return const Color(0xFF6A1B9A); // purple
    }
  }

  Color get backgroundColor {
    switch (this) {
      case LocationStatus.disponible:
        return const Color(0xFFE8F5E9);
      case LocationStatus.enUso:
        return const Color(0xFFE3F2FD);
      case LocationStatus.enDescanso:
        return const Color(0xFFFFF3E0);
      case LocationStatus.clausurado:
        return const Color(0xFFFFEBEE);
      case LocationStatus.enPreparacion:
        return const Color(0xFFF3E5F5);
    }
  }
}
