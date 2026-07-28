/// features > directorio > animales > widgets > record_form_scaffold
library;

import 'package:flutter/material.dart';

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
    super.key,
  });

  final String title;
  final List<Widget> fields;
  final bool saving;
  final VoidCallback onSave;
  final String saveLabel;

  /// When provided, [fields] are wrapped in a [Form] using this key (for
  /// pages that rely on [TextFormField] validators, e.g. bulk health).
  final GlobalKey<FormState>? formKey;

  @override
  Widget build(BuildContext context) {
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...fields,
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: saving ? null : onSave,
            child: saving
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(saveLabel),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: formKey == null ? column : Form(key: formKey, child: column),
        ),
      ),
    );
  }
}
