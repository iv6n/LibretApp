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
  final Set<String> _showAllAnimalsByEvent = {};
  final Map<String, Set<String>> _selectedAnimalIdsByEvent = {};

  void _toggleEvent(String key) {
    setState(() {
      if (!_expandedEvents.add(key)) _expandedEvents.remove(key);
    });
  }

  void _toggleAllAnimals(String key) {
    setState(() {
      if (!_showAllAnimalsByEvent.add(key)) {
        _showAllAnimalsByEvent.remove(key);
      }
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
      final theme = Theme.of(context);
      final scheme = theme.colorScheme;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Row(
          children: [
            Icon(Icons.task_alt_outlined, color: scheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.emptyTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    widget.emptyMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
              showAllAnimals: _showAllAnimalsByEvent.contains(event.key),
              onToggleAllAnimals: () => _toggleAllAnimals(event.key),
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
    required this.showAllAnimals,
    required this.onToggleAllAnimals,
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
  final bool showAllAnimals;
  final VoidCallback onToggleAllAnimals;
  final VoidCallback onOpen;
  final Set<String> selectedAnimalIds;
  final Map<String, AgendaRegistrationDetail> registrationDetailsByRow;
  final bool readOnly;
  final ValueChanged<AgendaTaskRow> onToggleAnimalSelection;
  final Future<void> Function() onRegister;

  bool get _overdue => event.rows.any((row) => row.isOverdue(today));

  bool get _hasAnimals => event.animalCount > 0;

  bool get _isExpandedForRender => expanded;

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

  int get _totalAnimalCount => event.totalAnimalCount;

  int get _registeredCount =>
      _totalAnimalCount > _pendingCount ? _totalAnimalCount - _pendingCount : 0;

  bool get _canRegister => readOnly || _hasGeneralTask || _pendingCount == 1
      ? true
      : _selectedCount > 0;

  bool get _showCheckboxes => !readOnly && _pendingCount > 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventColor = colorForTipo(event.tipo);
    final isExpanded = _isExpandedForRender;
    return AppCard(
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      padding: EdgeInsets.zero,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            key: ValueKey('agenda-event-header-${event.key}'),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: theme.brightness == Brightness.dark
                            ? 0.28
                            : 0.55,
                      ),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Center(
                      child: AgendaAssetIcon(
                        assetPath: assetForTipo(event.tipo),
                        fallbackIcon: iconForTipo(event.tipo),
                        color: eventColor,
                        size: 25,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.titulo,
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
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: eventColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            _MetadataDot(color: theme.colorScheme.outline),
                            Text(
                              _hasAnimals
                                  ? '$_totalAnimalCount ${_totalAnimalCount == 1 ? 'animal' : 'animales'}'
                                  : '${event.rows.length} ${event.rows.length == 1 ? 'tarea' : 'tareas'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            _MetadataDot(color: theme.colorScheme.outline),
                            Text(
                              _dueLabel(event.primaryEntry.fecha, today),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _overdue
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: _overdue
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        if (!isExpanded) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (_hasAnimals)
                                _AnimalAvatarStack(
                                  event: event,
                                  animalsById: animalsById,
                                )
                              else
                                Icon(
                                  Icons.task_alt_outlined,
                                  size: 20,
                                  color: theme.colorScheme.outline,
                                ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  _hasAnimals
                                      ? '$_registeredCount de $_totalAnimalCount ${_totalAnimalCount == 1 ? 'registrado' : 'registrados'} · Toca para ver animales'
                                      : readOnly
                                      ? 'Toca para ver detalles'
                                      : 'Toca para ver detalles y registrar',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(
                    width: AppControlMetrics.minHeight,
                    height: AppControlMetrics.minHeight,
                    child: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            _BoundedAnimalList(
              event: event,
              today: today,
              animalsById: animalsById,
              showAllAnimals: showAllAnimals,
              onToggleAllAnimals: onToggleAllAnimals,
              showCheckboxes: _showCheckboxes,
              registeredCount: _registeredCount,
              totalCount: _hasAnimals ? _totalAnimalCount : event.rows.length,
              onOpen: onOpen,
              selectedAnimalIds: selectedAnimalIds,
              registrationDetailsByRow: registrationDetailsByRow,
              readOnly: readOnly,
              onToggleAnimalSelection: onToggleAnimalSelection,
            ),
            _AgendaEventFooter(
              eventKey: event.key,
              hasAnimals: _hasAnimals,
              totalCount: _hasAnimals ? _totalAnimalCount : event.rows.length,
              selectedCount: _selectedCount,
              pendingCount: _pendingCount,
              readOnly: readOnly,
              canRegister: _canRegister,
              onRegister: onRegister,
            ),
          ],
        ],
      ),
    );
  }
}

class _MetadataDot extends StatelessWidget {
  const _MetadataDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      Text('·', style: TextStyle(color: color));
}

class _AnimalAvatarStack extends StatelessWidget {
  const _AnimalAvatarStack({required this.event, required this.animalsById});

  final AgendaEventGroup event;
  final Map<String, AnimalEntity> animalsById;

  @override
  Widget build(BuildContext context) {
    final animals = event.rows
        .where((row) => row.animalId != null)
        .map((row) => animalsById[row.animalId])
        .whereType<AnimalEntity>()
        .take(3)
        .toList(growable: false);
    if (animals.isEmpty) {
      return Icon(
        Icons.pets_outlined,
        size: 20,
        color: Theme.of(context).colorScheme.outline,
      );
    }
    const avatarSize = 22.0;
    const overlap = 15.0;
    return SizedBox(
      width: avatarSize + overlap * (animals.length - 1),
      height: avatarSize,
      child: Stack(
        children: [
          for (var index = 0; index < animals.length; index++)
            Positioned(
              left: index * overlap,
              child: _AgendaAnimalAvatar(
                animal: animals[index],
                color: AnimalPalette.categoryColor(animals[index].category),
                size: avatarSize,
                borderColor: Theme.of(context).colorScheme.surfaceContainerLow,
              ),
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
    required this.totalCount,
    required this.selectedCount,
    required this.pendingCount,
    required this.readOnly,
    required this.canRegister,
    required this.onRegister,
  });

  final String eventKey;
  final bool hasAnimals;
  final int totalCount;
  final int selectedCount;
  final int pendingCount;
  final bool readOnly;
  final bool canRegister;
  final Future<void> Function() onRegister;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.xs,
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              Text(
                hasAnimals
                    ? '$selectedCount ${selectedCount == 1 ? 'seleccionado' : 'seleccionados'}'
                    : '${totalCount - pendingCount}/$totalCount ${totalCount == 1 ? 'pendiente' : 'pendientes'}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
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
                  minimumSize: const Size(0, AppControlMetrics.minHeight),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
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
    required this.showAllAnimals,
    required this.onToggleAllAnimals,
    required this.showCheckboxes,
    required this.registeredCount,
    required this.totalCount,
    required this.onOpen,
    required this.selectedAnimalIds,
    required this.registrationDetailsByRow,
    required this.readOnly,
    required this.onToggleAnimalSelection,
  });

  final AgendaEventGroup event;
  final DateTime today;
  final Map<String, AnimalEntity> animalsById;
  final bool showAllAnimals;
  final VoidCallback onToggleAllAnimals;
  final bool showCheckboxes;
  final int registeredCount;
  final int totalCount;
  final VoidCallback onOpen;
  final Set<String> selectedAnimalIds;
  final Map<String, AgendaRegistrationDetail> registrationDetailsByRow;
  final bool readOnly;
  final ValueChanged<AgendaTaskRow> onToggleAnimalSelection;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(
      context,
    ).scale(1).clamp(1.0, 2.0).toDouble();
    final rowExtent = 56.0 + 24.0 * (textScale - 1);
    final isAnimalList = event.animalCount > 0;
    final visibleRows = showAllAnimals
        ? event.rows.length.toDouble()
        : math.min(event.rows.length.toDouble(), 3.0);
    final maxHeight = rowExtent * 5 + 4;
    final height = math
        .max(
          rowExtent,
          math.min(
            visibleRows * rowExtent + math.max(0, visibleRows.ceil() - 1),
            maxHeight,
          ),
        )
        .toDouble();
    final itemCount = showAllAnimals || !isAnimalList
        ? event.rows.length
        : math.min(event.rows.length, 3).toInt();
    final list = ListView.separated(
      primary: false,
      physics: showAllAnimals ? null : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final row = event.rows[index];
        final animal = row.animalId == null ? null : animalsById[row.animalId];
        return _AgendaAnimalRow(
          row: row,
          animal: animal,
          today: today,
          onOpen: onOpen,
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
    final listWithScroll = showAllAnimals && event.rows.length > 5
        ? Scrollbar(child: boundedList)
        : boundedList;
    final theme = Theme.of(context);
    final listSurfaceColor = theme.colorScheme.surfaceContainerLow;

    return ColoredBox(
      key: ValueKey('agenda-animal-list-surface-${event.key}'),
      color: listSurfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAnimalList)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.xxs,
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xxs,
                children: [
                  Text(
                    'ANIMALES',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    '$registeredCount/$totalCount registrados',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          listWithScroll,
          if (isAnimalList && event.rows.length > 3)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onToggleAllAnimals,
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, AppControlMetrics.minHeight),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
                child: Text(
                  showAllAnimals ? 'Ver menos animales' : 'Ver más animales',
                ),
              ),
            ),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              SizedBox(
                width: AppControlMetrics.minHeight,
                height: AppControlMetrics.minHeight,
                child: Icon(
                  Icons.task_alt_outlined,
                  size: 18,
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.entry.titulo,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _DateLabel(date: row.entry.fecha, today: today),
                  ],
                ),
              ),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: AppControlMetrics.minHeight,
              height: AppControlMetrics.minHeight,
              child: Center(
                child: registered
                    ? Icon(
                        Icons.check_circle,
                        size: 21,
                        color: theme.colorScheme.primary,
                      )
                    : showCheckbox && canSelect
                    ? _AgendaAnimalCheckbox(
                        checkboxKey: ValueKey(
                          'agenda-animal-checkbox-$animalId',
                        ),
                        value: selected,
                        onChanged: (_) => onToggleSelection(row),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            const SizedBox(width: AppSpacing.xxs),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primaryAnimalLabel(resolvedAnimal),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    registrationSummary?.isNotEmpty == true
                        ? '${identificationDisplay(resolvedAnimal)} · $registrationSummary'
                        : identificationDisplay(resolvedAnimal),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            TagChip(
              label: resolvedAnimal.lifeStage.displayName.toUpperCase(),
              accentColor: categoryColor,
              fontSize: 10,
              tintOpacity: 0.12,
              borderOpacity: 0.3,
            ),
          ],
        ),
      ),
    );
  }
}

class _AgendaAnimalAvatar extends StatelessWidget {
  const _AgendaAnimalAvatar({
    required this.animal,
    required this.color,
    this.size = 34,
    this.borderColor,
  });

  final AnimalEntity animal;
  final Color color;
  final double size;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final profile = profileVisualFor(
      animal,
      AnimalPalette.speciesColor(animal.species),
    );

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.14),
      decoration: BoxDecoration(
        color: AnimalPalette.avatarBackgroundLight,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? color.withValues(alpha: 0.55),
          width: 1.4,
        ),
      ),
      child: Image.asset(
        profile.asset,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) =>
            Icon(profile.fallbackIcon, size: size * 0.56, color: profile.color),
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
        visualDensity: VisualDensity.standard,
        materialTapTargetSize: MaterialTapTargetSize.padded,
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
