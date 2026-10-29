/// features › agenda › view › agenda_view — main view for the agenda calendar.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/features/agenda/bloc/agenda_bloc.dart';
import 'package:libretapp/features/agenda/bloc/agenda_event.dart';
import 'package:libretapp/features/agenda/bloc/agenda_state.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/domain/agenda_registration.dart';
import 'package:libretapp/features/agenda/domain/agenda_task_grouping.dart';
import 'package:libretapp/features/agenda/view/agenda_task_detail_page.dart';
import 'package:libretapp/features/agenda/view/agenda_registration_flow_page.dart';
import 'package:libretapp/features/agenda/widgets/widgets.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/theme/theme.dart';

enum _AgendaMenuAction { week, twoWeeks, month }

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  static const _taskGrouper = AgendaTaskGrouper();
  static const double _toolbarHeight = 56;

  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<TooltipState> _dateTooltipKey = GlobalKey<TooltipState>();
  late final FocusNode _searchFocusNode;
  late final ScrollController _scrollController;
  DateTime _visibleDate = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  bool _isSearchActive = false;
  bool _isSearchFieldActive = false;
  CalendarMode _calendarMode = CalendarMode.week;
  Map<String, AnimalEntity> _animalsById = {};
  StreamSubscription<void>? _animalChangesSubscription;
  bool _showAgendaFab = true;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _searchFocusNode = FocusNode()..addListener(_updateSearchActive);
    _searchController.addListener(_updateSearchActive);
    _loadAnimals();
    _animalChangesSubscription = locator<AnimalRepository>()
        .watchChanges()
        .listen((_) => _loadAnimals());
  }

  Future<void> _loadAnimals() async {
    final animals = await locator<AnimalRepository>().getAll();
    if (!mounted) return;
    setState(() => _animalsById = {for (final a in animals) a.uuid: a});
  }

  @override
  void dispose() {
    _searchController.removeListener(_updateSearchActive);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _animalChangesSubscription?.cancel();
    super.dispose();
  }

  void _handleScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    final offset = _scrollController.position.pixels;
    final atTop = offset <= 0;
    final scrollingDown = offset > _lastScrollOffset + 1;
    final scrollingUp = offset < _lastScrollOffset - 1;
    _lastScrollOffset = offset;

    var shouldShow = _showAgendaFab;
    if (atTop || scrollingUp) {
      shouldShow = true;
    } else if (scrollingDown) {
      shouldShow = false;
    }
    if (shouldShow == _showAgendaFab) return;
    setState(() => _showAgendaFab = shouldShow);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = ShellInsets.bottomSafePadding(context);
    final fabConfig = ShellFabConfig(
      id: 'agenda',
      label: 'Agregar',
      icon: Icons.add_task,
      heroTag: 'fab_agenda',
      onPressed: () => _openForm(context),
      secondary: ShellFabSecondaryAction(
        id: 'agenda_workforce',
        icon: Icons.groups_outlined,
        heroTag: 'fab_agenda_workforce',
        tooltip: 'Personal y cuadrillas',
        onPressed: () => showWorkforceManager(context),
      ),
    );

    return ShellFabConfigScope(
      config: _showAgendaFab ? fabConfig : null,
      child: ShellChromeScope(
        visible: !_isSearchActive,
        child: Scaffold(
          body: BlocBuilder<AgendaBloc, AgendaState>(
            builder: (context, state) {
              final filteredEntries = state is AgendaLoaded
                  ? _filterByQuery(state.entries)
                  : const <AgendaEntry>[];
              final visibleRange = _visibleRange();
              final entriesPorDia = _agruparPorDia(
                _entriesEnRango(filteredEntries, visibleRange),
              );
              final header = _buildCalendarHeader(context, entriesPorDia);

              if (state is AgendaLoading) {
                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    header,
                    const SliverFillRemaining(child: AppLoadingIndicator()),
                  ],
                );
              }
              if (state is AgendaError) {
                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    header,
                    SliverFillRemaining(
                      child: AppEmptyState(
                        icon: Icons.cloud_off_outlined,
                        title: 'No se pudo cargar la agenda',
                        message: state.message,
                        action: AppButton(
                          label: 'Reintentar',
                          variant: AppButtonVariant.secondary,
                          icon: Icons.refresh,
                          onPressed: () => context.read<AgendaBloc>().add(
                            const RefreshAgenda(),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              if (state is! AgendaLoaded) {
                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [header],
                );
              }

              final DateTime? selectedDay = _selectedDay;
              final selectedKey = selectedDay != null
                  ? _dayKey(selectedDay)
                  : null;
              final entriesHoy = selectedKey != null
                  ? entriesPorDia[selectedKey] ?? const <AgendaEntry>[]
                  : const <AgendaEntry>[];
              final today = DateTime.now();
              final todayGroups = _taskGrouper.group(
                entriesHoy,
                today: today,
                includeCompletedAnimals: true,
              );
              final proximosGroups = _taskGrouper.group(
                _entriesPendientes(
                  filteredEntries,
                  today,
                  selectedKey: selectedKey,
                ),
                today: today,
                includeCompletedAnimals: true,
              );
              final realizadasGroups = _taskGrouper.group(
                entriesHoy.where(_taskGrouper.isTerminal).toList(),
                today: today,
                includeFinished: true,
                includeCompletedAnimals: true,
              );

              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  header,
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xs,
                      AppSpacing.xs,
                      AppSpacing.xs,
                      bottomInset + ShellInsets.fabContentClearance,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AgendaLegend(),
                          const SizedBox(height: AppSpacing.sm),

                          // Entries for selected day
                          const _SectionHeader(title: 'Hoy'),
                          const SizedBox(height: 8),
                          AgendaProximasSection(
                            groups: todayGroups,
                            animalsById: _animalsById,
                            today: today,
                            emptyTitle: selectedDay == null
                                ? 'Selecciona un día para ver tareas'
                                : 'Sin pendientes para este día',
                            emptyMessage:
                                'No hay eventos pendientes en la fecha seleccionada.',
                            onOpenGroup: (group) =>
                                _openTaskDetail(context, group),
                            onRegisterGroup: _registerAgendaGroup,
                            registrationDetailsByRow:
                                state.registrationDetailsByRow,
                          ),
                          if (realizadasGroups.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const _SectionHeader(title: 'Realizadas'),
                            const SizedBox(height: 8),
                            AgendaProximasSection(
                              groups: realizadasGroups,
                              animalsById: _animalsById,
                              today: today,
                              readOnly: true,
                              registrationDetailsByRow:
                                  state.registrationDetailsByRow,
                              onOpenGroup: (group) =>
                                  _openTaskDetail(context, group),
                            ),
                          ],
                          const SizedBox(height: 20),

                          // Pendientes (atrasadas + próximos 14 días), agrupadas
                          // por categoría > tipo > animal, ordenadas por urgencia.
                          const _SectionHeader(title: 'Pendientes'),
                          const SizedBox(height: 8),
                          AgendaProximasSection(
                            groups: proximosGroups,
                            animalsById: _animalsById,
                            today: today,
                            onOpenGroup: (group) =>
                                _openTaskDetail(context, group),
                            onRegisterGroup: _registerAgendaGroup,
                            registrationDetailsByRow:
                                state.registrationDetailsByRow,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _updateSearchActive() {
    final active =
        _searchFocusNode.hasFocus || _searchController.text.trim().isNotEmpty;
    if (active == _isSearchActive) return;
    setState(() => _isSearchActive = active);
  }

  SliverAppBar _buildCalendarHeader(
    BuildContext context,
    Map<DateTime, List<AgendaEntry>> entriesPorDia,
  ) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final calendarHeight = AgendaCalendarPeriod.height(
      _calendarMode,
      _visibleDate,
    );
    final label = AgendaCalendarPeriod.label(
      _calendarMode,
      _visibleDate,
      locale,
    );
    final modeLabel = switch (_calendarMode) {
      CalendarMode.week => 'Semanal',
      CalendarMode.twoWeeks => 'Quincenal',
      CalendarMode.month => 'Mensual',
    };
    final modeIcon = switch (_calendarMode) {
      CalendarMode.week => Icons.view_week_outlined,
      CalendarMode.twoWeeks => Icons.view_agenda_outlined,
      CalendarMode.month => Icons.calendar_month_outlined,
    };

    return SliverAppBar(
      pinned: true,
      leadingWidth: 40,
      titleSpacing: 4,
      toolbarHeight: _toolbarHeight,
      expandedHeight: _toolbarHeight + calendarHeight + 8,
      backgroundColor: theme.appBarTheme.backgroundColor,
      surfaceTintColor: Colors.transparent,
      leading: AppIconButton(
        icon: _isSearchFieldActive ? Icons.arrow_back : Icons.chevron_left,
        tooltip: _isSearchFieldActive ? 'Cerrar búsqueda' : 'Periodo anterior',
        compact: true,
        onPressed: _isSearchFieldActive
            ? _closeSearch
            : () => _changePeriod(-1),
      ),
      title: _isSearchFieldActive
          ? AppSearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              hintText: 'Buscar agenda...',
              onClear: () => setState(() {}),
              onClose: _closeSearch,
              onChanged: (_) => setState(() {}),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final compactLabel = AgendaCalendarPeriod.compactLabel(
                  _calendarMode,
                  _visibleDate,
                  locale,
                );
                final dateWidth = constraints.maxWidth - 160;
                final painter = TextPainter(
                  text: TextSpan(
                    text: compactLabel,
                    style: theme.appBarTheme.titleTextStyle,
                  ),
                  maxLines: 1,
                  textDirection: Directionality.of(context),
                  textScaler: MediaQuery.textScalerOf(context),
                )..layout();
                final visibleLabel = painter.width <= dateWidth
                    ? compactLabel
                    : AgendaCalendarPeriod.compactLabel(
                        _calendarMode,
                        _visibleDate,
                        locale,
                        numeric: true,
                      );
                return Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label: 'Agenda, $label',
                        button: true,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _dateTooltipKey.currentState
                              ?.ensureTooltipVisible(),
                          child: Tooltip(
                            key: _dateTooltipKey,
                            message: label,
                            triggerMode: TooltipTriggerMode.manual,
                            excludeFromSemantics: true,
                            child: SizedBox(
                              height: 40,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  visibleLabel,
                                  key: const ValueKey('agenda_period_label'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.appBarTheme.titleTextStyle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    PopupMenuButton<_AgendaMenuAction>(
                      tooltip: 'Cambiar vista: $modeLabel',
                      position: PopupMenuPosition.under,
                      padding: EdgeInsets.zero,
                      onSelected: (action) {
                        switch (action) {
                          case _AgendaMenuAction.week:
                            _selectMode(CalendarMode.week);
                          case _AgendaMenuAction.twoWeeks:
                            _selectMode(CalendarMode.twoWeeks);
                          case _AgendaMenuAction.month:
                            _selectMode(CalendarMode.month);
                        }
                      },
                      itemBuilder: (_) => [
                        CheckedPopupMenuItem(
                          value: _AgendaMenuAction.week,
                          checked: _calendarMode == CalendarMode.week,
                          child: const Text('Semanal'),
                        ),
                        CheckedPopupMenuItem(
                          value: _AgendaMenuAction.twoWeeks,
                          checked: _calendarMode == CalendarMode.twoWeeks,
                          child: const Text('Quincenal'),
                        ),
                        CheckedPopupMenuItem(
                          value: _AgendaMenuAction.month,
                          checked: _calendarMode == CalendarMode.month,
                          child: const Text('Mensual'),
                        ),
                      ],
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: Icon(
                            modeIcon,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    AppIconButton(
                      icon: Icons.chevron_right,
                      tooltip: 'Periodo siguiente',
                      compact: true,
                      onPressed: () => _changePeriod(1),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Citas y medicamentos',
                      icon: const Icon(Icons.medication_outlined),
                      onSelected: (_) => _openReminderForm(context),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'reminder',
                          child: Text('Cita, medicamento o recordatorio'),
                        ),
                      ],
                    ),
                    AppIconButton(
                      icon: Icons.search,
                      tooltip: 'Buscar agenda',
                      compact: true,
                      onPressed: _openSearch,
                    ),
                  ],
                );
              },
            ),
      flexibleSpace: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: MediaQuery.paddingOf(context).top + _toolbarHeight + 2,
            left: AppSpacing.xs,
            right: AppSpacing.xs,
            height: calendarHeight,
            child: AgendaCalendar(
              visibleDate: _visibleDate,
              mode: _calendarMode,
              selectedDay: _selectedDay,
              entriesByDay: entriesPorDia,
              onDaySelected: (day) => setState(() {
                _selectedDay = AgendaCalendarPeriod.day(day);
                _visibleDate = _selectedDay!;
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _openSearch() {
    setState(() => _isSearchFieldActive = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    setState(() {
      _isSearchFieldActive = false;
      _searchController.clear();
      _searchFocusNode.unfocus();
    });
  }

  DateTime _dayKey(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  /// Overdue (no lower bound) plus what's due in the next 14 days, excluding
  /// today itself (already shown in the "Hoy" section above). Anchored on
  /// real "today", not the calendar's selected day, so the pending worklist
  /// doesn't shift just because the user is browsing a different date.
  List<AgendaEntry> _entriesPendientes(
    List<AgendaEntry> entries,
    DateTime today, {
    DateTime? selectedKey,
  }) {
    final todayKey = _dayKey(today);
    final limite = todayKey.add(const Duration(days: 14));
    return entries.where((e) {
      if (_taskGrouper.isTerminal(e)) return false;
      final day = _dayKey(e.fecha);
      if (selectedKey != null && day == selectedKey) return false;
      final overdue = day.isBefore(todayKey);
      final upcoming = day.isAfter(todayKey) && !day.isAfter(limite);
      return overdue || upcoming;
    }).toList();
  }

  Map<DateTime, List<AgendaEntry>> _agruparPorDia(List<AgendaEntry> entries) {
    final mapa = <DateTime, List<AgendaEntry>>{};
    for (final entry in entries) {
      final key = _dayKey(entry.fecha);
      mapa.putIfAbsent(key, () => <AgendaEntry>[]).add(entry);
    }
    return mapa;
  }

  List<AgendaEntry> _entriesEnRango(
    List<AgendaEntry> entries,
    DateTimeRange rango,
  ) {
    return entries.where((e) {
      final day = _dayKey(e.fecha);
      return !day.isBefore(rango.start) && !day.isAfter(rango.end);
    }).toList();
  }

  List<AgendaEntry> _filterByQuery(List<AgendaEntry> entries) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return entries;
    return entries
        .where(
          (e) =>
              e.titulo.toLowerCase().contains(query) ||
              e.tipo.toLowerCase().contains(query) ||
              e.ubicacion.toLowerCase().contains(query) ||
              e.descripcion.toLowerCase().contains(query),
        )
        .toList();
  }

  void _changePeriod(int delta) {
    setState(() {
      final next = AgendaCalendarPeriod.navigate(
        _calendarMode,
        _selectedDay ?? _visibleDate,
        delta,
      );
      _selectedDay = next;
      _visibleDate = next;
    });
  }

  void _selectMode(CalendarMode mode) {
    setState(() {
      _calendarMode = mode;
      _visibleDate = _selectedDay ?? _visibleDate;
    });
  }

  DateTimeRange _visibleRange() =>
      AgendaCalendarPeriod.range(_calendarMode, _visibleDate);

  Future<void> _openForm(BuildContext context) {
    final initialDate = _selectedDay ?? DateTime.now();
    return context.pushNamed(
      AppRoutes.nameAgendaNuevo,
      queryParameters: {'date': DateFormat('yyyy-MM-dd').format(initialDate)},
    );
  }

  Future<void> _openReminderForm(BuildContext context) {
    final initialDate = _selectedDay ?? DateTime.now();
    return context.pushNamed(
      AppRoutes.nameAgendaNuevo,
      queryParameters: {
        'date': DateFormat('yyyy-MM-dd').format(initialDate),
        'kind': 'reminder',
      },
    );
  }

  void _openTaskDetail(BuildContext context, AgendaEventGroup group) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<AgendaBloc>(),
          child: AgendaTaskDetailPage(group: group),
        ),
      ),
    );
  }

  Future<void> _registerAgendaGroup(
    AgendaEventGroup group,
    List<AgendaTaskRow> selectedRows,
  ) async {
    final result = await context.pushNamed<AgendaRegistrationBatchResult>(
      AppRoutes.nameAgendaRegistro,
      extra: AgendaRegistrationRouteArgs(
        agendaBloc: context.read<AgendaBloc>(),
        group: group,
        rows: selectedRows,
        animalsById: _animalsById,
      ),
    );
    if (result != null && mounted) {
      context.read<AgendaBloc>().add(const RefreshAgenda());
    }
  }
}

// Widget: Encabezado de sección
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
