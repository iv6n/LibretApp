/// features › agenda › view › agenda_view — main view for the agenda calendar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/features/agenda/bloc/agenda_bloc.dart';
import 'package:libretapp/features/agenda/bloc/agenda_state.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/domain/agenda_task_grouping.dart';
import 'package:libretapp/features/agenda/view/agenda_task_detail_page.dart';
import 'package:libretapp/features/agenda/widgets/widgets.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _searchFocusNode;
  late final ScrollController _scrollController;
  DateTime _visibleDate = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  bool _isSearchActive = false;
  bool _isSearchFieldActive = false;
  CalendarMode _calendarMode = CalendarMode.twoWeeks;
  Map<String, AnimalEntity> _animalsById = {};
  bool _showAgendaFab = true;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _searchFocusNode = FocusNode()..addListener(_updateSearchActive);
    _searchController.addListener(_updateSearchActive);
    _loadAnimals();
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
    final theme = Theme.of(context);
    final bottomInset = ShellInsets.bottomSafePadding(context);
    final fabConfig = ShellFabConfig(
      id: 'agenda',
      label: 'Agregar',
      icon: Icons.add_task,
      heroTag: 'fab_agenda',
      onPressed: () => _openForm(context),
    );

    return ShellFabConfigScope(
      config: _showAgendaFab ? fabConfig : null,
      child: ShellChromeScope(
        visible: !_isSearchActive,
        child: Scaffold(
          appBar: AppBar(
            title: _isSearchFieldActive
                ? TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Buscar agenda...',
                      border: InputBorder.none,
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    style: theme.textTheme.bodyMedium,
                    onChanged: (_) => setState(() {}),
                  )
                : const Text('Agenda'),
            elevation: 5,
            centerTitle: false,
            leading: _isSearchFieldActive
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => setState(() {
                      _isSearchFieldActive = false;
                      _searchController.clear();
                      _searchFocusNode.unfocus();
                    }),
                  )
                : null,
            actions: [
              if (!_isSearchFieldActive)
                IconButton(
                  icon: const Icon(Icons.groups_outlined),
                  onPressed: () => showWorkforceManager(context),
                  tooltip: 'Personal y cuadrillas',
                ),
              if (!_isSearchFieldActive)
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => setState(() {
                    _isSearchFieldActive = true;
                    _searchFocusNode.requestFocus();
                  }),
                  tooltip: 'Buscar',
                ),
            ],
          ),
          body: BlocBuilder<AgendaBloc, AgendaState>(
            builder: (context, state) {
              if (state is AgendaLoading) {
                return const AppLoadingIndicator();
              }
              if (state is AgendaError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              if (state is! AgendaLoaded) {
                return const SizedBox.shrink();
              }

              final filteredEntries = _filterByQuery(state.entries);
              final visibleRange = _visibleRange();
              final entriesVisibles = _entriesEnRango(
                filteredEntries,
                visibleRange,
              );
              final entriesPorDia = _agruparPorDia(entriesVisibles);
              final DateTime? selectedDay = _selectedDay;
              final selectedKey = selectedDay != null
                  ? DateTime(
                      selectedDay.year,
                      selectedDay.month,
                      selectedDay.day,
                    )
                  : null;
              final entriesHoy = selectedKey != null
                  ? entriesPorDia[selectedKey] ?? const <AgendaEntry>[]
                  : const <AgendaEntry>[];
              final today = DateTime.now();
              const grouper = AgendaTaskGrouper();
              final todayGroups = grouper.group(entriesHoy, today: today);
              final proximosGroups = grouper.group(
                _entriesPendientes(
                  filteredEntries,
                  today,
                  selectedKey: selectedKey,
                ),
                today: today,
              );

              return SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(7, 4, 7, bottomInset + 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    _CalendarSection(
                      onToggleMode: _toggleMode,
                      visibleDate: _visibleDate,
                      mode: _calendarMode,
                      selectedDay: _selectedDay,
                      entriesPorDia: entriesPorDia,
                      onDaySelected: (day) => setState(() {
                        _selectedDay = day;
                        _visibleDate = day;
                        _clampSelectionToRange();
                      }),
                      onPrevious: () => _cambiarMes(-1),
                      onNext: () => _cambiarMes(1),
                    ),
                    const SizedBox(height: 5),
                    const AgendaLegend(),
                    const SizedBox(height: 10),

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
                      onOpenGroup: (group) => _openTaskDetail(context, group),
                    ),
                    const SizedBox(height: 20),

                    // Pendientes (atrasadas + próximos 14 días), agrupadas
                    // por categoría > tipo > animal, ordenadas por urgencia.
                    const _SectionHeader(title: 'Pendientes'),
                    const SizedBox(height: 8),
                    AgendaProximasSection(
                      groups: proximosGroups,
                      animalsById: _animalsById,
                      today: today,
                      onOpenGroup: (group) => _openTaskDetail(context, group),
                    ),
                  ],
                ),
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

  /// Overdue (no lower bound) plus what's due in the next 14 days, excluding
  /// today itself (already shown in the "Hoy" section above). Anchored on
  /// real "today", not the calendar's selected day, so the pending worklist
  /// doesn't shift just because the user is browsing a different date.
  List<AgendaEntry> _entriesPendientes(
    List<AgendaEntry> entries,
    DateTime today, {
    DateTime? selectedKey,
  }) {
    final todayKey = DateTime(today.year, today.month, today.day);
    final limite = todayKey.add(const Duration(days: 14));
    return entries.where((e) {
      final noCompletado =
          e.estado != AgendaEstado.completado &&
          e.estado != AgendaEstado.verificado &&
          e.estado != AgendaEstado.cancelado;
      if (!noCompletado) return false;
      final day = DateTime(e.fecha.year, e.fecha.month, e.fecha.day);
      if (selectedKey != null && day == selectedKey) return false;
      final overdue = day.isBefore(todayKey);
      final upcoming = day.isAfter(todayKey) && !day.isAfter(limite);
      return overdue || upcoming;
    }).toList();
  }

  Map<DateTime, List<AgendaEntry>> _agruparPorDia(List<AgendaEntry> entries) {
    final mapa = <DateTime, List<AgendaEntry>>{};
    for (final entry in entries) {
      final key = DateTime(
        entry.fecha.year,
        entry.fecha.month,
        entry.fecha.day,
      );
      mapa.putIfAbsent(key, () => <AgendaEntry>[]).add(entry);
    }
    return mapa;
  }

  List<AgendaEntry> _entriesEnRango(
    List<AgendaEntry> entries,
    DateTimeRange rango,
  ) {
    return entries
        .where(
          (e) => !e.fecha.isBefore(rango.start) && !e.fecha.isAfter(rango.end),
        )
        .toList();
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

  void _cambiarMes(int delta) {
    setState(() {
      if (_calendarMode == CalendarMode.month) {
        _visibleDate = DateTime(
          _visibleDate.year,
          _visibleDate.month + delta,
          1,
        );
        _selectedDay = DateTime(_visibleDate.year, _visibleDate.month, 1);
      } else {
        _visibleDate = _visibleDate.add(Duration(days: 14 * delta));
      }
      _clampSelectionToRange();
    });
  }

  void _toggleMode() {
    setState(() {
      _calendarMode = _calendarMode == CalendarMode.month
          ? CalendarMode.twoWeeks
          : CalendarMode.month;
      _visibleDate = _calendarMode == CalendarMode.month
          ? DateTime(
              _selectedDay?.year ?? _visibleDate.year,
              _selectedDay?.month ?? _visibleDate.month,
              1,
            )
          : (_selectedDay ?? _visibleDate);
      _clampSelectionToRange();
    });
  }

  DateTimeRange _visibleRange() {
    if (_calendarMode == CalendarMode.month) {
      final start = DateTime(_visibleDate.year, _visibleDate.month, 1);
      final end = DateTime(
        _visibleDate.year,
        _visibleDate.month + 1,
        0,
        23,
        59,
        59,
        999,
        999,
      );
      return DateTimeRange(start: start, end: end);
    }

    final start = _inicioSemana(_visibleDate);
    final end = start.add(
      const Duration(
        days: 13,
        hours: 23,
        minutes: 59,
        seconds: 59,
        milliseconds: 999,
        microseconds: 999,
      ),
    );
    return DateTimeRange(start: start, end: end);
  }

  DateTime _inicioSemana(DateTime fecha) {
    final normalizada = DateTime(fecha.year, fecha.month, fecha.day);
    final diasARestar = normalizada.weekday - DateTime.monday;
    return normalizada.subtract(Duration(days: diasARestar));
  }

  void _clampSelectionToRange() {
    final rango = _visibleRange();
    final sel = _selectedDay;
    if (sel == null) return;
    final normalizada = DateTime(sel.year, sel.month, sel.day);
    if (normalizada.isBefore(rango.start) || normalizada.isAfter(rango.end)) {
      _selectedDay = rango.start;
    } else {
      _selectedDay = normalizada;
    }
  }

  Future<void> _openForm(BuildContext context) {
    final initialDate = _selectedDay ?? DateTime.now();
    return context.pushNamed(
      AppRoutes.nameAgendaNuevo,
      queryParameters: {'date': DateFormat('yyyy-MM-dd').format(initialDate)},
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

// Widget: Sección del Calendario
class _CalendarSection extends StatelessWidget {
  const _CalendarSection({
    required this.visibleDate,
    required this.mode,
    required this.selectedDay,
    required this.entriesPorDia,
    required this.onDaySelected,
    required this.onPrevious,
    required this.onNext,
    this.onToggleMode,
  });

  final DateTime visibleDate;
  final VoidCallback? onToggleMode;
  final CalendarMode mode;
  final DateTime? selectedDay;
  final Map<DateTime, List<AgendaEntry>> entriesPorDia;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthName = DateFormat.yMMMM().format(visibleDate);

    return Column(
      children: [
        // Navigation controls
        Row(
          children: [
            IconButton(
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Anterior',
            ),
            const Expanded(child: SizedBox.shrink()),
            Center(
              child: Text(
                monthName,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: 14,
                ),
              ),
            ),
            const Expanded(child: SizedBox.shrink()),
            if (onToggleMode != null)
              OutlinedButton.icon(
                onPressed: onToggleMode,
                icon: Icon(
                  mode == CalendarMode.month
                      ? Icons.view_week_outlined
                      : Icons.calendar_month_outlined,
                  size: 14,
                ),
                label: Text(
                  mode == CalendarMode.month ? '2 semanas' : 'Mes',
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 11),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            IconButton(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Siguiente',
            ),
          ],
        ),
        const SizedBox(height: 8),
        AgendaCalendar(
          visibleDate: visibleDate,
          mode: mode,
          selectedDay: selectedDay,
          entriesByDay: entriesPorDia,
          onDaySelected: onDaySelected,
        ),
      ],
    );
  }
}
