import 'package:flutter/material.dart';
import 'package:libretapp/features/eventos/widgets/event_constants.dart';

class EventLegend extends StatelessWidget {
  const EventLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: eventLegendItems
          .map(
            (item) => Chip(
              backgroundColor: item.color.withValues(alpha: 0.12),
              padding: const EdgeInsets.symmetric(horizontal: .3, vertical: 2),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 1),
                  Text(
                    item.label,
                    style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
