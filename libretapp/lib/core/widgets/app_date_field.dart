/// core › widgets › app_date_field — shared date picker form control.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/theme/theme.dart';

/// A read-only date field with the same decoration and validation behavior as
/// the rest of the app's form controls.
///
/// Keeping the picker behind one control prevents subtle differences between
/// screens (date format, minimum touch target, and cancelled selections).
class AppDateField extends StatelessWidget {
  const AppDateField({
    required this.value,
    required this.onChanged,
    required this.labelText,
    this.emptyLabel,
    this.helperText,
    this.requiredField = false,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.allowClear = false,
    this.clearTooltip = 'Clear date',
    this.validator,
    this.prefixIcon,
    super.key,
  });

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String labelText;
  final String? emptyLabel;
  final String? helperText;
  final bool requiredField;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final bool allowClear;
  final String clearTooltip;
  final FormFieldValidator<DateTime>? validator;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat('dd/MM/yyyy', locale);
    final resolvedLabel = requiredField && !labelText.endsWith('*')
        ? '$labelText *'
        : labelText;

    return FormField<DateTime>(
      // Recreate the FormField when an async load or a parent update changes
      // the selected date, while preserving the value if the picker is
      // cancelled (showDatePicker returns null).
      key: ValueKey(value?.millisecondsSinceEpoch),
      initialValue: value,
      enabled: enabled,
      validator: validator,
      builder: (state) {
        return InputDecorator(
          // The control always renders visible text, including its empty-state
          // label. Keep the decoration floated so it cannot overlap that text.
          isEmpty: false,
          decoration: InputDecoration(
            labelText: resolvedLabel,
            helperText: helperText,
            errorText: state.errorText,
            prefixIcon: prefixIcon ?? const Icon(Icons.calendar_today_outlined),
            suffixIcon: allowClear && value != null
                ? IconButton(
                    tooltip: clearTooltip,
                    onPressed: enabled
                        ? () {
                            state.didChange(null);
                            onChanged(null);
                          }
                        : null,
                    icon: const Icon(Icons.clear),
                  )
                : null,
          ),
          child: InkWell(
            onTap: enabled ? () => _pickDate(context, state) : null,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppControlMetrics.minHeight - 32,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  value == null
                      ? (emptyLabel ?? 'Seleccionar fecha')
                      : dateFormat.format(value!),
                  style: value == null
                      ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )
                      : Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    FormFieldState<DateTime> state,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(now.year + 20),
    );
    if (picked == null) return;
    state.didChange(picked);
    onChanged(picked);
  }
}
