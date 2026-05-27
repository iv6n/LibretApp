/// finanzas › widgets › kpi_card — small metric tile for the summary tab.
library;

import 'package:flutter/material.dart';

/// A compact metric card that shows an [icon], a [label], and a [value].
///
/// Pass [large] = true for the primary "net profit" card.
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.large = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(large ? 20 : 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: large ? 24 : 18,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: large ? 24 : 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: large
                        ? theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )
                        : theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
