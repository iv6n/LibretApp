import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_palette.dart';
import 'package:libretapp/l10n/app_localizations.dart';

Future<void> showAnimalFiltersSheet({
  required BuildContext context,
  required Set<LifeStage> selectedStages,
  required bool onlyAttention,
  required ValueChanged<Set<LifeStage>> onStagesChanged,
  required ValueChanged<bool> onAttentionChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: _FiltersContent(
            selectedStages: selectedStages,
            onlyAttention: onlyAttention,
            onStagesChanged: onStagesChanged,
            onAttentionChanged: onAttentionChanged,
          ),
        ),
      );
    },
  );
}

class _FiltersContent extends StatelessWidget {
  const _FiltersContent({
    required this.selectedStages,
    required this.onlyAttention,
    required this.onStagesChanged,
    required this.onAttentionChanged,
  });

  final Set<LifeStage> selectedStages;
  final bool onlyAttention;
  final ValueChanged<Set<LifeStage>> onStagesChanged;
  final ValueChanged<bool> onAttentionChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chips = _buildStageChips(l10n);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.animalsFilters,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.visibility, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.animalsOnlyAttention,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Switch(value: onlyAttention, onChanged: onAttentionChanged),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.animalsStageFilterLabel,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips.map((cfg) => _buildStageChip(cfg)).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  List<_StageChipConfig> _buildStageChips(AppLocalizations l10n) {
    return <_StageChipConfig>[
      _StageChipConfig(l10n.stageFilterCalf, [
        LifeStage.calf,
        LifeStage.calfMale,
        LifeStage.calfFemale,
      ], AnimalPalette.stageColor(LifeStage.calf)),
      _StageChipConfig(l10n.stageFilterHeifer, [
        LifeStage.heifer,
      ], AnimalPalette.stageColor(LifeStage.heifer)),
      _StageChipConfig(l10n.stageFilterYoungBull, [
        LifeStage.youngBull,
      ], AnimalPalette.stageColor(LifeStage.youngBull)),
      _StageChipConfig(l10n.stageFilterSteer, [
        LifeStage.steer,
      ], AnimalPalette.stageColor(LifeStage.steer)),
      _StageChipConfig(l10n.stageFilterCow, [
        LifeStage.cow,
      ], AnimalPalette.stageColor(LifeStage.cow)),
      _StageChipConfig(l10n.stageFilterBull, [
        LifeStage.bull,
      ], AnimalPalette.stageColor(LifeStage.bull)),
      _StageChipConfig(l10n.stageFilterColt, [
        LifeStage.colt,
        LifeStage.filly,
      ], AnimalPalette.stageColor(LifeStage.colt)),
      _StageChipConfig(l10n.stageFilterHorse, [
        LifeStage.horse,
      ], AnimalPalette.stageColor(LifeStage.horse)),
      _StageChipConfig(l10n.stageFilterMare, [
        LifeStage.mare,
      ], AnimalPalette.stageColor(LifeStage.mare)),
      _StageChipConfig(l10n.stageFilterDonkey, [
        LifeStage.donkey,
        LifeStage.donkeyFemale,
      ], AnimalPalette.stageColor(LifeStage.donkey)),
      _StageChipConfig(l10n.stageFilterMule, [
        LifeStage.mule,
      ], AnimalPalette.stageColor(LifeStage.mule)),
    ];
  }

  Widget _buildStageChip(_StageChipConfig config) {
    final isSelected = config.stages.any(selectedStages.contains);
    final color = config.color;
    final labelColor = isSelected ? Colors.white : color.withValues(alpha: 0.9);
    final bgColor = isSelected ? color : color.withValues(alpha: 0.18);

    return FilterChip(
      label: Text(
        config.label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      selected: isSelected,
      onSelected: (selected) {
        final updated = Set<LifeStage>.from(selectedStages);
        if (selected) {
          updated.addAll(config.stages);
        } else {
          updated.removeAll(config.stages);
        }
        onStagesChanged(updated);
      },
      backgroundColor: bgColor,
      selectedColor: bgColor,
      side: BorderSide(color: isSelected ? color : Colors.transparent),
      labelStyle: TextStyle(
        color: labelColor,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
      ),
      showCheckmark: false,
    );
  }
}

class _StageChipConfig {
  const _StageChipConfig(this.label, this.stages, this.color);

  final String label;
  final List<LifeStage> stages;
  final Color color;
}
