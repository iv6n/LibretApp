/// features › agenda › widgets › agenda_style — styling helpers for agenda widgets.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/assets/app_asset_paths.dart';
import 'package:libretapp/theme/app_theme.dart';

String _agendaKey(String value) => value
    .toLowerCase()
    .trim()
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll('ü', 'u')
    .replaceAll('ñ', 'n')
    .replaceAll(' ', '_');

String? assetForTipo(String tipo) {
  switch (_agendaKey(tipo)) {
    case 'ordena':
    case 'ordeno':
      return AppAssetPaths.taskMilking;
    case 'bano_garrapaticida':
      return AppAssetPaths.taskTickBath;
    case 'suplemento/vitaminas':
    case 'suplemento_/_vitaminas':
      return AppAssetPaths.taskVitamins;
    case 'revision_de_casco':
      return AppAssetPaths.taskHoofCheck;
    case 'chequeo_reproductivo':
      return AppAssetPaths.taskReproductiveCheck;
    case 'fertilizacion':
      return AppAssetPaths.taskFertilization;
    case 'fumigacion':
      return AppAssetPaths.taskFumigation;
    case 'cosecha':
      return AppAssetPaths.taskHarvest;
    case 'desparasitacion':
    case 'desparasitar':
      return AppAssetPaths.taskDeworming;
    case 'vacunacion':
    case 'vacunacion_anual':
    case 'vacuna_anual':
      return AppAssetPaths.taskAnnualVaccination;
    case 'pesaje':
      return AppAssetPaths.healthWeight;
    case 'revision_veterinaria':
    case 'sanidad':
    case 'sanitario':
      return AppAssetPaths.healthDiagnosis;
    case 'parto':
      return AppAssetPaths.healthBirth;
    case 'gestacion':
    case 'inseminacion':
      return AppAssetPaths.healthReproduction;
    case 'movimiento_de_lote':
      return AppAssetPaths.recordMovement;
    case 'comercial':
      return AppAssetPaths.recordSale;
    case 'cultivo':
      return AppAssetPaths.cropField;
    case 'mantenimiento':
      return AppAssetPaths.inventoryTool;
    case 'riego':
      return AppAssetPaths.recordIrrigation;
    case 'administrativo':
    case 'administracion':
      return AppAssetPaths.recordAdministration;
    case 'alerta':
      return AppAssetPaths.recordAlert;
    case 'recordatorio':
      return AppAssetPaths.recordReminder;
    case 'cuidado':
      return AppAssetPaths.recordCare;
    default:
      return null;
  }
}

String? assetForEstado(String estado) {
  switch (_agendaKey(estado)) {
    case 'pendiente':
      return AppAssetPaths.statusPending;
    case 'completado':
      return AppAssetPaths.statusCompleted;
    case 'vencido':
      return AppAssetPaths.statusOverdue;
    case 'en_progreso':
      return AppAssetPaths.statusInProgress;
    case 'cancelado':
    case 'canceled':
      return AppAssetPaths.statusCanceled;
    case 'critico':
    case 'critical':
      return AppAssetPaths.statusCritical;
    case 'en_cuarentena':
    case 'cuarentena':
      return AppAssetPaths.statusQuarantine;
    case 'sincronizado':
    case 'synced':
      return AppAssetPaths.statusSynced;
    case 'sin_conexion':
    case 'offline':
      return AppAssetPaths.statusOffline;
    case 'verificado':
      return AppAssetPaths.statusVerified;
    case 'reprogramada':
    case 'reprogramado':
      return AppAssetPaths.statusReprogrammed;
    case 'borrador':
      return AppAssetPaths.statusDraft;
    case 'bloqueado':
      return AppAssetPaths.statusBlocked;
    default:
      return null;
  }
}

class AgendaAssetIcon extends StatelessWidget {
  const AgendaAssetIcon({
    required this.assetPath,
    required this.fallbackIcon,
    this.size = 20,
    this.color,
    super.key,
  });

  final String? assetPath;
  final IconData fallbackIcon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (assetPath == null) {
      return Icon(fallbackIcon, size: size, color: color);
    }
    return Image.asset(
      assetPath!,
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => Icon(fallbackIcon, size: size, color: color),
    );
  }
}

Color colorForTipo(String tipo) {
  switch (_agendaKey(tipo)) {
    case 'vacunacion':
      return AppColors.primary;
    case 'desparasitacion':
      return AppColors.success;
    case 'pesaje':
      return AppColors.secondary;
    case 'revision_veterinaria':
    case 'sanidad':
    case 'sanitario':
      return const Color(0xFF3A7F78);
    case 'inseminacion':
      return AppColors.earth;
    case 'parto':
    case 'gestacion':
      return const Color(0xFF8B623A);
    case 'movimiento_de_lote':
      return AppColors.earth;
    case 'mantenimiento':
      return AppColors.amber;
    case 'alerta':
      return Colors.redAccent;
    case 'recordatorio':
      return AppColors.secondary;
    case 'bano_garrapaticida':
      return const Color(0xFF6E8B3D);
    case 'suplemento/vitaminas':
    case 'suplemento_/_vitaminas':
      return AppColors.amber;
    case 'revision_de_casco':
      return const Color(0xFF3A7F78);
    case 'chequeo_reproductivo':
      return AppColors.earth;
    case 'cuidado':
      return AppColors.primary;
    case 'comercial':
      return const Color(0xFF7A4FA3);
    case 'cultivo':
      return AppColors.primary;
    default:
      return AppColors.primary;
  }
}

IconData iconForTipo(String tipo) {
  switch (_agendaKey(tipo)) {
    case 'vacunacion':
      return Icons.vaccines_outlined;
    case 'desparasitacion':
      return Icons.bug_report_outlined;
    case 'pesaje':
      return Icons.monitor_weight_outlined;
    case 'revision_veterinaria':
    case 'sanidad':
    case 'sanitario':
      return Icons.medical_services_outlined;
    case 'inseminacion':
      return Icons.favorite_border;
    case 'parto':
    case 'gestacion':
      return Icons.child_care;
    case 'movimiento_de_lote':
      return Icons.swap_horiz;
    case 'mantenimiento':
      return Icons.home_repair_service_outlined;
    case 'alerta':
      return Icons.warning_amber_outlined;
    case 'recordatorio':
      return Icons.alarm;
    case 'bano_garrapaticida':
      return Icons.water_drop_outlined;
    case 'suplemento/vitaminas':
    case 'suplemento_/_vitaminas':
      return Icons.medication_outlined;
    case 'revision_de_casco':
      return Icons.pets_outlined;
    case 'chequeo_reproductivo':
      return Icons.favorite_outline;
    case 'cuidado':
      return Icons.health_and_safety_outlined;
    case 'comercial':
      return Icons.storefront_outlined;
    case 'cultivo':
      return Icons.grass_outlined;
    default:
      return Icons.event_note;
  }
}

Color colorForEstado(String estado) {
  switch (estado) {
    case 'verificado':
    case 'completado':
      return AppColors.success;
    case 'reprogramada':
      return AppColors.warning;
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
    case 'reprogramada':
      return Icons.event_repeat_outlined;
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
    case 'reprogramada':
      return 'Reprogramada';
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
