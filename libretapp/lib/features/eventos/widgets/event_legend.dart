import 'package:flutter/material.dart';
import 'package:libretapp/features/eventos/widgets/event_constants.dart';

class EventLegend extends StatelessWidget {
  const EventLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: eventLegendItems
          .map(
            (item) => Chip(
              backgroundColor: item.color.withValues(alpha: 0.14),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(item.label),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
