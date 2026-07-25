/// features › agenda › widgets › agenda_constants — constants used by agenda widgets.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/theme/app_theme.dart';

class AgendaLegendItem {
  const AgendaLegendItem({
    required this.color,
    required this.label,
    required this.icon,
  });
  final Color color;
  final String label;
  final IconData icon;
}

const agendaTipos = <String>[
  'Vacunación',
  'Desparasitación',
  'Pesaje',
  'Revisión veterinaria',
  'Inseminación',
  'Parto',
  'Movimiento de lote',
  'Mantenimiento',
  'Alerta',
  'Recordatorio',
];

const agendaLegendItems = <AgendaLegendItem>[
  AgendaLegendItem(
    color: AppColors.primary,
    label: 'Vacunación',
    icon: Icons.vaccines_outlined,
  ),
  AgendaLegendItem(
    color: AppColors.success,
    label: 'Desparasitación',
    icon: Icons.bug_report_outlined,
  ),
  AgendaLegendItem(
    color: AppColors.secondary,
    label: 'Pesaje',
    icon: Icons.monitor_weight_outlined,
  ),
  AgendaLegendItem(
    color: Color(0xFF3A7F78),
    label: 'Revisión veterinaria',
    icon: Icons.medical_services_outlined,
  ),
  AgendaLegendItem(
    color: AppColors.earth,
    label: 'Inseminación',
    icon: Icons.favorite_border,
  ),
  AgendaLegendItem(
    color: Color(0xFF8B623A),
    label: 'Parto',
    icon: Icons.child_care,
  ),
  AgendaLegendItem(
    color: AppColors.earth,
    label: 'Movimiento de lote',
    icon: Icons.swap_horiz,
  ),
  AgendaLegendItem(
    color: AppColors.amber,
    label: 'Mantenimiento',
    icon: Icons.home_repair_service_outlined,
  ),
  AgendaLegendItem(
    color: Colors.redAccent,
    label: 'Alerta',
    icon: Icons.warning_amber_outlined,
  ),
  AgendaLegendItem(
    color: AppColors.secondary,
    label: 'Recordatorio',
    icon: Icons.alarm,
  ),
];
