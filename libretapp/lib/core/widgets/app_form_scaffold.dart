/// core › widgets › app_form_scaffold — shared full-screen form chrome.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/app_button.dart';
import 'package:libretapp/core/widgets/app_loading_indicator.dart';
import 'package:libretapp/core/widgets/generated_asset_title.dart';
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
    this.formKey,
    this.assetPath,
    this.fallbackIcon = Icons.description_outlined,
    this.loading = false,
    this.onCancel,
    this.cancelLabel = 'Cancelar',
    this.saveIcon = Icons.save_outlined,
    this.saveKey,
    super.key,
  });

  final String title;
  final List<Widget> fields;
  final bool saving;
  final bool loading;
  final VoidCallback onSave;
  final String saveLabel;
  final GlobalKey<FormState>? formKey;
  final String? assetPath;
  final IconData fallbackIcon;
  final VoidCallback? onCancel;
  final String cancelLabel;
  final IconData saveIcon;

  /// Stable semantic hook for UI/integration tests of the form action.
  final Key? saveKey;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...fields,
        const SizedBox(height: AppSpacing.md),
        _buildActions(),
        SizedBox(
          height: AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: assetPath == null
            ? Text(title)
            : GeneratedAssetTitle(
                title: title,
                assetPath: assetPath!,
                fallbackIcon: fallbackIcon,
              ),
      ),
      body: loading
          ? const AppLoadingIndicator()
          : SafeArea(
              top: false,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: formKey == null
                    ? content
                    : Form(key: formKey, child: content),
              ),
            ),
    );
  }

  Widget _buildActions() {
    final save = AppButton(
      key: saveKey,
      label: saveLabel,
      icon: saveIcon,
      expanded: true,
      isLoading: saving,
      onPressed: onSave,
    );
    final cancel = onCancel == null
        ? null
        : AppButton(
            label: cancelLabel,
            variant: AppButtonVariant.secondary,
            expanded: true,
            onPressed: saving ? null : onCancel,
          );

    if (cancel == null) return save;

    return Row(
      children: [
        Expanded(child: cancel),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: save),
      ],
    );
  }
}
