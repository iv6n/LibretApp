/// features › agenda › widgets › agenda_legend — legend widget for agenda type colours.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/agenda/widgets/agenda_constants.dart';

class AgendaLegend extends StatelessWidget {
  const AgendaLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 6,
            children: agendaLegendItems
                .map(
                  (item) => Chip(
                    backgroundColor: item.color.withValues(alpha: 0.12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: .3,
                      vertical: 2,
                    ),
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
                        const SizedBox(width: 4),
                        Text(item.label, style: theme.textTheme.labelSmall),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        if (MediaQuery.sizeOf(context).width < 800)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: 28,
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.scaffoldBackgroundColor.withValues(alpha: 0),
                      theme.scaffoldBackgroundColor,
                    ],
                  ),
                ),
                child: const Icon(Icons.chevron_right, size: 16),
              ),
            ),
          ),
      ],
    );
  }
}
