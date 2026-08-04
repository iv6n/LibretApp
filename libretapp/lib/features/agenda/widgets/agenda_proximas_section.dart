/// Agenda worklist rendered as category headers and one card per logical
/// event. Every card contains an expandable, bounded animal list.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/features/agenda/domain/agenda_categoria.dart';
import 'package:libretapp/features/agenda/domain/agenda_task_grouping.dart';
import 'package:libretapp/features/agenda/widgets/agenda_style.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/theme/theme.dart';

class AgendaProximasSection extends StatefulWidget {
  const AgendaProximasSection({
    required this.groups,
    required this.animalsById,
    required this.today,
    required this.onOpenGroup,
    this.emptyTitle = 'Sin pendientes',
    this.emptyMessage = 'No hay tareas atrasadas ni próximas por ahora.',
    super.key,
  });

  final List<AgendaCategoryGroup> groups;
  final Map<String, AnimalEntity> animalsById;
  final DateTime today;
  final ValueChanged<AgendaEventGroup> onOpenGroup;
  final String emptyTitle;
  final String emptyMessage;

  @override
  State<AgendaProximasSection> createState() => _AgendaProximasSectionState();
}

class _AgendaProximasSectionState extends State<AgendaProximasSection> {
  final Set<String> _expandedEvents = {};

  void _toggleEvent(String key) {
    setState(() {
      if (!_expandedEvents.add(key)) _expandedEvents.remove(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.groups.isEmpty) {
      return AppEmptyState(
        icon: Icons.task_alt_outlined,
        title: widget.emptyTitle,
        message: widget.emptyMessage,
        compact: true,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (
          var categoryIndex = 0;
          categoryIndex < widget.groups.length;
          categoryIndex++
        ) ...[
          _CategoryHeader(group: widget.groups[categoryIndex]),
          const SizedBox(height: AppSpacing.xs),
          for (final event in widget.groups[categoryIndex].events) ...[
            _AgendaEventCard(
              event: event,
              today: widget.today,
              animalsById: widget.animalsById,
              expanded: _expandedEvents.contains(event.key),
              onToggle: () => _toggleEvent(event.key),
              onOpen: () => widget.onOpenGroup(event),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (categoryIndex != widget.groups.length - 1)
            const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.group});

  final AgendaCategoryGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            _iconForCategory(group.categoria),
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              group.categoria.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AppChip(label: '${group.events.length}', tone: AppChipTone.neutral),
        ],
      ),
    );
  }
}

class _AgendaEventCard extends StatelessWidget {
  const _AgendaEventCard({
    required this.event,
    required this.today,
    required this.animalsById,
    required this.expanded,
    required this.onToggle,
    required this.onOpen,
  });

  final AgendaEventGroup event;
  final DateTime today;
  final Map<String, AnimalEntity> animalsById;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  bool get _overdue => event.rows.any((row) => row.isOverdue(today));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventColor = colorForTipo(event.tipo);
    final pendingAnimals = event.rows
        .where((row) => row.animalId != null)
        .length;
    final ranchTasks = event.rows.where((row) => row.animalId == null).length;
    final countLabel = pendingAnimals > 0
        ? '$pendingAnimals ${pendingAnimals == 1 ? 'animal' : 'animales'}'
        : '$ranchTasks ${ranchTasks == 1 ? 'tarea' : 'tareas'}';

    return AppCard(
      padding: EdgeInsets.zero,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: eventColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Icon(
                      iconForTipo(event.tipo),
                      color: eventColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xxs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              event.tipo,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: eventColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _dueLabel(event.primaryEntry.fecha, today),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _overdue
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.outline,
                                fontWeight: _overdue
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AppChip(
                    label: countLabel,
                    tone: _overdue ? AppChipTone.error : AppChipTone.neutral,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  IconButton(
                    key: ValueKey('agenda-event-toggle-${event.key}'),
                    onPressed: onToggle,
                    tooltip: expanded ? 'Ocultar animales' : 'Ver animales',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            _BoundedAnimalList(
              event: event,
              today: today,
              animalsById: animalsById,
              onOpen: onOpen,
            ),
          ],
        ],
      ),
    );
  }
}

class _BoundedAnimalList extends StatelessWidget {
  const _BoundedAnimalList({
    required this.event,
    required this.today,
    required this.animalsById,
    required this.onOpen,
  });

  final AgendaEventGroup event;
  final DateTime today;
  final Map<String, AnimalEntity> animalsById;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    const rowExtent = 48.0;
    final visibleRows = math.min(event.rows.length, 5);
    final height = math.max(rowExtent, visibleRows * rowExtent);

    return SizedBox(
      height: height,
      child: Scrollbar(
        child: ListView.separated(
          primary: false,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          itemCount: event.rows.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final row = event.rows[index];
            final animal = row.animalId == null
                ? null
                : animalsById[row.animalId];
            return InkWell(
              onTap: onOpen,
              child: SizedBox(
                height: rowExtent - 1,
                child: Row(
                  children: [
                    Icon(
                      row.animalId == null
                          ? Icons.task_alt_outlined
                          : Icons.pets_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        row.animalId == null
                            ? row.entry.titulo
                            : _animalLabel(animal, row.animalId!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _dueLabel(row.entry.fecha, today),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: row.isOverdue(today)
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

String _animalLabel(AnimalEntity? animal, String fallbackId) {
  if (animal == null) return 'Animal ($fallbackId)';
  final name = animal.customName?.trim().isNotEmpty == true
      ? animal.customName!
      : animal.visualId?.trim().isNotEmpty == true
      ? animal.visualId!
      : null;
  return name != null ? '$name (${animal.earTagNumber})' : animal.earTagNumber;
}

String _dueLabel(DateTime date, DateTime today) {
  final entryDay = DateTime(date.year, date.month, date.day);
  final todayDay = DateTime(today.year, today.month, today.day);
  final difference = entryDay.difference(todayDay).inDays;
  if (difference < 0) return 'Atrasado ${-difference} d';
  if (difference == 0) return 'Hoy';
  if (difference == 1) return 'Mañana';
  if (difference <= 14) return 'En $difference días';
  return DateFormat('dd/MM/yyyy').format(entryDay);
}

IconData _iconForCategory(AgendaCategoria category) => switch (category) {
  AgendaCategoria.sanidad => Icons.health_and_safety_outlined,
  AgendaCategoria.reproduccion => Icons.favorite_outline,
  AgendaCategoria.produccion => Icons.bar_chart_outlined,
  AgendaCategoria.movimientos => Icons.swap_horiz,
  AgendaCategoria.administracion => Icons.home_repair_service_outlined,
  AgendaCategoria.otros => Icons.event_note,
};
