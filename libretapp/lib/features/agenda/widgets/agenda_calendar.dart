/// features › agenda › widgets › agenda_calendar — calendar grid widget for agenda.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/widgets/agenda_style.dart';

enum CalendarMode { week, twoWeeks, month }

/// Calendar-day calculations shared by the header and its grid.
class AgendaCalendarPeriod {
  const AgendaCalendarPeriod._();

  static const double rowHeight = 48;
  static const double weekdayHeight = 20;
  static const double weekdayGap = 4;

  static DateTime day(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime startOfWeek(DateTime value) =>
      DateTime(value.year, value.month, value.day - value.weekday + 1);

  static List<DateTime> days(CalendarMode mode, DateTime visibleDate) {
    if (mode != CalendarMode.month) {
      final start = startOfWeek(visibleDate);
      final count = mode == CalendarMode.week ? 7 : 14;
      return List<DateTime>.generate(
        count,
        (index) => DateTime(start.year, start.month, start.day + index),
      );
    }

    final firstOfMonth = DateTime(visibleDate.year, visibleDate.month);
    final start = startOfWeek(firstOfMonth);
    final count =
        firstOfMonth.weekday -
        DateTime.monday +
        DateUtils.getDaysInMonth(visibleDate.year, visibleDate.month);
    final cells = ((count + 6) ~/ 7) * 7;
    return List<DateTime>.generate(
      cells,
      (index) => DateTime(start.year, start.month, start.day + index),
    );
  }

  static DateTimeRange range(CalendarMode mode, DateTime visibleDate) {
    if (mode == CalendarMode.month) {
      return DateTimeRange(
        start: DateTime(visibleDate.year, visibleDate.month),
        end: DateTime(visibleDate.year, visibleDate.month + 1, 0),
      );
    }
    final visibleDays = days(mode, visibleDate);
    return DateTimeRange(start: visibleDays.first, end: visibleDays.last);
  }

  static DateTime navigate(CalendarMode mode, DateTime selectedDay, int delta) {
    if (mode == CalendarMode.month) {
      final targetMonth = DateTime(selectedDay.year, selectedDay.month + delta);
      final lastDay = DateUtils.getDaysInMonth(
        targetMonth.year,
        targetMonth.month,
      );
      return DateTime(
        targetMonth.year,
        targetMonth.month,
        selectedDay.day.clamp(1, lastDay),
      );
    }
    final span = mode == CalendarMode.week ? 7 : 14;
    return DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day + span * delta,
    );
  }

  static String label(CalendarMode mode, DateTime visibleDate, String locale) {
    if (mode == CalendarMode.month) {
      return DateFormat.yMMMM(locale).format(visibleDate);
    }
    final period = range(mode, visibleDate);
    final start = period.start;
    final end = period.end;
    if (start.year != end.year) {
      return '${DateFormat('d MMM y', locale).format(start)} – '
          '${DateFormat('d MMM y', locale).format(end)}';
    }
    if (start.month != end.month) {
      return '${DateFormat('d MMM', locale).format(start)} – '
          '${DateFormat('d MMM y', locale).format(end)}';
    }
    return '${start.day}–${DateFormat('d MMM y', locale).format(end)}';
  }

  static String compactLabel(
    CalendarMode mode,
    DateTime visibleDate,
    String locale, {
    bool numeric = false,
  }) {
    if (mode == CalendarMode.month) {
      return DateFormat('MMM y', locale).format(visibleDate);
    }
    final period = range(mode, visibleDate);
    final start = period.start;
    final end = period.end;
    if (numeric) {
      return '${start.day}/${start.month}–${end.day}/${end.month}';
    }
    final endLabel = DateFormat('d MMM', locale).format(end);
    if (start.year != end.year) {
      return '${DateFormat('d MMM yy', locale).format(start)}–'
          '${DateFormat('d MMM yy', locale).format(end)}';
    }
    if (start.month != end.month) {
      return '${DateFormat('d MMM', locale).format(start)}–$endLabel';
    }
    return '${start.day}–$endLabel';
  }

  static double height(CalendarMode mode, DateTime visibleDate) =>
      weekdayHeight +
      weekdayGap +
      (days(mode, visibleDate).length ~/ 7) * rowHeight;
}

class AgendaCalendar extends StatelessWidget {
  const AgendaCalendar({
    super.key,
    required this.visibleDate,
    required this.mode,
    required this.selectedDay,
    required this.entriesByDay,
    required this.onDaySelected,
  });

  final DateTime visibleDate;
  final CalendarMode mode;
  final DateTime? selectedDay;
  final Map<DateTime, List<AgendaEntry>> entriesByDay;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const dayHeaders = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final dias = AgendaCalendarPeriod.days(mode, visibleDate);

    return Column(
      children: [
        SizedBox(
          height: AgendaCalendarPeriod.weekdayHeight,
          child: Row(
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
        ),
        const SizedBox(height: AgendaCalendarPeriod.weekdayGap),
        SizedBox(
          height: (dias.length ~/ 7) * AgendaCalendarPeriod.rowHeight,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: AgendaCalendarPeriod.rowHeight,
            ),
            itemCount: dias.length,
            itemBuilder: (context, index) {
              final dia = dias[index];
              final isDelMes = mode == CalendarMode.month
                  ? dia.month == visibleDate.month
                  : true;
              final diaKey = DateTime(dia.year, dia.month, dia.day);
              final entries = entriesByDay[diaKey] ?? const [];
              final esHoy = DateUtils.isSameDay(dia, DateTime.now());
              final seleccionado =
                  selectedDay != null && DateUtils.isSameDay(dia, selectedDay);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.all(1),
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
                    padding: const EdgeInsets.all(3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '${dia.day}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDelMes
                                      ? theme.colorScheme.onSurface
                                      : theme.disabledColor,
                                  fontWeight: seleccionado
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (entries.isNotEmpty)
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
                        const SizedBox(height: 2),
                        if (entries.isNotEmpty)
                          Wrap(
                            spacing: 3,
                            runSpacing: 1,
                            children: entries
                                .take(3)
                                .map(
                                  (e) => Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: colorForTipo(e.tipo),
                                      shape: BoxShape.circle,
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
        ),
      ],
    );
  }
}
