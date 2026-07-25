/// Single profile info row.
library;

import 'package:flutter/material.dart';

class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = value.isEmpty;

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: theme.colorScheme.primary, size: 22),
          title: Text(label, style: theme.textTheme.labelSmall),
          subtitle: Text(
            isEmpty ? '—' : value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isEmpty ? theme.colorScheme.outline : null,
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}
