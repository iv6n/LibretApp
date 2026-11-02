/// Shared retry action for full screen and embedded load failures.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/app_empty_state.dart';

class AppRetryState extends StatelessWidget {
  const AppRetryState({
    required this.title,
    required this.message,
    required this.onRetry,
    this.icon = Icons.error_outline,
    this.retryLabel = 'Reintentar',
    this.compact = false,
    super.key,
  });

  final String title;
  final String? message;
  final VoidCallback onRetry;
  final IconData icon;
  final String retryLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) => AppEmptyState(
    icon: icon,
    title: title,
    message: message,
    compact: compact,
    action: FilledButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: Text(retryLabel),
    ),
  );
}
