/// features › agenda › view › agenda_page — BLoC provider entry point for the Agenda feature.
library;

import 'package:libretapp/features/agenda/view/agenda_view.dart';
import 'package:flutter/material.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AgendaView();
  }
}
