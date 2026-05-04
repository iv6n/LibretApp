/// features \u203a eventos \u203a widgets \u203a event_month_header \u2014 header row showing month name and navigation.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/features/eventos/widgets/event_calendar.dart';

class EventMonthHeader extends StatelessWidget {
  const EventMonthHeader({
    super.key,
    required this.visibleMonth,
    required this.onPrevious,
    required this.onNext,
    required this.mode,
    required this.onToggleMode,
  });

  final DateTime visibleMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final CalendarMode mode;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = DateFormat.yMMMM();
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Mes anterior',
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                formatter.format(visibleMonth),
                style: theme.textTheme.titleLarge,
              ),
              Text(
                'Calendario de vacunaciones, mantenimientos y alertas',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: OutlinedButton.icon(
            onPressed: onToggleMode,
            icon: Icon(
              mode == CalendarMode.month
                  ? Icons.view_week
                  : Icons.calendar_month,
              size: 18,
            ),
            label: Text(
              mode == CalendarMode.month ? '2 semanas' : 'Mes',
              style: theme.textTheme.labelLarge,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Mes siguiente',
        ),
      ],
    );
  }
}
