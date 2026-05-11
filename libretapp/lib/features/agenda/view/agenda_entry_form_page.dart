/// features > agenda > view > agenda_entry_form_page — full-screen form route for creating/editing agenda entries.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/agenda/bloc/agenda_bloc.dart';
import 'package:libretapp/features/agenda/bloc/agenda_event.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/widgets/agenda_form_sheet.dart';

class AgendaEntryFormPage extends StatelessWidget {
  const AgendaEntryFormPage({required this.initialDate, this.entry, super.key});

  final DateTime initialDate;
  final AgendaEntry? entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry == null ? 'Nueva tarea / evento' : 'Editar tarea'),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: AgendaEntryForm(
            initialDate: initialDate,
            entry: entry,
            popOnSave: true,
            onSave: (saved) {
              context.read<AgendaBloc>().add(AddAgendaEntry(saved));
            },
          ),
        ),
      ),
    );
  }
}
