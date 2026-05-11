/// features › agenda › widgets › agenda_style — styling helpers for agenda widgets.
library;

import 'package:flutter/material.dart';

Color colorForTipo(String tipo) {
  switch (tipo.toLowerCase()) {
    case 'vacunación':
      return Colors.teal;
    case 'desparasitación':
      return const Color(0xFF8BC34A);
    case 'pesaje':
      return Colors.blueAccent;
    case 'revisión veterinaria':
      return Colors.cyan;
    case 'inseminación':
      return const Color(0xFFE91E8C);
    case 'parto':
    case 'gestación':
      return const Color(0xFF9C27B0);
    case 'movimiento de lote':
      return Colors.orange;
    case 'mantenimiento':
      return Colors.amber;
    case 'alerta':
      return Colors.redAccent;
    case 'recordatorio':
      return Colors.indigo;
    default:
      return Colors.blueGrey;
  }
}

IconData iconForTipo(String tipo) {
  switch (tipo.toLowerCase()) {
    case 'vacunación':
      return Icons.vaccines_outlined;
    case 'desparasitación':
      return Icons.bug_report_outlined;
    case 'pesaje':
      return Icons.monitor_weight_outlined;
    case 'revisión veterinaria':
      return Icons.medical_services_outlined;
    case 'inseminación':
      return Icons.favorite_border;
    case 'parto':
    case 'gestación':
      return Icons.child_care;
    case 'movimiento de lote':
      return Icons.swap_horiz;
    case 'mantenimiento':
      return Icons.home_repair_service_outlined;
    case 'alerta':
      return Icons.warning_amber_outlined;
    case 'recordatorio':
      return Icons.alarm;
    default:
      return Icons.event_note;
  }
}

Color colorForEstado(String estado) {
  switch (estado) {
    case 'completado':
      return Colors.green;
    case 'en_progreso':
      return Colors.blue;
    case 'pendiente':
    default:
      return Colors.orange;
  }
}

IconData iconForEstado(String estado) {
  switch (estado) {
    case 'completado':
      return Icons.check_circle_outline;
    case 'en_progreso':
      return Icons.timelapse;
    case 'pendiente':
    default:
      return Icons.schedule;
  }
}

String labelForEstado(String estado) {
  switch (estado) {
    case 'completado':
      return 'Completado';
    case 'en_progreso':
      return 'En progreso';
    case 'pendiente':
    default:
      return 'Pendiente';
  }
}
