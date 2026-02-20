import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/eventos/bloc/eventos_bloc.dart';
import 'package:libretapp/features/eventos/bloc/eventos_event.dart';
import 'package:libretapp/features/eventos/bloc/eventos_state.dart';
import 'package:libretapp/features/eventos/data/eventos_model.dart';
import 'package:libretapp/features/eventos/widgets/widgets.dart';
import 'package:libretapp/app/app_shell.dart';

class EventosView extends StatefulWidget {
  const EventosView({super.key});

  @override
  State<EventosView> createState() => _EventosViewState();
}

class _EventosViewState extends State<EventosView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDay = DateTime.now();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = AppShell.bottomSafePadding(context);
    final fabBottomPadding = AppShell.fabDockPadding(context);
    return Scaffold(
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
          final eventosMes = _eventosDelMes(filteredEventos, _visibleMonth);
          final eventosPorDia = _agruparPorDia(eventosMes);
          final DateTime? selectedDay = _selectedDay;
          final selectedKey = selectedDay != null
              ? DateTime(selectedDay.year, selectedDay.month, selectedDay.day)
              : null;
          final eventosSeleccionados = selectedKey != null
              ? eventosPorDia[selectedKey] ?? const []
              : eventosMes;

          final proximos = _proximos(eventosMes, selectedKey);

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
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      EventMonthHeader(
                        visibleMonth: _visibleMonth,
                        onPrevious: () => _cambiarMes(-1),
                        onNext: () => _cambiarMes(1),
                      ),
                      const SizedBox(height: 12),
                      const _SectionTitle('Calendario'),
                      const SizedBox(height: 6),
                      const EventLegend(),
                      const SizedBox(height: 8),
                      EventCalendar(
                        visibleMonth: _visibleMonth,
                        selectedDay: _selectedDay,
                        eventosPorDia: eventosPorDia,
                        onDaySelected: (day) =>
                            setState(() => _selectedDay = day),
                      ),
                      const SizedBox(height: 12),
                      const _SectionTitle('Listado del día'),
                      TabBar(
                        controller: _tabController,
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor: theme.textTheme.bodyMedium?.color,
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
                              onDelete: (id) => context.read<EventosBloc>().add(
                                DeleteEvento(id),
                              ),
                            ),
                            EventList(
                              eventos: proximos,
                              emptyLabel:
                                  'No hay próximos en los siguientes días',
                              onDelete: (id) => context.read<EventosBloc>().add(
                                DeleteEvento(id),
                              ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: fabBottomPadding),
        child: FloatingActionButton.extended(
          onPressed: () => _openForm(context),
          icon: const Icon(Icons.add_task),
          label: const Text('Agregar'),
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

  List<Evento> _eventosDelMes(List<Evento> eventos, DateTime mes) {
    return eventos
        .where((e) => e.fecha.year == mes.year && e.fecha.month == mes.month)
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
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
      _selectedDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    });
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
