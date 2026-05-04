/// features \u203a directorio \u203a animales \u203a widgets \u203a detail_error \u2014 error state widget for the animal detail page.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class DetailError extends StatelessWidget {
  const DetailError({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.detailRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
