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
    builder: (context) => SizedBox(
      height: 200,
      child: Center(child: Text('Animal Filters Sheet')),
    ),
  );
}
