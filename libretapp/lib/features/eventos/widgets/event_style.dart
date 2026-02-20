import 'package:flutter/material.dart';

Color colorForTipo(String tipo) {
  switch (tipo.toLowerCase()) {
    case 'vacunación':
      return Colors.teal;
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
