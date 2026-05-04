/// features \u203a directorio \u203a animales \u203a view \u203a show_animal_filters_sheet \u2014 shows the animal filter bottom sheet.
library;

import 'package:flutter/material.dart';

Future<void> showAnimalFiltersSheet({
  required BuildContext context,
  required Set<dynamic> selectedStages,
  required bool onlyAttention,
  required Function(bool) onAttentionChanged,
}) async {
  // Stub implementation
  await showModalBottomSheet(
    context: context,
    builder: (context) => const SizedBox(
      height: 200,
      child: Center(child: Text('Animal Filters Sheet')),
    ),
  );
}
