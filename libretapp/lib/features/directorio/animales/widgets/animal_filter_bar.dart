import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_palette.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class AnimalFilterBar extends StatelessWidget {
  const AnimalFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedStages,
    required this.onlyAttention,
    required this.onSearchChanged,
    required this.onStagesChanged,
    required this.onAttentionChanged,
  });

  final String searchQuery;
  final Set<LifeStage> selectedStages;
  final bool onlyAttention;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Set<LifeStage>> onStagesChanged;
  final ValueChanged<bool> onAttentionChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final chips = <_StageChipConfig>[
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: l10n.animalsSearchHint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: Colors.green),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => onSearchChanged(''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.animalsStageFilterLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.visibility, size: 18, color: Colors.green),
                  const SizedBox(width: 6),
                  Switch(
                    value: onlyAttention,
                    onChanged: onAttentionChanged,
                    activeThumbColor: Colors.green,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.animalsOnlyAttention,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 1),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: chips.map((cfg) => _buildStageChip(cfg)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStageChip(_StageChipConfig config) {
    final isSelected = config.stages.any(selectedStages.contains);
    final color = config.color;

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
      backgroundColor: color.withValues(alpha: 0.12),
      selectedColor: color.withValues(alpha: 0.25),
      side: BorderSide(color: isSelected ? color : Colors.grey[300]!),
      labelStyle: TextStyle(
        color: color,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
      ),
      showCheckmark: false,
    );
  }
}

class _StageChipConfig {
  _StageChipConfig(this.label, this.stages, this.color);

  final String label;
  final List<LifeStage> stages;
  final Color color;
}
