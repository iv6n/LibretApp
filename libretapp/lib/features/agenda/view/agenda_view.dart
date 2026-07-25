/// features › agenda › view › agenda_view — main view for the agenda calendar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/agenda/bloc/agenda_bloc.dart';
import 'package:libretapp/features/agenda/bloc/agenda_event.dart';
import 'package:libretapp/features/agenda/bloc/agenda_state.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/view/agenda_task_detail_page.dart';
import 'package:libretapp/features/agenda/widgets/widgets.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _searchFocusNode;
  DateTime _visibleDate = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  bool _isSearchActive = false;
  bool _isSearchFieldActive = false;
  CalendarMode _calendarMode = CalendarMode.twoWeeks;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode()..addListener(_updateSearchActive);
    _searchController.addListener(_updateSearchActive);
  }

  @override
  void dispose() {
    _searchController.removeListener(_updateSearchActive);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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
      config: fabConfig,
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
                return const Center(child: CircularProgressIndicator());
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
              final proximosEntries = _proximos(filteredEntries, selectedKey);

              return SingleChildScrollView(
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
                    if (entriesHoy.isEmpty)
                      _EmptyState(
                        icon: Icons.inbox_outlined,
                        message: selectedDay == null
                            ? 'Selecciona un día para ver tareas'
                            : 'Sin tareas para este día',
                      )
                    else
                      Column(
                        children: entriesHoy
                            .map(
                              (e) => AgendaSummaryCard(
                                entry: e,
                                onDelete: () => context.read<AgendaBloc>().add(
                                  DeleteAgendaEntry(e.id),
                                ),
                                onRealize: () => _openTaskDetail(context, e),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 20),

                    // Próximas tareas
                    const _SectionHeader(title: 'Próximas tareas (14 días)'),
                    const SizedBox(height: 8),
                    if (proximosEntries.isEmpty)
                      const _EmptyState(
                        icon: Icons.event_outlined,
                        message: 'No hay próximas tareas',
                      )
                    else
                      Column(
                        children: proximosEntries
                            .map(
                              (e) => AgendaSummaryCard(
                                entry: e,
                                onDelete: () => context.read<AgendaBloc>().add(
                                  DeleteAgendaEntry(e.id),
                                ),
                                onRealize: () => _openTaskDetail(context, e),
                              ),
                            )
                            .toList(),
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

  List<AgendaEntry> _proximos(
    List<AgendaEntry> entries,
    DateTime? selectedKey,
  ) {
    if (selectedKey == null) return entries;
    final limite = selectedKey.add(const Duration(days: 14));
    return entries
        .where(
          (e) =>
              e.fecha.isAfter(selectedKey) &&
              e.fecha.isBefore(limite.add(const Duration(days: 1))) &&
              e.estado != AgendaEstado.completado &&
              e.estado != AgendaEstado.verificado &&
              e.estado != AgendaEstado.cancelado,
        )
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
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

  void _openTaskDetail(BuildContext context, AgendaEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<AgendaBloc>(),
          child: AgendaTaskDetailPage(entry: entry),
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

// Widget: Estado vacío
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 36, color: theme.colorScheme.outline),
            const SizedBox(height: 6),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
