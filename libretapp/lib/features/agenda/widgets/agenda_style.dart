/// features › agenda › widgets › agenda_style — styling helpers for agenda widgets.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/theme/app_theme.dart';

Color colorForTipo(String tipo) {
  switch (tipo.toLowerCase()) {
    case 'vacunación':
      return AppColors.primary;
    case 'desparasitación':
      return AppColors.success;
    case 'pesaje':
      return AppColors.secondary;
    case 'revisión veterinaria':
      return const Color(0xFF3A7F78);
    case 'inseminación':
      return AppColors.earth;
    case 'parto':
    case 'gestación':
      return const Color(0xFF8B623A);
    case 'movimiento de lote':
      return AppColors.earth;
    case 'mantenimiento':
      return AppColors.amber;
    case 'alerta':
      return Colors.redAccent;
    case 'recordatorio':
      return AppColors.secondary;
    case 'baño garrapaticida':
      return const Color(0xFF6E8B3D);
    case 'suplemento/vitaminas':
      return AppColors.amber;
    case 'revisión de casco':
      return const Color(0xFF3A7F78);
    case 'chequeo reproductivo':
      return AppColors.earth;
    case 'cuidado':
      return AppColors.primary;
    default:
      return AppColors.primary;
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
    case 'baño garrapaticida':
      return Icons.water_drop_outlined;
    case 'suplemento/vitaminas':
      return Icons.medication_outlined;
    case 'revisión de casco':
      return Icons.pets_outlined;
    case 'chequeo reproductivo':
      return Icons.favorite_outline;
    case 'cuidado':
      return Icons.health_and_safety_outlined;
    default:
      return Icons.event_note;
  }
}

Color colorForEstado(String estado) {
  switch (estado) {
    case 'verificado':
    case 'completado':
      return AppColors.success;
    case 'en_progreso':
      return AppColors.secondary;
    case 'bloqueado':
    case 'cancelado':
      return Colors.redAccent;
    case 'borrador':
      return Colors.blueGrey;
    case 'pendiente':
    default:
      return AppColors.amber;
  }
}

IconData iconForEstado(String estado) {
  switch (estado) {
    case 'verificado':
      return Icons.verified_outlined;
    case 'completado':
      return Icons.check_circle_outline;
    case 'en_progreso':
      return Icons.timelapse;
    case 'bloqueado':
      return Icons.pause_circle_outline;
    case 'cancelado':
      return Icons.cancel_outlined;
    case 'borrador':
      return Icons.edit_note_outlined;
    case 'pendiente':
    default:
      return Icons.schedule;
  }
}

String labelForEstado(String estado) {
  switch (estado) {
    case 'verificado':
      return 'Verificado';
    case 'completado':
      return 'Completado';
    case 'en_progreso':
      return 'En progreso';
    case 'bloqueado':
      return 'Bloqueado';
    case 'cancelado':
      return 'Cancelado';
    case 'borrador':
      return 'Borrador';
    case 'pendiente':
    default:
      return 'Pendiente';
  }
}
