/// Agenda worklist rendered as category headers and one card per logical
/// event. Every card contains an expandable, bounded animal list.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/features/agenda/domain/agenda_categoria.dart';
import 'package:libretapp/features/agenda/domain/agenda_registration.dart';
import 'package:libretapp/features/agenda/domain/agenda_task_grouping.dart';
import 'package:libretapp/features/agenda/widgets/agenda_style.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_presentation.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_card.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_palette.dart';
import 'package:libretapp/theme/theme.dart';

class AgendaProximasSection extends StatefulWidget {
  const AgendaProximasSection({
    required this.groups,
    required this.animalsById,
    required this.today,
    required this.onOpenGroup,
    this.onRegisterGroup,
    this.registrationDetailsByRow = const {},
    this.readOnly = false,
    this.emptyTitle = 'Sin pendientes',
    this.emptyMessage = 'No hay tareas atrasadas ni próximas por ahora.',
    super.key,
  });

  final List<AgendaCategoryGroup> groups;
  final Map<String, AnimalEntity> animalsById;
  final DateTime today;
  final ValueChanged<AgendaEventGroup> onOpenGroup;
  final Future<void> Function(AgendaEventGroup group, List<AgendaTaskRow> rows)?
  onRegisterGroup;
  final Map<String, AgendaRegistrationDetail> registrationDetailsByRow;
  final bool readOnly;
  final String emptyTitle;
  final String emptyMessage;

  @override
  State<AgendaProximasSection> createState() => _AgendaProximasSectionState();
}

class _AgendaProximasSectionState extends State<AgendaProximasSection> {
  final Set<String> _expandedEvents = {};
  final Map<String, Set<String>> _selectedAnimalIdsByEvent = {};

  void _toggleEvent(String key) {
    setState(() {
      if (!_expandedEvents.add(key)) _expandedEvents.remove(key);
    });
  }

  void _toggleAnimalSelection(String eventKey, AgendaTaskRow row) {
    final animalId = row.animalId;
    if (animalId == null) return;
    setState(() {
      final selected = _selectedAnimalIdsByEvent.putIfAbsent(
        eventKey,
        () => <String>{},
      );
      if (!selected.add(animalId)) selected.remove(animalId);
      if (selected.isEmpty) _selectedAnimalIdsByEvent.remove(eventKey);
    });
  }

