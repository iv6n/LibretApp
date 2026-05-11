/// features › agenda › widgets › agenda_month_header — header row showing month name and navigation.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/features/agenda/widgets/agenda_calendar.dart';

class AgendaMonthHeader extends StatelessWidget {
  const AgendaMonthHeader({
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
          tooltip: 'Anterior',
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                formatter.format(visibleMonth),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            visualDensity: VisualDensity.compact,
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Siguiente',
        ),
      ],
    );
  }
}
