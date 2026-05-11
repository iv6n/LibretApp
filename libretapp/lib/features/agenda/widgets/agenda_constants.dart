/// features › agenda › widgets › agenda_constants — constants used by agenda widgets.
library;

import 'package:flutter/material.dart';

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
    color: Colors.teal,
    label: 'Vacunación',
    icon: Icons.vaccines_outlined,
  ),
  AgendaLegendItem(
    color: Color(0xFF8BC34A),
    label: 'Desparasitación',
    icon: Icons.bug_report_outlined,
  ),
  AgendaLegendItem(
    color: Colors.blueAccent,
    label: 'Pesaje',
    icon: Icons.monitor_weight_outlined,
  ),
  AgendaLegendItem(
    color: Colors.cyan,
    label: 'Revisión veterinaria',
    icon: Icons.medical_services_outlined,
  ),
  AgendaLegendItem(
    color: Color(0xFFE91E8C),
    label: 'Inseminación',
    icon: Icons.favorite_border,
  ),
  AgendaLegendItem(
    color: Color(0xFF9C27B0),
    label: 'Parto',
    icon: Icons.child_care,
  ),
  AgendaLegendItem(
    color: Colors.orange,
    label: 'Movimiento de lote',
    icon: Icons.swap_horiz,
  ),
  AgendaLegendItem(
    color: Colors.amber,
    label: 'Mantenimiento',
    icon: Icons.home_repair_service_outlined,
  ),
  AgendaLegendItem(
    color: Colors.redAccent,
    label: 'Alerta',
    icon: Icons.warning_amber_outlined,
  ),
  AgendaLegendItem(
    color: Colors.indigo,
    label: 'Recordatorio',
    icon: Icons.alarm,
  ),
];
