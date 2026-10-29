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
    this.assetPath,
    this.fallbackIcon = Icons.receipt_long,
    this.subtitle,
    this.currency,
    this.onDelete,
    this.onEdit,
  });

  final String title;
  final String? subtitle;
  final DateTime date;
  final String amount;
  final Color amountColor;
  final String? assetPath;
  final IconData fallbackIcon;
  final String? currency;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Eliminar movimiento'),
      content: Text('¿Eliminar «$title» por $amount${currency == null ? '' : ' $currency'}? Esta acción modifica tus registros.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Eliminar')),
      ],
    ));
    if (confirmed == true && context.mounted) onDelete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.brightness == Brightness.dark ? theme.colorScheme.onSurface : amountColor;
    return Card(child: Padding(padding: const EdgeInsets.all(12), child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(backgroundColor: color.withValues(alpha: 0.12), child: assetPath == null
          ? Icon(fallbackIcon, color: color) : Image.asset(assetPath!, width: 30, height: 30,
            errorBuilder: (_, _, _) => Icon(fallbackIcon, color: color))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: theme.textTheme.titleSmall),
          Text(DateFormat('dd MMM yyyy', 'es').format(date), style: theme.textTheme.bodySmall),
          if (subtitle != null && subtitle!.isNotEmpty) Text(subtitle!),
          const SizedBox(height: 4),
          Text('$amount${currency == null ? '' : ' $currency'}',
            style: theme.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ])),
        if (onEdit != null || onDelete != null) PopupMenuButton<String>(
          tooltip: 'Acciones del movimiento',
          onSelected: (action) async {
            if (action == 'edit') onEdit?.call();
            if (action == 'delete') await _delete(context);
          },
          itemBuilder: (_) => [
            if (onEdit != null) const PopupMenuItem(value: 'edit', child: Text('Corregir')),
            if (onDelete != null) const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ],
    )));
  }
}
