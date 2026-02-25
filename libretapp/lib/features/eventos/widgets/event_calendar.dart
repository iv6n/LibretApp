import 'package:flutter/material.dart';
import 'package:libretapp/features/eventos/data/eventos_model.dart';
import 'package:libretapp/features/eventos/widgets/event_style.dart';

enum CalendarMode { month, twoWeeks }

class EventCalendar extends StatelessWidget {
  const EventCalendar({
    super.key,
    required this.visibleDate,
    required this.mode,
    required this.selectedDay,
    required this.eventosPorDia,
    required this.onDaySelected,
  });

  final DateTime visibleDate;
  final CalendarMode mode;
  final DateTime? selectedDay;
  final Map<DateTime, List<Evento>> eventosPorDia;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const dayHeaders = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final dias = _diasParaCalendario(mode, visibleDate);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: dayHeaders
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.78,
          ),
          itemCount: dias.length,
          itemBuilder: (context, index) {
            final dia = dias[index];
            final isDelMes = mode == CalendarMode.month
                ? dia.month == visibleDate.month
                : true;
            final diaKey = DateTime(dia.year, dia.month, dia.day);
            final eventos = eventosPorDia[diaKey] ?? const [];
            final esHoy = DateUtils.isSameDay(dia, DateTime.now());
            final seleccionado =
                selectedDay != null && DateUtils.isSameDay(dia, selectedDay);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: seleccionado
                    ? theme.colorScheme.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: esHoy
                      ? theme.colorScheme.primary
                      : Colors.grey.shade300,
                  width: esHoy ? 1.4 : 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: isDelMes ? () => onDaySelected(dia) : null,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${dia.day}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDelMes
                                  ? theme.colorScheme.onSurface
                                  : theme.disabledColor,
                              fontWeight: seleccionado
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          if (eventos.isNotEmpty)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: eventos
                            .take(3)
                            .map(
                              (e) => Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorForTipo(
                                    e.tipo,
                                  ).withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  e.titulo,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorForTipo(e.tipo),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<DateTime> _diasParaCalendario(CalendarMode mode, DateTime base) {
    if (mode == CalendarMode.twoWeeks) {
      final inicio = _inicioSemana(base);
      return List<DateTime>.generate(
        14,
        (index) => inicio.add(Duration(days: index)),
      );
    }

    final primerDiaMes = DateTime(base.year, base.month, 1);
    final diasAntes = primerDiaMes.weekday - 1;
    final primerDiaVista = primerDiaMes.subtract(Duration(days: diasAntes));
    final totalDiasMes = DateUtils.getDaysInMonth(base.year, base.month);
    final totalCeldas = diasAntes + totalDiasMes;
    final filas = (totalCeldas / 7).ceil();
    final celdas = filas * 7;

    return List<DateTime>.generate(
      celdas,
      (index) => primerDiaVista.add(Duration(days: index)),
    );
  }

  DateTime _inicioSemana(DateTime fecha) {
    final normalizada = DateTime(fecha.year, fecha.month, fecha.day);
    final diasARestar = normalizada.weekday - DateTime.monday;
    return normalizada.subtract(Duration(days: diasARestar));
  }
}
