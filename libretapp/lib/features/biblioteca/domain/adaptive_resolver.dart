/// features > biblioteca > domain > adaptive_resolver — resolves which
/// regional adaptation box and task tips to show for a chapter, given the
/// reader's profile.
///
/// Precedence follows the content repo's ADAPTIVE_CONTENT.md exactly:
/// 1. exact state match
/// 2. climate region match
/// 3. production setting match
/// 4. general fallback
///
/// Chapter text itself is always shown as-is; this only decides which
/// additive adaptation box (if any) accompanies it.
library;

import 'package:libretapp/features/biblioteca/data/book_content.dart';

class ReaderProfile {
  const ReaderProfile({
    required this.state,
    required this.climateRegions,
    required this.productionSetting,
  });

  static const general = ReaderProfile(
    state: 'general',
    climateRegions: ['general'],
    productionSetting: 'general',
  );

  final String state;
  final List<String> climateRegions;
  final String productionSetting;
}

class AdaptiveResolver {
  const AdaptiveResolver();

  /// Picks the single best-matching [AdaptationEntry] for a chapter, or
  /// `null` if the chapter has no adaptations at all.
  AdaptationEntry? resolveAdaptation(
    ChapterAdaptations chapter,
    ReaderProfile profile,
  ) {
    if (chapter.adaptations.isEmpty) return null;

    for (final entry in chapter.adaptations) {
      if (entry.states.contains(profile.state)) return entry;
    }
    for (final region in profile.climateRegions) {
      for (final entry in chapter.adaptations) {
        if (entry.regions.contains(region)) return entry;
      }
    }
    for (final entry in chapter.adaptations) {
      if (entry.productionSettings.contains(profile.productionSetting)) {
        return entry;
      }
    }
    for (final entry in chapter.adaptations) {
      if (entry.states.contains('general') || entry.regions.contains('general')) {
        return entry;
      }
    }
    return chapter.adaptations.first;
  }

  /// Relevance-filters task tips for a chapter: a tip counts as relevant if
  /// it applies to the reader's state, any of their climate regions, their
  /// production setting, or is scoped generally (no states/regions/settings
  /// declared at all).
  List<TaskTip> resolveTaskTips(
    List<TaskTip> chapterTips,
    ReaderProfile profile,
  ) {
    return chapterTips.where((tip) {
      final scope = tip.appliesTo;
      final isGeneral =
          scope.states.isEmpty &&
          scope.regions.isEmpty &&
          scope.productionSettings.isEmpty;
      if (isGeneral) return true;
      if (scope.states.contains(profile.state)) return true;
      if (scope.regions.any(profile.climateRegions.contains)) return true;
      if (scope.productionSettings.contains(profile.productionSetting)) {
        return true;
      }
      return false;
    }).toList(growable: false);
  }
}
