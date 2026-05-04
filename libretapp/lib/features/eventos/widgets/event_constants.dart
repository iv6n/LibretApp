/// features \u203a eventos \u203a widgets \u203a event_constants \u2014 constants used by eventos widgets.
library;

import 'package:flutter/material.dart';

class EventLegendItem {
  const EventLegendItem({required this.color, required this.label});
  final Color color;
  final String label;
}

const eventTypes = <String>[
  'Vacunación',
  'Mantenimiento',
  'Alerta',
  'Recordatorio',
];

const eventLegendItems = <EventLegendItem>[
  EventLegendItem(color: Colors.teal, label: 'Vacunación'),
  EventLegendItem(color: Colors.amber, label: 'Mantenimiento'),
  EventLegendItem(color: Colors.redAccent, label: 'Alerta'),
  EventLegendItem(color: Colors.indigo, label: 'Recordatorio'),
];
