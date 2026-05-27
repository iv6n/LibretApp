/// finanzas › widgets › record_tile — list tile for income/expense records.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A [Card]-based list tile used in the Ingresos and Gastos tabs.
class RecordTile extends StatelessWidget {
  const RecordTile({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.amountColor,
    this.subtitle,
    this.currency,
    this.onDelete,
  });

  final String title;
  final String? subtitle;
  final DateTime date;
  final String amount;
  final Color amountColor;
  final String? currency;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('dd MMM yyyy', 'es');
    return Card(
      child: ListTile(
        title: Text(title, style: theme.textTheme.bodyMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFmt.format(date),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (subtitle != null)
              Text(subtitle!, style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$amount${currency != null ? ' $currency' : ''}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: onDelete,
                color: theme.colorScheme.error,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
