/// features › agenda › widgets › agenda_list — scrollable list of agenda entries.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/widgets/agenda_style.dart';

class AgendaList extends StatelessWidget {
  const AgendaList({
    super.key,
    required this.entries,
    required this.emptyLabel,
    required this.onDelete,
    this.onRealize,
  });

  final List<AgendaEntry> entries;
  final String emptyLabel;
  final ValueChanged<String> onDelete;
  final ValueChanged<AgendaEntry>? onRealize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (entries.isEmpty) {
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
      itemCount: entries.length,
      separatorBuilder: (context, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final typeColor = colorForTipo(entry.tipo);
        final estadoColor = colorForEstado(entry.estado);
        final isCompleted = entry.estado == AgendaEstado.completado;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: typeColor.withValues(alpha: 0.18),
              child: Icon(iconForTipo(entry.tipo), color: typeColor),
            ),
            title: Text(
              entry.titulo,
              style: theme.textTheme.bodyMedium?.copyWith(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatter.format(entry.fecha)),
                Row(
                  children: [
                    Text('${entry.tipo} · ${entry.ubicacion}'),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: estadoColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        labelForEstado(entry.estado),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: estadoColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isCompleted && onRealize != null)
                  IconButton(
                    icon: Icon(
                      Icons.play_arrow,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: 'Realizar',
                    onPressed: () => onRealize!(entry),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Eliminar',
                  onPressed: () => onDelete(entry.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
