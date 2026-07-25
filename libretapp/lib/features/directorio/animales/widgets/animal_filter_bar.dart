/// features \u203a directorio \u203a animales \u203a widgets \u203a animal_filter_bar \u2014 inline filter bar for the animal list.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_palette.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/app_theme.dart';

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

    final chips = AnimalTaxonomy.filterStageGroups()
        .map(
          (stages) => _StageChipConfig(
            _stageGroupLabel(stages),
            stages,
          ),
        )
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: l10n.animalsSearchHint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: AppColors.accent),
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
                borderSide: const BorderSide(color: AppColors.accent, width: 2),
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
                  const Icon(
                    Icons.visibility,
                    size: 18,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Switch(
                    value: onlyAttention,
                    onChanged: onAttentionChanged,
                    activeThumbColor: AppColors.accent,
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
            children: chips.map((cfg) => _buildStageChip(context, cfg)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStageChip(BuildContext context, _StageChipConfig config) {
    final isSelected = config.stages.any(selectedStages.contains);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AnimalPalette.filterChipBackground(
      isSelected: isSelected,
      isDark: isDark,
    );
    final foregroundColor = AnimalPalette.filterChipForeground(
      isSelected: isSelected,
      isDark: isDark,
    );
    final borderColor = AnimalPalette.filterChipBorder(
      isSelected: isSelected,
      isDark: isDark,
    );

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
      backgroundColor: backgroundColor,
      selectedColor: backgroundColor,
      side: BorderSide(color: borderColor),
      labelStyle: TextStyle(
        color: foregroundColor,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
      ),
      showCheckmark: false,
    );
  }
}

class _StageChipConfig {
  _StageChipConfig(this.label, this.stages);

  final String label;
  final List<LifeStage> stages;
}

String _stageGroupLabel(List<LifeStage> stages) {
  if (stages.length == 1) return stages.first.displayName;
  return stages.map((stage) => stage.displayName).toSet().join(' / ');
}
