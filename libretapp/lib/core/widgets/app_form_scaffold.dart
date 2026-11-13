/// core › widgets › app_form_scaffold — shared full-screen form chrome.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/app_form_body.dart';
import 'package:libretapp/core/widgets/app_form_exit_guard.dart';
import 'package:libretapp/core/widgets/app_loading_indicator.dart';
import 'package:libretapp/core/widgets/app_record_header.dart';
import 'package:libretapp/core/widgets/generated_asset_title.dart';
import 'package:libretapp/core/widgets/record_form_style.dart';
import 'package:libretapp/theme/theme.dart';

/// Provides the common page structure for forms: app bar, safe scroll area,
/// optional Form, and a predictable cancel/save footer.
class AppFormScaffold extends StatelessWidget {
  const AppFormScaffold({
    required this.title,
    required this.fields,
    required this.saving,
    required this.onSave,
    required this.saveLabel,
    this.recordStyle,
    this.onBack,
    this.contextLabel,
    this.contextIcon,
    this.errorMessage,
    this.onRetry,
    this.formKey,
    this.assetPath,
    this.fallbackIcon,
    this.loading = false,
    this.onCancel,
    this.cancelLabel = 'Cancelar',
    this.saveIcon = Icons.save_outlined,
    this.saveKey,
    this.protectUnsavedChanges = false,
    this.onExitWithinFlow,
    this.onCaptureChanged,
    this.currentSignature,
    this.initialSignature,
    super.key,
  });

  final String title;
  final List<Widget> fields;
  final bool saving;
  final bool loading;
  final VoidCallback onSave;
  final String saveLabel;
  final RecordFormStyle? recordStyle;
  final VoidCallback? onBack;

  /// Identifies the animal, lote, cultivo or location that receives the record.
  final String? contextLabel;
  final IconData? contextIcon;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final GlobalKey<FormState>? formKey;
  final String? assetPath;
  final IconData? fallbackIcon;
  final VoidCallback? onCancel;
  final String cancelLabel;
  final IconData saveIcon;

  /// Stable semantic hook for UI/integration tests of the form action.
  final Key? saveKey;
  final bool protectUnsavedChanges;
  final VoidCallback? onExitWithinFlow;
  final VoidCallback? onCaptureChanged;
  final String Function()? currentSignature;
  final String? initialSignature;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recordStyle != null) ...[
          AppRecordHeader(style: recordStyle!),
          const SizedBox(height: AppSpacing.md),
        ],
        if (contextLabel != null && contextLabel!.trim().isNotEmpty) ...[
          _FormContextBanner(
            label: contextLabel!,
            icon: contextIcon ?? Icons.link_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        AbsorbPointer(
          absorbing: saving,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: fields,
          ),
        ),
      ],
    );

    final formContent = protectUnsavedChanges
        ? Form(
            key: formKey,
            onChanged: () {
              AppFormExitGuard.refreshFromForm(context);
              onCaptureChanged?.call();
            },
            child: content,
          )
        : formKey == null
        ? content
        : Form(key: formKey, child: content);

    final scaffold = Scaffold(
      appBar: AppBar(
        leading: onBack == null && !protectUnsavedChanges
            ? null
            : IconButton(
                onPressed: saving
                    ? null
                    : () {
                        if (protectUnsavedChanges) {
                          AppFormExitGuard.requestExit(context);
                        } else {
                          onBack?.call();
                        }
                      },
                icon: const Icon(Icons.arrow_back),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              ),
        title: assetPath == null && recordStyle == null
            ? Text(title)
            : GeneratedAssetTitle(
                title: title,
                assetPath: assetPath ?? recordStyle?.assetPath,
                fallbackIcon:
                    fallbackIcon ??
                    recordStyle?.icon ??
                    Icons.description_outlined,
              ),
      ),
      body: loading
          ? const AppLoadingIndicator()
          : errorMessage != null
          ? _FormErrorState(message: errorMessage!, onRetry: onRetry)
          : AppFormBody(
              bottomPadding: 56,
              includeKeyboardInset: false,
              bottomSafeArea: false,
              child: formContent,
            ),
      bottomNavigationBar: loading || errorMessage != null
          ? null
          : AnimatedPadding(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                child: SafeArea(
                  top: false,
                  child: Container(
                    key: const ValueKey('form-action-footer'),
                    constraints: const BoxConstraints(minHeight: 72),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.sizeOf(context).width >= 600
                          ? AppSpacing.lg
                          : AppSpacing.md,
                      vertical: 12,
                    ),
                    child: Align(
                      heightFactor: 1,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: AppFormActions(
                          onSave: onSave,
                          saving: saving,
                          saveLabel: saveLabel,
                          saveSemanticLabel:
                              saveLabel == 'Guardar' && recordStyle != null
                              ? 'Guardar ${recordStyle!.label.toLowerCase()}'
                                    '${contextLabel == null ? '' : ': $contextLabel'}'
                              : saveLabel,
                          saveIcon: saveIcon,
                          saveKey: saveKey,
                          onCancel: protectUnsavedChanges
                              ? () => AppFormExitGuard.requestExit(context)
                              : onCancel,
                          cancelLabel: cancelLabel,
                          textCancel: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
    return AppFormExitGuard(
      enabled: protectUnsavedChanges,
      saving: saving,
      onExitWithinFlow: onExitWithinFlow,
      currentSignature: loading || errorMessage != null
          ? null
          : currentSignature,
      initialSignature: initialSignature,
      child: scaffold,
    );
  }
}

class _FormContextBanner extends StatelessWidget {
  const _FormContextBanner({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: scheme.primaryContainer.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, color: scheme.onPrimaryContainer),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormErrorState extends StatelessWidget {
  const _FormErrorState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
