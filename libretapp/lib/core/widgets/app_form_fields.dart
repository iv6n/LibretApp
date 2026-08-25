/// core › widgets › app_form_fields — shared form controls.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    this.controller,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.helperText,
    this.requiredField = false,
    this.decoration,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onFieldSubmitted,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autovalidateMode,
    this.prefixIcon,
    this.suffixIcon,
    super.key,
  }) : assert(
         controller == null || initialValue == null,
         'Use controller or initialValue, not both.',
       );

  final TextEditingController? controller;
  final String? initialValue;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final bool requiredField;
  final InputDecoration? decoration;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final AutovalidateMode? autovalidateMode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      obscureText: obscureText,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      onFieldSubmitted: onFieldSubmitted,
      autovalidateMode: autovalidateMode,
      decoration: _resolveDecoration(),
    );
  }

  InputDecoration _resolveDecoration() {
    final base = decoration ?? const InputDecoration();
    final resolvedLabel = labelText ?? base.labelText;
    final label = requiredField && resolvedLabel != null
        ? (resolvedLabel.endsWith('*') ? resolvedLabel : '$resolvedLabel *')
        : resolvedLabel;

    return base.copyWith(
      labelText: label,
      hintText: hintText ?? base.hintText,
      helperText: helperText ?? base.helperText,
      prefixIcon: prefixIcon ?? base.prefixIcon,
      suffixIcon: suffixIcon ?? base.suffixIcon,
    );
  }
}

class AppSelectField<T> extends StatelessWidget {
  const AppSelectField({
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.labelText,
    this.hintText,
    this.helperText,
    this.requiredField = false,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    this.isExpanded = true,
    super.key,
  });

  final T? value;
  final List<T> items;
  final String Function(T value) itemLabel;
  final ValueChanged<T?>? onChanged;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final bool requiredField;
  final FormFieldValidator<T>? validator;
  final bool enabled;
  final Widget? prefixIcon;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final resolvedLabel = requiredField && labelText != null
        ? (labelText!.endsWith('*') ? labelText : '${labelText!} *')
        : labelText;

    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: isExpanded,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      decoration: InputDecoration(
        labelText: resolvedLabel,
        hintText: hintText,
        helperText: helperText,
        prefixIcon: prefixIcon,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
