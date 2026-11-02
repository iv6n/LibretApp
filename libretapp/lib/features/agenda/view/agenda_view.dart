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
import 'package:libretapp/features/agenda/widgets/agenda_empty_panel.dart';
import 'package:libretapp/features/agenda/widgets/widgets.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/theme/theme.dart';

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
  bool _calendarCollapsed = false;
  bool _calendarCollapseUpdateScheduled = false;
  bool? _pendingCalendarCollapsed;
  int? _calendarPointer;
  Offset? _calendarPointerOrigin;
  Map<String, AnimalEntity> _animalsById = {};
  StreamSubscription<void>? _animalChangesSubscription;
  StreamSubscription<List<CultivationEntity>>? _cultivationChangesSubscription;
  bool _animalsLoaded = false;
  bool _cultivationsLoaded = false;
  int _cultivationCount = 0;
  String? _animalLoadError;
  String? _cultivationLoadError;
  String? get _directoryLoadError => _animalLoadError ?? _cultivationLoadError;
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
    if (locator.isRegistered<CultivationRepository>()) {
      _cultivationChangesSubscription = locator<CultivationRepository>()
          .watchAll()
          .listen(
            (cultivations) {
              if (!mounted) return;
              setState(() {
                _cultivationCount = cultivations.length;
                _cultivationsLoaded = true;
                _cultivationLoadError = null;
              });
            },
            onError: (Object error) {
              if (!mounted) return;
              setState(() => _cultivationLoadError = error.toString());
            },
          );
    } else {
      _cultivationsLoaded = true;
    }
  }

  Future<void> _loadAnimals() async {
    try {
      final animals = await locator<AnimalRepository>().getAll();
      if (!mounted) return;
      setState(() {
        _animalsById = {for (final a in animals) a.uuid: a};
        _animalsLoaded = true;
        _animalLoadError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _animalLoadError = error.toString());
    }
  }

  Future<void> _loadCultivations() async {
    if (!locator.isRegistered<CultivationRepository>()) return;
    try {
      final items = await locator<CultivationRepository>().getAll();
      if (!mounted) return;
      setState(() {
        _cultivationCount = items.length;
        _cultivationsLoaded = true;
        _cultivationLoadError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _cultivationLoadError = error.toString());
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_updateSearchActive);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _animalChangesSubscription?.cancel();
    _cultivationChangesSubscription?.cancel();
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

  bool _handleCalendarScroll(ScrollNotification notification) {
    if (notification.depth != 0 || _calendarMode == CalendarMode.week) {
      return false;
    }

    if (notification is ScrollUpdateNotification &&
        notification.dragDetails != null) {
      final delta = notification.scrollDelta ?? 0;
      if (delta > 0) {
        _scheduleCalendarCollapse(true);
      } else if (delta < 0 &&
          notification.metrics.pixels <=
              notification.metrics.minScrollExtent + 1) {
        _scheduleCalendarCollapse(false);
      }
    } else if (notification is OverscrollNotification &&
        notification.dragDetails != null) {
      if (notification.overscroll > 0) {
        _scheduleCalendarCollapse(true);
      } else if (notification.overscroll < 0) {
        _scheduleCalendarCollapse(false);
      }
    }
    return false;
  }

  void _handleCalendarPointerMove(int pointer, Offset position) {
    if (pointer != _calendarPointer || _calendarMode == CalendarMode.week) {
      return;
    }
    final origin = _calendarPointerOrigin;
    if (origin == null) return;
    final distance = position.dy - origin.dy;
    if (distance < -12) {
      _scheduleCalendarCollapse(true);
      _calendarPointerOrigin = position;
    } else if (distance > 12 &&
        _scrollController.hasClients &&
        _scrollController.position.pixels <=
            _scrollController.position.minScrollExtent + 1) {
      _scheduleCalendarCollapse(false);
      _calendarPointerOrigin = position;
    }
  }

  void _scheduleCalendarCollapse(bool collapsed) {
    if (_pendingCalendarCollapsed == collapsed ||
        (_pendingCalendarCollapsed == null &&
            _calendarCollapsed == collapsed)) {
      return;
    }
    _pendingCalendarCollapsed = collapsed;
    if (_calendarCollapseUpdateScheduled) return;
    _calendarCollapseUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calendarCollapseUpdateScheduled = false;
      final requested = _pendingCalendarCollapsed;
      _pendingCalendarCollapsed = null;
      if (mounted && requested != null && requested != _calendarCollapsed) {
        setState(() => _calendarCollapsed = requested);
      }
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = ShellInsets.bottomSafePadding(context);
    final agendaState = context.watch<AgendaBloc>().state;
    final isGlobalEmpty =
        agendaState is AgendaLoaded &&
        agendaState.entries.isEmpty &&
        _animalsLoaded &&
        _cultivationsLoaded &&
        _directoryLoadError == null;
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
      config: _showAgendaFab && !isGlobalEmpty ? fabConfig : null,
      child: ShellChromeScope(
        visible: !_isSearchActive,
        child: Scaffold(
          body: Listener(
            onPointerDown: (event) {
              _calendarPointer = event.pointer;
              _calendarPointerOrigin = event.position;
            },
            onPointerMove: (event) =>
                _handleCalendarPointerMove(event.pointer, event.position),
            onPointerUp: (_) {
              _calendarPointer = null;
              _calendarPointerOrigin = null;
            },
            onPointerCancel: (_) {
              _calendarPointer = null;
              _calendarPointerOrigin = null;
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: _handleCalendarScroll,
              child: BlocBuilder<AgendaBloc, AgendaState>(
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
                          child: AppRetryState(
                            title: 'No se pudo cargar la agenda',
                            message: state.message,
                            icon: Icons.cloud_off_outlined,
                            onRetry: () => context.read<AgendaBloc>().add(
                              const RefreshAgenda(),
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

                  if (state.entries.isEmpty) {
                    if (_directoryLoadError != null) {
                      return CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          header,
                          SliverFillRemaining(
                            child: AppRetryState(
                              title: 'No se pudieron cargar tus registros',
                              message: _directoryLoadError,
                              icon: Icons.cloud_off_outlined,
                              onRetry: () {
                                _loadAnimals();
                                _loadCultivations();
                              },
                            ),
                          ),
                        ],
                      );
                    }
                    if (!_animalsLoaded || !_cultivationsLoaded) {
                      return CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          header,
                          const SliverFillRemaining(
                            child: AppLoadingIndicator(),
                          ),
                        ],
                      );
                    }
                    final firstUse =
                        _animalsById.isEmpty && _cultivationCount == 0;
                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        header,
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.md,
                            bottomInset + AppSpacing.xxl,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: AgendaEmptyPanel(
                              firstUse: firstUse,
                              onPrimary: firstUse
                                  ? () => _showAddSelector(context)
                                  : () => _openForm(context),
                              onSecondary: firstUse
                                  ? () => _showAgendaGuide(context)
                                  : () => context.goNamed(
                                      AppRoutes.nameDirectorio,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (_searchController.text.trim().isNotEmpty &&
                      filteredEntries.isEmpty) {
                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        header,
                        const SliverFillRemaining(
                          child: AppEmptyState(
                            icon: Icons.search_off_outlined,
                            title: 'Sin resultados',
                            message:
                                'Prueba con otro nombre o tipo de actividad.',
                          ),
                        ),
                      ],
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
                              _AgendaOverviewBanner(
                                selectedDay: selectedDay,
                                entriesForDay: entriesHoy.length,
                                totalEntries: state.entries.length,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              const AgendaLegend(),
                              const SizedBox(height: AppSpacing.sm),

                              // Entries for selected day
                              _SectionHeader(
                                title:
                                    selectedDay != null &&
                                        !DateUtils.isSameDay(selectedDay, today)
                                    ? DateFormat(
                                        'd MMMM',
                                        'es',
                                      ).format(selectedDay)
                                    : 'Hoy',
                              ),
                              const SizedBox(height: 8),
                              AgendaProximasSection(
                                groups: todayGroups,
                                animalsById: _animalsById,
                                today: today,
                                emptyTitle: selectedDay == null
                                    ? 'Selecciona un día para ver tareas'
                                    : 'Sin pendientes para este día',
                                emptyMessage:
                                    'Puedes elegir otra fecha o programar un cuidado.',
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
                              if (proximosGroups.isNotEmpty) ...[
                                const SizedBox(height: 20),
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
    final selectedDate = _selectedDay ?? _visibleDate;
    final displayedMode = _calendarCollapsed
        ? CalendarMode.week
        : _calendarMode;
    final displayedDate = _calendarCollapsed ? selectedDate : _visibleDate;
    final calendarHeight = AgendaCalendarPeriod.height(
      displayedMode,
      displayedDate,
      textScale: MediaQuery.textScalerOf(context).scale(16) / 16,
    );
    final label = AgendaCalendarPeriod.label(
      displayedMode,
      displayedDate,
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
      collapsedHeight: _toolbarHeight + calendarHeight + 8,
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
                  displayedMode,
                  displayedDate,
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
                        displayedMode,
                        displayedDate,
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
                    AppIconButton(
                      icon: modeIcon,
                      tooltip: 'Cambiar vista: $modeLabel',
                      compact: true,
                      onPressed: _cycleCalendarMode,
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
              visibleDate: displayedDate,
              mode: displayedMode,
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

  /// Overdue and upcoming tasks, excluding the selected date. Anchored on
  /// real "today", not the calendar's selected day, so the pending worklist
  /// doesn't shift just because the user is browsing a different date.
  List<AgendaEntry> _entriesPendientes(
    List<AgendaEntry> entries,
    DateTime today, {
    DateTime? selectedKey,
  }) {
    final todayKey = _dayKey(today);
    return entries.where((e) {
      if (_taskGrouper.isTerminal(e)) return false;
      final day = _dayKey(e.fecha);
      if (selectedKey != null && day == selectedKey) return false;
      final overdue = day.isBefore(todayKey);
      final upcoming = !day.isBefore(todayKey);
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

  void _cycleCalendarMode() {
    setState(() {
      _calendarMode = switch (_calendarMode) {
        CalendarMode.week => CalendarMode.twoWeeks,
        CalendarMode.twoWeeks => CalendarMode.month,
        CalendarMode.month => CalendarMode.week,
      };
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

  Future<void> _showAddSelector(BuildContext context) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Qué quieres agregar?',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  key: const ValueKey('agenda-add-animal'),
                  leading: const Icon(Icons.pets_outlined),
                  title: const Text('Agregar animal'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.pushNamed(AppRoutes.nameAnimalNuevo);
                  },
                ),
                ListTile(
                  key: const ValueKey('agenda-add-crop'),
                  leading: const Icon(Icons.spa_outlined),
                  title: const Text('Agregar cultivo'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.pushNamed(AppRoutes.nameCultivoNuevo);
                  },
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> _showAgendaGuide(
    BuildContext context,
  ) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cómo funciona la agenda',
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('1. Agrega tus animales o cultivos en el Directorio.'),
            const SizedBox(height: AppSpacing.sm),
            const Text('2. Programa los cuidados y elige una fecha.'),
            const SizedBox(height: AppSpacing.sm),
            const Text('3. Revisa y registra las actividades desde la agenda.'),
          ],
        ),
      ),
    ),
  );

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

class _AgendaOverviewBanner extends StatelessWidget {
  const _AgendaOverviewBanner({
    required this.selectedDay,
    required this.entriesForDay,
    required this.totalEntries,
  });

  final DateTime? selectedDay;
  final int entriesForDay;
  final int totalEntries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dayLabel =
        selectedDay == null || DateUtils.isSameDay(selectedDay, DateTime.now())
        ? 'hoy'
        : DateFormat('d MMMM', 'es').format(selectedDay!);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month_outlined, size: 28, color: scheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu agenda en marcha',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '$entriesForDay ${entriesForDay == 1 ? 'actividad' : 'actividades'} para $dayLabel · $totalEntries en total',
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
}
