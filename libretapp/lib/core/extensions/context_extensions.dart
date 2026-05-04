/// core › extensions › context_extensions — BuildContext extension methods.
///
/// Convenience getters on [BuildContext] for frequently accessed services.
library;

import 'package:flutter/material.dart';

/// Convenience extensions on [BuildContext] for common UI operations.
extension SnackBarExtensions on BuildContext {
  /// Shows a success-styled [SnackBar] with the given [message].
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  /// Shows an error-styled [SnackBar] with the given [message].
  void showErrorSnackBar(String message) {
    final colorScheme = Theme.of(this).colorScheme;
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
