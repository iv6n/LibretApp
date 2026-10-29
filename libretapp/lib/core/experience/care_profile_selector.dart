import 'package:flutter/material.dart';
import 'package:libretapp/core/experience/care_profile.dart';

class CareProfileSelector extends StatelessWidget {
  const CareProfileSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  final CareProfile? value;
  final ValueChanged<CareProfile> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final profiles = CareProfile.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          Text(
            '¿Qué vas a cuidar?',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final profile in profiles)
              ChoiceChip(
                label: Text(profile.label),
                selected: value == profile,
                onSelected: (_) => onChanged(profile),
              ),
          ],
        ),
      ],
    );
  }
}
