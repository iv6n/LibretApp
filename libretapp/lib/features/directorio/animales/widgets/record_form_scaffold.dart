/// features > directorio > animales > widgets > record_form_scaffold
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/theme/theme.dart';

/// Shared chrome for the 8 "add a record" form pages (health, movement,
/// weight, cost, commercial, production, reproduction, bulk health): an
/// [AppBar] + scrollable [Column] of [fields] + a full-width save button
/// with a loading spinner while [saving].
///
/// This intentionally only extracts the outer scaffold, not the fields
/// themselves — each record type has a genuinely different set of inputs,
/// validation, and side widgets (e.g. the advisor tips panel), so a fully
/// generic `RecordFormScaffold<TRecord>` would need to abstract all of that
/// too, which is where the actual duplication-vs-complexity tradeoff turns
/// negative. Callers keep their own State, controllers, and _save() logic.
class RecordFormScaffold extends StatelessWidget {
  const RecordFormScaffold({
    required this.title,
    required this.fields,
    required this.saving,
    required this.onSave,
    required this.saveLabel,
    this.formKey,
    this.assetPath,
    this.fallbackIcon = Icons.description_outlined,
    this.loading = false,
    super.key,
  });

  final String title;
  final List<Widget> fields;
  final bool saving;
  final bool loading;
  final VoidCallback onSave;
  final String saveLabel;

  /// When provided, [fields] are wrapped in a [Form] using this key (for
  /// pages that rely on [TextFormField] validators, e.g. bulk health).
  final GlobalKey<FormState>? formKey;
  final String? assetPath;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...fields,
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: saveLabel,
          icon: Icons.save_outlined,
          expanded: true,
          isLoading: saving,
          onPressed: onSave,
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
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: formKey == null
                    ? column
                    : Form(key: formKey, child: column),
              ),
            ),
    );
  }
}
