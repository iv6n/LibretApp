import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/app_button.dart';
import 'package:libretapp/theme/theme.dart';

/// Shared scrolling and reading width for full pages and modal record forms.
class AppFormBody extends StatelessWidget {
  const AppFormBody({
    required this.child,
    this.bottomPadding = AppSpacing.xl,
    this.includeKeyboardInset = true,
    this.bottomSafeArea = true,
    super.key,
  });

  final Widget child;
  final double bottomPadding;
  final bool includeKeyboardInset;
  final bool bottomSafeArea;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.sizeOf(context).width >= 600
        ? AppSpacing.lg
        : AppSpacing.md;
    return SafeArea(
      top: false,
      bottom: bottomSafeArea,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          AppSpacing.md,
          horizontalPadding,
          bottomPadding +
              (includeKeyboardInset
                  ? MediaQuery.viewInsetsOf(context).bottom
                  : 0),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ),
    );
  }
}

/// Actions stack on small screens or with large text so labels stay readable.
class AppFormActions extends StatelessWidget {
  const AppFormActions({
    required this.onSave,
    this.saving = false,
    this.saveLabel = 'Guardar',
    this.saveIcon = Icons.save_outlined,
    this.saveKey,
    this.saveSemanticLabel,
    this.onCancel,
    this.cancelLabel = 'Cancelar',
    this.textCancel = false,
    super.key,
  });

  final VoidCallback? onSave;
  final bool saving;
  final String saveLabel;
  final IconData saveIcon;
  final Key? saveKey;
  final String? saveSemanticLabel;
  final VoidCallback? onCancel;
  final String cancelLabel;
  final bool textCancel;

  @override
  Widget build(BuildContext context) {
    final save = MergeSemantics(
      child: AppButton(
        key: saveKey,
        label: saveLabel,
        semanticLabel: saveSemanticLabel,
        icon: saveIcon,
        expanded: true,
        isLoading: saving,
        onPressed: onSave,
      ),
    );
    if (onCancel == null) return save;
    final cancel = textCancel
        ? TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 48),
              textStyle: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontSize: 12),
              alignment: Alignment.centerLeft,
            ),
            onPressed: saving ? null : onCancel,
            child: Text(cancelLabel),
          )
        : AppButton(
            label: cancelLabel,
            variant: AppButtonVariant.secondary,
            expanded: true,
            onPressed: saving ? null : onCancel,
          );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < (textCancel ? 320 : 360) ||
            MediaQuery.textScalerOf(context).scale(1) >= 1.5) {
          return Column(
            mainAxisSize: MainAxisSize.min,
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
            if (textCancel) cancel else Expanded(child: cancel),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: save),
          ],
        );
      },
    );
  }
}
