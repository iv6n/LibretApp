/// features \u203a eventos \u203a widgets \u203a event_list \u2014 scrollable list of events for a selected day.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/features/eventos/data/eventos_model.dart';
import 'package:libretapp/features/eventos/widgets/event_style.dart';

class EventList extends StatelessWidget {
  const EventList({
    super.key,
    required this.eventos,
    required this.emptyLabel,
    required this.onDelete,
  });

  final List<Evento> eventos;
  final String emptyLabel;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (eventos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 32),
            const SizedBox(height: 8),
            Text(emptyLabel, style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    final formatter = DateFormat('EEEE d MMM, HH:mm');

    return ListView.separated(
      itemCount: eventos.length,
      separatorBuilder: (context, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final evento = eventos[index];
        final color = colorForTipo(evento.tipo);
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.18),
              child: Icon(iconForTipo(evento.tipo), color: color),
            ),
            title: Text(evento.titulo),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatter.format(evento.fecha)),
                Text(
                  '${evento.tipo} · ${evento.ubicacion} · ${evento.animalId}',
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Eliminar',
              onPressed: () => onDelete(evento.id),
            ),
          ),
        );
      },
    );
  }
}
