import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/app_button.dart';
import 'package:libretapp/theme/theme.dart';

/// Shared scrolling and reading width for full pages and modal record forms.
class AppFormBody extends StatelessWidget {
  const AppFormBody({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    ),
  );
}

/// Actions stack on small screens or with large text so labels stay readable.
class AppFormActions extends StatelessWidget {
  const AppFormActions({
    required this.onSave,
    this.saving = false,
    this.saveLabel = 'Guardar',
    this.saveIcon = Icons.save_outlined,
    this.saveKey,
    this.onCancel,
    this.cancelLabel = 'Cancelar',
    super.key,
  });

  final VoidCallback? onSave;
  final bool saving;
  final String saveLabel;
  final IconData saveIcon;
  final Key? saveKey;
  final VoidCallback? onCancel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    final save = AppButton(
      key: saveKey,
      label: saveLabel,
      icon: saveIcon,
      expanded: true,
      isLoading: saving,
      onPressed: onSave,
    );
    if (onCancel == null) return save;
    final cancel = AppButton(
      label: cancelLabel,
      variant: AppButtonVariant.secondary,
      expanded: true,
      onPressed: saving ? null : onCancel,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360 ||
            MediaQuery.textScalerOf(context).scale(1) >= 1.5) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              save,
              const SizedBox(height: AppSpacing.sm),
              cancel,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: cancel),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: save),
          ],
        );
      },
    );
  }
}