  Future<void> _registerEvent(AgendaEventGroup event) async {
    final selectedIds =
        _selectedAnimalIdsByEvent[event.key] ?? const <String>{};
    final pendingRows = event.rows
        .where((row) {
          if (row.animalId == null) return true;
          final detail =
              widget.registrationDetailsByRow[agendaRegistrationRowKey(
                row.entry.id,
                row.animalId,
              )];
          return detail == null && !row.isCompleted;
        })
        .toList(growable: false);
    final selectedRows = event.rows
        .where(
          (row) => row.animalId != null && selectedIds.contains(row.animalId),
        )
        .toList(growable: false);
    final rowsToRegister = selectedRows.isEmpty && pendingRows.length == 1
        ? pendingRows
        : selectedRows;
    if (rowsToRegister.isEmpty) return;

    await widget.onRegisterGroup?.call(event, rowsToRegister);
    if (mounted) setState(() => _selectedAnimalIdsByEvent.remove(event.key));
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
          if (widget.groups[categoryIndex].categoria !=
              AgendaCategoria.sanidad) ...[
            _CategoryHeader(group: widget.groups[categoryIndex]),
            const SizedBox(height: AppSpacing.xs),
          ],
          for (final event in widget.groups[categoryIndex].events) ...[
            _AgendaEventCard(
              event: event,
              today: widget.today,
              animalsById: widget.animalsById,
              expanded: _expandedEvents.contains(event.key),
              onToggle: () => _toggleEvent(event.key),
              onOpen: () => widget.onOpenGroup(event),
              selectedAnimalIds:
                  _selectedAnimalIdsByEvent[event.key] ?? const <String>{},
              registrationDetailsByRow: widget.registrationDetailsByRow,
              readOnly: widget.readOnly,
              onToggleAnimalSelection: (row) =>
                  _toggleAnimalSelection(event.key, row),
              onRegister: widget.readOnly
                  ? () async => widget.onOpenGroup(event)
                  : () => _registerEvent(event),
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
    required this.selectedAnimalIds,
    required this.registrationDetailsByRow,
    required this.readOnly,
    required this.onToggleAnimalSelection,
    required this.onRegister,
  });

  final AgendaEventGroup event;
  final DateTime today;
  final Map<String, AnimalEntity> animalsById;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onOpen;
  final Set<String> selectedAnimalIds;
  final Map<String, AgendaRegistrationDetail> registrationDetailsByRow;
  final bool readOnly;
  final ValueChanged<AgendaTaskRow> onToggleAnimalSelection;
  final Future<void> Function() onRegister;

  bool get _overdue => event.rows.any((row) => row.isOverdue(today));

  bool get _hasAnimals => event.animalCount > 0;

  bool get _canExpand => _hasAnimals && event.animalCount > 2;

  bool get _isExpandedForRender =>
      !_hasAnimals || expanded || event.animalCount <= 2;

  int get _selectedCount => selectedAnimalIds.length;

  bool get _hasGeneralTask => event.rows.any((row) => row.animalId == null);

  AgendaRegistrationDetail? _detailFor(AgendaTaskRow row) =>
      registrationDetailsByRow[agendaRegistrationRowKey(
        row.entry.id,
        row.animalId,
      )];

  bool _isRegistered(AgendaTaskRow row) =>
      _detailFor(row) != null || row.isCompleted;

  int get _pendingCount =>
      event.rows.where((row) => !_isRegistered(row)).length;

  bool get _canRegister => readOnly || _hasGeneralTask || _pendingCount == 1
      ? true
      : _selectedCount > 0;

  bool get _showCheckboxes =>
      !readOnly && _isExpandedForRender && _pendingCount > 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventColor = colorForTipo(event.tipo);
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
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: AgendaAssetIcon(
                      assetPath: assetForTipo(event.tipo),
                      fallbackIcon: iconForTipo(event.tipo),
                      color: eventColor,
                      size: 32,
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
                              event.categoria.label,
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
                  if (_canExpand)
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
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          _BoundedAnimalList(
            event: event,
            today: today,
            animalsById: animalsById,
            expanded: _isExpandedForRender,
            showCheckboxes: _showCheckboxes,
            onToggle: onToggle,
            onOpen: onOpen,
            selectedAnimalIds: selectedAnimalIds,
            registrationDetailsByRow: registrationDetailsByRow,
            readOnly: readOnly,
            onToggleAnimalSelection: onToggleAnimalSelection,
          ),
          _AgendaEventFooter(
            eventKey: event.key,
            hasAnimals: _hasAnimals,
            completedCount: event.completedAnimalCount,
            totalCount: _hasAnimals
                ? event.totalAnimalCount
                : event.rows.length,
            selectedCount: _selectedCount,
            pendingCount: _pendingCount,
            readOnly: readOnly,
            canRegister: _canRegister,
            onRegister: onRegister,
          ),
        ],
      ),
    );
  }
}

class _AgendaEventFooter extends StatelessWidget {
  const _AgendaEventFooter({
    required this.eventKey,
    required this.hasAnimals,
    required this.completedCount,
    required this.totalCount,
    required this.selectedCount,
    required this.pendingCount,
    required this.readOnly,
    required this.canRegister,
    required this.onRegister,
  });

  final String eventKey;
  final bool hasAnimals;
  final int completedCount;
  final int totalCount;
  final int selectedCount;
  final int pendingCount;
  final bool readOnly;
  final bool canRegister;
  final Future<void> Function() onRegister;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressText = hasAnimals
        ? '$completedCount/$totalCount ${totalCount == 1 ? 'animal' : 'animales'}'
        : '${totalCount - pendingCount}/$totalCount ${totalCount == 1 ? 'pendiente' : 'pendientes'}';

