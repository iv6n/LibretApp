import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/app_directory_filter_chip.dart';
import 'package:libretapp/core/widgets/app_directory_layout.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';

/// Stage choices shown after an animal category has been selected.
class AnimalStageFilterRow extends StatelessWidget {
  const AnimalStageFilterRow({
    super.key,
    required this.species,
    required this.counts,
    required this.selectedStages,
    required this.onChanged,
    this.companionOnly = false,
  });

  final Species? species;
  final Map<LifeStage, int> counts;
  final Set<LifeStage> selectedStages;
  final ValueChanged<Set<LifeStage>> onChanged;
  final bool companionOnly;

  @override
  Widget build(BuildContext context) {
    final groups = _stageGroups(species, counts, companionOnly);
    final total = counts.values.fold<int>(0, (sum, count) => sum + count);
    if (total == 0 || groups.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return AppDirectoryFilterRow(
      children: [
        _stageChip(
          theme: theme,
          label: 'Todas',
          count: total,
          selected: selectedStages.isEmpty,
          onTap: () => onChanged(const <LifeStage>{}),
        ),
        for (final group in groups)
          _stageChip(
            theme: theme,
            label: group.label,
            count: group.count,
            selected: group.stages.any(selectedStages.contains),
            onTap: () {
              final updated = Set<LifeStage>.of(selectedStages);
              if (group.stages.any(updated.contains)) {
                updated.removeAll(group.stages);
              } else {
                updated.addAll(group.stages);
              }
              onChanged(updated);
            },
          ),
      ],
    );
  }

  Widget _stageChip({
    required ThemeData theme,
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return AppDirectoryFilterChip(
      label: label,
      selected: selected,
      count: count,
      accentColor: theme.colorScheme.primary,
      onTap: onTap,
    );
  }
}

class _AnimalStageGroup {
  const _AnimalStageGroup(this.stages, this.label, this.count);

  final List<LifeStage> stages;
  final String label;
  final int count;
}

List<_AnimalStageGroup> _stageGroups(
  Species? species,
  Map<LifeStage, int> counts,
  bool companionOnly,
) {
  final configuredGroups = companionOnly
      ? (counts.keys.toList()..sort((a, b) => a.index.compareTo(b.index)))
            .map((stage) => <LifeStage>[stage])
            .toList(growable: false)
      : switch (species) {
          Species.cattle => const [
            [LifeStage.calf, LifeStage.calfMale, LifeStage.calfFemale],
            [LifeStage.heifer],
            [LifeStage.youngBull],
            [LifeStage.steer],
            [LifeStage.cow],
            [LifeStage.bull],
          ],
          Species.equine => const [
            [LifeStage.colt, LifeStage.filly],
            [LifeStage.horse],
            [LifeStage.mare],
            [LifeStage.donkey, LifeStage.donkeyFemale],
            [LifeStage.mule],
          ],
          Species.goat => const [
            [LifeStage.kid],
            [LifeStage.youngGoat],
            [LifeStage.goat],
            [LifeStage.breedingBuck],
          ],
          Species.sheep => const [
            [LifeStage.lamb],
            [LifeStage.youngSheep],
            [LifeStage.ewe],
            [LifeStage.ram],
          ],
          Species.pig => const [
            [LifeStage.piglet],
            [LifeStage.youngPig],
            [LifeStage.sow],
            [LifeStage.boar],
          ],
          Species.poultry => const [
            [LifeStage.chick],
            [LifeStage.pullet],
            [LifeStage.hen],
            [LifeStage.rooster],
          ],
          Species.canine => const [
            [LifeStage.puppy],
            [LifeStage.youngDog],
            [LifeStage.workingDog],
            [LifeStage.guardDog],
          ],
          Species.feline => const [
            [LifeStage.cat],
          ],
          Species.other => const [
            [LifeStage.unknown],
          ],
          null => const <List<LifeStage>>[],
        };

  return [
    for (final stages in configuredGroups)
      if (stages.any((stage) => (counts[stage] ?? 0) > 0))
        _AnimalStageGroup(
          stages.where((stage) => (counts[stage] ?? 0) > 0).toList(),
          stages.map((stage) => stage.displayName).toSet().join(' / '),
          stages.fold<int>(0, (sum, stage) => sum + (counts[stage] ?? 0)),
        ),
  ];
}
