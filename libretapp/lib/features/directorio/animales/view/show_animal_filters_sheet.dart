/// features \u203a directorio \u203a animales \u203a view \u203a show_animal_filters_sheet \u2014 shows the animal filter bottom sheet.
library;

import 'package:flutter/material.dart';

Future<void> showAnimalFiltersSheet({
  required BuildContext context,
  required Set<dynamic> selectedStages,
  required bool onlyAttention,
  required Function(bool) onAttentionChanged,
}) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => _AnimalFiltersPage(
        selectedStages: selectedStages,
        onlyAttention: onlyAttention,
        onAttentionChanged: onAttentionChanged,
      ),
    ),
  );
}

class _AnimalFiltersPage extends StatefulWidget {
  const _AnimalFiltersPage({
    required this.selectedStages,
    required this.onlyAttention,
    required this.onAttentionChanged,
  });

  final Set<dynamic> selectedStages;
  final bool onlyAttention;
  final Function(bool) onAttentionChanged;

  @override
  State<_AnimalFiltersPage> createState() => _AnimalFiltersPageState();
}

class _AnimalFiltersPageState extends State<_AnimalFiltersPage> {
  late bool _onlyAttention;

  @override
  void initState() {
    super.initState();
    _onlyAttention = widget.onlyAttention;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtros'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _onlyAttention,
              title: const Text('Solo con atencion'),
              onChanged: (value) {
                setState(() => _onlyAttention = value);
                widget.onAttentionChanged(value);
              },
            ),
            const SizedBox(height: 8),
            Text('Etapas seleccionadas: ${widget.selectedStages.length}'),
          ],
        ),
      ),
    );
  }
}