    return Column(
      children: [
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  progressText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                key: ValueKey('agenda-event-register-$eventKey'),
                onPressed: canRegister ? onRegister : null,
                icon: Icon(
                  readOnly ? Icons.visibility_outlined : Icons.check,
                  size: 17,
                ),
                label: Text(
                  readOnly
                      ? 'Ver registros'
                      : hasAnimals && totalCount > 1 && pendingCount > 1
                      ? 'Registrar ($selectedCount)'
                      : 'Registrar',
                ),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BoundedAnimalList extends StatelessWidget {
  const _BoundedAnimalList({
    required this.event,
    required this.today,
    required this.animalsById,
    required this.expanded,
    required this.showCheckboxes,
    required this.onToggle,
    required this.onOpen,
    required this.selectedAnimalIds,
    required this.registrationDetailsByRow,
    required this.readOnly,
    required this.onToggleAnimalSelection,
  });

  final AgendaEventGroup event;
  final DateTime today;
  final Map<String, AnimalEntity> animalsById;
  final bool expanded;
  final bool showCheckboxes;
  final VoidCallback onToggle;
  final VoidCallback onOpen;
  final Set<String> selectedAnimalIds;
  final Map<String, AgendaRegistrationDetail> registrationDetailsByRow;
  final bool readOnly;
  final ValueChanged<AgendaTaskRow> onToggleAnimalSelection;

  @override
  Widget build(BuildContext context) {
    const rowExtent = 52.0;
    final animalCount = event.animalCount;
    final isAnimalList = animalCount > 0;
    final maxVisibleRows = expanded ? 5.0 : 2.5;
    final visibleRows = math.min(event.rows.length.toDouble(), maxVisibleRows);
    final height = math.max(rowExtent, visibleRows * rowExtent);
    final list = ListView.separated(
      primary: false,
      physics: expanded ? null : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      itemCount: event.rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final row = event.rows[index];
        final animal = row.animalId == null ? null : animalsById[row.animalId];
        return _AgendaAnimalRow(
          row: row,
          animal: animal,
          today: today,
          onOpen: expanded ? onOpen : onToggle,
          showCheckbox: showCheckboxes,
          registered:
              registrationDetailsByRow[agendaRegistrationRowKey(
                    row.entry.id,
                    row.animalId,
                  )] !=
                  null ||
              row.isCompleted,
          detail:
              registrationDetailsByRow[agendaRegistrationRowKey(
                row.entry.id,
                row.animalId,
              )],
          readOnly: readOnly,
          selected:
              row.animalId != null && selectedAnimalIds.contains(row.animalId),
          onToggleSelection: onToggleAnimalSelection,
        );
      },
    );

    final boundedList = SizedBox(height: height, child: list);
    final listWithScroll = expanded && event.rows.length > 5
        ? Scrollbar(child: boundedList)
        : boundedList;
    final showFade = isAnimalList && animalCount > 2 && !expanded;
    final theme = Theme.of(context);
    // Keep the inset list distinct from the card without using a stark white.
    final listSurfaceColor = theme.colorScheme.surfaceContainerHighest;
    final listWithPreview = showFade
        ? Stack(
            key: ValueKey('agenda-animal-preview-fade-${event.key}'),
            children: [
              listWithScroll,
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 26,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          listSurfaceColor.withValues(alpha: 0),
                          listSurfaceColor.withValues(alpha: 0.96),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        : listWithScroll;

    return ColoredBox(
      key: ValueKey('agenda-animal-list-surface-${event.key}'),
      color: listSurfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAnimalList && animalCount > 2)
            InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.xs,
                  AppSpacing.xs,
                  0,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.pets_outlined,
                      size: 15,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      'Animales',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      expanded ? 'Ocultar' : 'Ver todos',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isAnimalList && animalCount > 2)
            const SizedBox(height: AppSpacing.xxs),
          listWithPreview,
        ],
      ),
    );
  }
}

