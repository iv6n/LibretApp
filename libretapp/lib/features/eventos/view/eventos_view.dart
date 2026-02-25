import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/features/eventos/bloc/eventos_bloc.dart';
import 'package:libretapp/features/eventos/bloc/eventos_event.dart';
import 'package:libretapp/features/eventos/bloc/eventos_state.dart';
import 'package:libretapp/features/eventos/data/eventos_model.dart';
import 'package:libretapp/features/eventos/widgets/widgets.dart';

class EventosView extends StatefulWidget {
  const EventosView({super.key});

  @override
  State<EventosView> createState() => _EventosViewState();
}

class _EventosViewState extends State<EventosView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _searchFocusNode;
  DateTime _visibleDate = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  late final TabController _tabController;
  bool _isSearchActive = false;
  CalendarMode _calendarMode = CalendarMode.twoWeeks;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchFocusNode = FocusNode()..addListener(_updateSearchActive);
    _searchController.addListener(_updateSearchActive);
  }

  @override
  void dispose() {
    _searchController.removeListener(_updateSearchActive);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _updateSearchActive() {
    final active =
        _searchFocusNode.hasFocus || _searchController.text.trim().isNotEmpty;
    if (active == _isSearchActive) return;
    setState(() => _isSearchActive = active);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = ShellInsets.bottomSafePadding(context);
    final fabConfig = ShellFabConfig(
      id: 'eventos',
      label: 'Agregar',
      icon: Icons.add_task,
      heroTag: 'fab_eventos',
      onPressed: () => _openForm(context),
    );

    return ShellFabConfigScope(
      config: fabConfig,
      child: ShellChromeScope(
        visible: !_isSearchActive,
        child: Scaffold(
          appBar: AppBar(title: const Text('Eventos'), elevation: 0),
          body: BlocBuilder<EventosBloc, EventosState>(
            builder: (context, state) {
              if (state is EventosLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is EventosError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              if (state is! EventosLoaded) {
                return const SizedBox.shrink();
              }

                final filteredEventos = _filterByQuery(state.eventos);
                final visibleRange = _visibleRange();
                final eventosVisibles =
                  _eventosEnRango(filteredEventos, visibleRange);
                final eventosPorDia = _agruparPorDia(eventosVisibles);
              final DateTime? selectedDay = _selectedDay;
              final selectedKey = selectedDay != null
                  ? DateTime(
                      selectedDay.year,
                      selectedDay.month,
                      selectedDay.day,
                    )
                  : null;
              final eventosSeleccionados = selectedKey != null
                    ? eventosPorDia[selectedKey] ?? const []
                    : eventosVisibles;

                  final proximos = _proximos(filteredEventos, selectedKey);

              return LayoutBuilder(
                builder: (context, constraints) {
                  final double tabHeight = constraints.maxHeight * 0.45;

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset + 2),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 24 + bottomInset,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EventSearchBar(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 8),
                          EventMonthHeader(
                            visibleMonth: _visibleDate,
                            onPrevious: () => _cambiarMes(-1),
                            onNext: () => _cambiarMes(1),
                            mode: _calendarMode,
                            onToggleMode: _toggleMode,
                          ),
                          const SizedBox(height: 12),
                          const _SectionTitle('Calendario'),
                          const SizedBox(height: 6),
                          const EventLegend(),
                          const SizedBox(height: 8),
                          EventCalendar(
                            visibleDate: _visibleDate,
                            mode: _calendarMode,
                            selectedDay: _selectedDay,
                            eventosPorDia: eventosPorDia,
                            onDaySelected: (day) =>
                                setState(() {
                              _selectedDay = day;
                              _visibleDate = day;
                              _clampSelectionToRange();
                            }),
                          ),
                          const SizedBox(height: 12),
                          const _SectionTitle('Listado del día'),
                          TabBar(
                            controller: _tabController,
                            labelColor: theme.colorScheme.primary,
                            unselectedLabelColor:
                                theme.textTheme.bodyMedium?.color,
                            indicatorColor: theme.colorScheme.primary,
                            tabs: const [
                              Tab(text: 'Pendientes'),
                              Tab(text: 'Próximos'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: tabHeight,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                EventList(
                                  eventos: eventosSeleccionados,
                                  emptyLabel: selectedDay == null
                                      ? 'Selecciona un día para ver detalles'
                                      : 'Sin pendientes para este día',
                                  onDelete: (id) => context
                                      .read<EventosBloc>()
                                      .add(DeleteEvento(id)),
                                ),
                                EventList(
                                  eventos: proximos,
                                  emptyLabel:
                                      'No hay próximos en los siguientes días',
                                  onDelete: (id) => context
                                      .read<EventosBloc>()
                                      .add(DeleteEvento(id)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  List<Evento> _proximos(List<Evento> eventosMes, DateTime? selectedKey) {
    if (selectedKey == null) return eventosMes;
    final limite = selectedKey.add(const Duration(days: 14));
    return eventosMes
        .where(
          (e) =>
              e.fecha.isAfter(selectedKey) &&
              e.fecha.isBefore(limite.add(const Duration(days: 1))),
        )
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
  }

  Map<DateTime, List<Evento>> _agruparPorDia(List<Evento> eventos) {
    final mapa = <DateTime, List<Evento>>{};
    for (final evento in eventos) {
      final key = DateTime(
        evento.fecha.year,
        evento.fecha.month,
        evento.fecha.day,
      );
      mapa.putIfAbsent(key, () => <Evento>[]).add(evento);
    }
    return mapa;
  }

  List<Evento> _eventosEnRango(List<Evento> eventos, DateTimeRange rango) {
    return eventos
        .where(
          (e) =>
              !e.fecha.isBefore(rango.start) && !e.fecha.isAfter(rango.end),
        )
        .toList();
  }

  List<Evento> _filterByQuery(List<Evento> eventos) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return eventos;
    return eventos
        .where(
          (e) =>
              e.titulo.toLowerCase().contains(query) ||
              e.tipo.toLowerCase().contains(query) ||
              e.animalId.toLowerCase().contains(query),
        )
        .toList();
  }

  void _cambiarMes(int delta) {
    setState(() {
      if (_calendarMode == CalendarMode.month) {
        _visibleDate =
            DateTime(_visibleDate.year, _visibleDate.month + delta, 1);
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
      final end = DateTime(_visibleDate.year, _visibleDate.month + 1, 0, 23,
          59, 59, 999, 999);
      return DateTimeRange(start: start, end: end);
    }

    final start = _inicioSemana(_visibleDate);
    final end = start.add(const Duration(days: 13, hours: 23, minutes: 59,
        seconds: 59, milliseconds: 999, microseconds: 999));
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
    return showEventFormSheet(
      context: context,
      initialDate: initialDate,
      onSave: (evento) => context.read<EventosBloc>().add(AddEvento(evento)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}
