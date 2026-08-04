/// core › widgets › app_loading_indicator — themed loading spinner, centered by default.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/theme/theme.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({this.message, super.key})
    : strokeWidth = 4,
      _center = true;

  const AppLoadingIndicator.inline({super.key})
    : message = null,
      strokeWidth = 2,
      _center = false;

  final String? message;
  final double strokeWidth;
  final bool _center;

  @override
  Widget build(BuildContext context) {
    final spinner = SizedBox(
      width: strokeWidth == 2 ? 20 : 32,
      height: strokeWidth == 2 ? 20 : 32,
      child: CircularProgressIndicator(strokeWidth: strokeWidth),
    );

    if (!_center) return Center(child: spinner);

    if (message == null) return Center(child: spinner);

    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          spinner,
          const SizedBox(height: AppSpacing.md),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.64),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