class _AgendaAnimalRow extends StatelessWidget {
  const _AgendaAnimalRow({
    required this.row,
    required this.animal,
    required this.today,
    required this.onOpen,
    required this.showCheckbox,
    required this.registered,
    required this.detail,
    required this.readOnly,
    required this.selected,
    required this.onToggleSelection,
  });

  final AgendaTaskRow row;
  final AnimalEntity? animal;
  final DateTime today;
  final VoidCallback onOpen;
  final bool showCheckbox;
  final bool registered;
  final AgendaRegistrationDetail? detail;
  final bool readOnly;
  final bool selected;
  final ValueChanged<AgendaTaskRow> onToggleSelection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animalId = row.animalId;
    final resolvedAnimal = animal;

    if (resolvedAnimal == null || animalId == null) {
      return InkWell(
        onTap: onOpen,
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              Icon(
                Icons.task_alt_outlined,
                size: 18,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  row.entry.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _DateLabel(date: row.entry.fecha, today: today),
            ],
          ),
        ),
      );
    }

    final categoryColor = AnimalPalette.categoryColor(resolvedAnimal.category);
    final canSelect = !readOnly && !registered;
    final registrationSummary =
        detail?.summary ?? (registered ? 'Completado sin detalle' : null);
    return InkWell(
      onTap: onOpen,
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            _AgendaAnimalAvatar(animal: resolvedAnimal, color: categoryColor),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          primaryAnimalLabel(resolvedAnimal),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      TagChip(
                        label: resolvedAnimal.lifeStage.displayName
                            .toUpperCase(),
                        accentColor: categoryColor,
                        fontSize: 9,
                        tintOpacity: 0.12,
                        borderOpacity: 0.3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    registrationSummary?.isNotEmpty == true
                        ? '${identificationDisplay(resolvedAnimal)} · $registrationSummary'
                        : identificationDisplay(resolvedAnimal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            _DateLabel(date: row.entry.fecha, today: today),
            if (registered)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xxs),
                child: Icon(
                  Icons.check_circle,
                  size: 19,
                  color: theme.colorScheme.primary,
                ),
              )
            else if (showCheckbox && canSelect) ...[
              const SizedBox(width: AppSpacing.xxs),
              _AgendaAnimalCheckbox(
                checkboxKey: ValueKey('agenda-animal-checkbox-$animalId'),
                value: selected,
                onChanged: (_) => onToggleSelection(row),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AgendaAnimalAvatar extends StatelessWidget {
  const _AgendaAnimalAvatar({required this.animal, required this.color});

  final AnimalEntity animal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final profile = profileVisualFor(
      animal,
      AnimalPalette.speciesColor(animal.species),
    );

    return Container(
      width: 34,
      height: 34,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AnimalPalette.avatarBackgroundLight,
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Image.asset(
        profile.asset,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) =>
            Icon(profile.fallbackIcon, size: 19, color: profile.color),
      ),
    );
  }
}

class _DateLabel extends StatelessWidget {
  const _DateLabel({required this.date, required this.today});

  final DateTime date;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final day = DateTime(date.year, date.month, date.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    final overdue = day.isBefore(todayDay);
    return Text(
      DateFormat('dd/MM/yyyy').format(date),
      style: theme.textTheme.labelSmall?.copyWith(
        color: overdue ? theme.colorScheme.error : theme.colorScheme.outline,
        fontWeight: overdue ? FontWeight.w700 : FontWeight.normal,
      ),
    );
  }
}

class _AgendaAnimalCheckbox extends StatelessWidget {
  const _AgendaAnimalCheckbox({
    required this.checkboxKey,
    required this.value,
    required this.onChanged,
  });

  final Key checkboxKey;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return CheckboxTheme(
      data: CheckboxThemeData(
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(color: primary, width: 1.4),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(Colors.white),
      ),
      child: Checkbox(key: checkboxKey, value: value, onChanged: onChanged),
    );
  }
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
