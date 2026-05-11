/// features › agenda › widgets › agenda_summary_card — summary card for a single agenda entry.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/widgets/agenda_style.dart';

class AgendaSummaryCard extends StatelessWidget {
  const AgendaSummaryCard({
    super.key,
    required this.entry,
    this.onDelete,
    this.onRealize,
  });

  final AgendaEntry entry;
  final VoidCallback? onDelete;

  /// Called when the user taps "Realizar" to execute the task step-by-step.
  final VoidCallback? onRealize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = colorForTipo(entry.tipo);
    final estadoColor = colorForEstado(entry.estado);
    final timeFormatter = DateFormat('HH:mm');
    final dateFormatter = DateFormat('d MMM, EEEE');

    final totalAnimals = entry.animalIds.length + entry.loteIds.length;
    final completedCount = entry.completedAnimalIds.length;
    final hasAnimals = totalAnimals > 0;
    final isCompleted = entry.estado == AgendaEstado.completado;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onRealize,
            onLongPress: onDelete != null
                ? () => _showDeleteConfirm(context)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: type icon + estado chip + overflow menu
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          iconForTipo(entry.tipo),
                          color: typeColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.tipo,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              timeFormatter.format(entry.fecha),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Estado chip
                      _EstadoChip(estado: entry.estado, color: estadoColor),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showDeleteConfirm(context),
                          constraints: const BoxConstraints.tightFor(
                            width: 40,
                            height: 40,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Título
                  Text(
                    entry.titulo,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (entry.descripcion.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.descripcion,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Progress bar (if animals assigned)
                  if (hasAnimals) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.pets_outlined,
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$completedCount / ${entry.animalIds.length} animales',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${entry.loteIds.isNotEmpty ? '${entry.loteIds.length} lote(s)' : ''}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: entry.animalIds.isEmpty
                            ? 0
                            : completedCount / entry.animalIds.length,
                        minHeight: 6,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(estadoColor),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  // Details row + Realizar button
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (entry.ubicacion.isNotEmpty &&
                                entry.ubicacion != 'Sin ubicación')
                              _DetailChip(
                                icon: Icons.location_on_outlined,
                                label: entry.ubicacion,
                                color: theme.colorScheme.secondary,
                              ),
                            _DetailChip(
                              icon: Icons.calendar_today_outlined,
                              label: dateFormatter.format(entry.fecha),
                              color: theme.colorScheme.outline,
                            ),
                          ],
                        ),
                      ),
                      if (!isCompleted && onRealize != null)
                        FilledButton.tonalIcon(
                          onPressed: onRealize,
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('Realizar'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Eliminar "${entry.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true) onDelete?.call();
  }
}

class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.estado, required this.color});
  final String estado;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconForEstado(estado), size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            labelForEstado(estado),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: color),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
