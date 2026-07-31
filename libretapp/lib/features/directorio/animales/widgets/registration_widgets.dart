/// Reusable controls shared by quick and full animal registration.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/theme/app_theme.dart';

class AnimalSpeciesSelector extends StatelessWidget {
  const AnimalSpeciesSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.includeOther = true,
  });

  final Species value;
  final ValueChanged<Species> onChanged;
  final bool includeOther;

  @override
  Widget build(BuildContext context) {
    final values = includeOther
        ? Species.values
        : Species.values.where((species) => species != Species.other).toList();
    return Semantics(
      label: 'Seleccionar especie',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: values.map((species) {
            final selected = species == value;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: ChoiceChip(
                  avatar: selected
                      ? const Icon(Icons.check, size: 18)
                      : Icon(_iconForSpecies(species), size: 18),
                  label: Text(species.displayName),
                  selected: selected,
                  onSelected: (_) => onChanged(species),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class CompactSexSelector extends StatelessWidget {
  const CompactSexSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Sex value;
  final ValueChanged<Sex> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: Sex.values.map((sex) {
        final selected = sex == value;
        return SizedBox(
          height: 48,
          child: ChoiceChip(
            avatar: Icon(
              sex == Sex.female ? Icons.female : Icons.male,
              size: 20,
            ),
            label: Text(sex.displayName),
            selected: selected,
            onSelected: (_) => onChanged(sex),
            labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        );
      }).toList(),
    );
  }
}

class ApproximateAgeField extends StatelessWidget {
  const ApproximateAgeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Edad aproximada',
    this.enabled = true,
  });

  final ApproximateAge value;
  final ValueChanged<ApproximateAge> onChanged;
  final String label;
  final bool enabled;

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<ApproximateAge>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _AgePickerSheet(initialValue: value),
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label, ${value.displayLabel}',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: enabled ? () => _openPicker(context) : null,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.cake_outlined),
            suffixIcon: const Icon(Icons.unfold_more),
            enabled: enabled,
          ),
          child: Text(
            value.displayLabel,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _AgePickerSheet extends StatefulWidget {
  const _AgePickerSheet({required this.initialValue});

  final ApproximateAge initialValue;

  @override
  State<_AgePickerSheet> createState() => _AgePickerSheetState();
}

class _AgePickerSheetState extends State<_AgePickerSheet> {
  late int _years;
  late int _months;
  late final FixedExtentScrollController _yearsController;
  late final FixedExtentScrollController _monthsController;

  @override
  void initState() {
    super.initState();
    _years = widget.initialValue.years;
    _months = widget.initialValue.months;
    _yearsController = FixedExtentScrollController(initialItem: _years);
    _monthsController = FixedExtentScrollController(initialItem: _months);
  }

  @override
  void dispose() {
    _yearsController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final age = ApproximateAge(years: _years, months: _months);
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Edad aproximada',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            age.displayLabel,
            key: const ValueKey('approximate-age-preview'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 190,
            child: Row(
              children: [
                Expanded(
                  child: _AgeWheel(
                    semanticsLabel: 'Años',
                    controller: _yearsController,
                    count: ApproximateAge.maxYears + 1,
                    labelFor: (index) =>
                        '$index año${index == 1 ? '' : 's'}',
                    onChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() => _years = index);
                    },
                  ),
                ),
                Expanded(
                  child: _AgeWheel(
                    semanticsLabel: 'Meses',
                    controller: _monthsController,
                    count: 12,
                    labelFor: (index) =>
                        '$index mes${index == 1 ? '' : 'es'}',
                    onChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() => _months = index);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(age),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgeWheel extends StatelessWidget {
  const _AgeWheel({
    required this.semanticsLabel,
    required this.controller,
    required this.count,
    required this.labelFor,
    required this.onChanged,
  });

  final String semanticsLabel;
  final FixedExtentScrollController controller;
  final int count;
  final String Function(int index) labelFor;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 48,
            physics: const FixedExtentScrollPhysics(),
            diameterRatio: 1.35,
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: count,
              builder: (context, index) => Center(
                child: Text(
                  labelFor(index),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconForSpecies(Species species) {
  switch (species) {
    case Species.cattle:
      return Icons.agriculture_outlined;
    case Species.equine:
      return Icons.directions_run;
    case Species.sheep:
    case Species.goat:
      return Icons.pets_outlined;
    case Species.pig:
      return Icons.cruelty_free_outlined;
    case Species.poultry:
      return Icons.egg_outlined;
    case Species.canine:
      return Icons.pets;
    case Species.other:
      return Icons.category_outlined;
  }
}
