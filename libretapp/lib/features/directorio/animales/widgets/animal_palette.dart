/// features \u203a directorio \u203a animales \u203a widgets \u203a animal_palette \u2014 colour palette chooser for animals.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/theme/app_theme.dart';

/// Centralized stage colors for animal UI components.
class AnimalPalette {
  static const Color cattle = Color(0xFF2F7D46);
  static const Color equine = Color(0xFF2E6FA3);
  static const Color goat = Color(0xFF7B58A6);
  static const Color sheep = Color(0xFFC89452);
  static const Color pig = Color(0xFFD66B73);
  static const Color poultry = Color(0xFFE18B2D);
  static const Color canine = Color(0xFF59616B);

  static const Color calf = AppColors.amber;
  static const Color heifer = AppColors.earth;
  static const Color cow = Color(0xFF9C6F52);
  static const Color bull = AppColors.secondary;
  static const Color youngBull = Color(0xFF5A8DA3);
  static const Color steer = AppColors.primary;
  static const Color horse = Color(0xFF9F6B3D);
  static const Color donkey = Color(0xFF7A828C);
  static const Color mule = AppColors.accent;
  static const Color grower = Color(0xFF7B9287);
  static const Color fattening = Color(0xFFB77957);
  static const Color production = Color(0xFF4F8C65);
  static const Color reproduction = Color(0xFFC06A6A);
  static const Color work = Color(0xFF4D7EA8);
  static const Color guard = Color(0xFF4F5964);

  static Color speciesColor(Species species) {
    switch (species) {
      case Species.cattle:
        return cattle;
      case Species.equine:
        return equine;
      case Species.goat:
        return goat;
      case Species.sheep:
        return sheep;
      case Species.pig:
        return pig;
      case Species.poultry:
        return poultry;
      case Species.canine:
        return canine;
      case Species.other:
        return AppColors.secondary;
    }
  }

  static Color categoryColor(Category category) {
    switch (category) {
      case Category.calf:
      case Category.juvenile:
        return calf;
      case Category.weaned:
      case Category.grower:
        return grower;
      case Category.heifer:
        return heifer;
      case Category.youngBull:
        return youngBull;
      case Category.steer:
      case Category.fattening:
        return fattening;
      case Category.cow:
      case Category.production:
        return production;
      case Category.bull:
      case Category.reproduction:
        return reproduction;
      case Category.oxen:
      case Category.work:
        return work;
      case Category.guard:
        return guard;
      case Category.other:
        return AppColors.secondary;
    }
  }

  static Color stageColor(LifeStage stage) {
    return categoryColor(AnimalTaxonomy.categoryForStage(stage));
  }

  /// Unified forest-sage chrome for animal cards and filter chips.
  static const uiAccent = AppColors.primary;
  static const uiAccentDark = Color(0xFF1F3A32);
  static Color get cardHeaderLight => LightColors.cardSurface;
  static Color get cardFooterLight => LightColors.background;
  static Color get avatarBackgroundLight => Color.alphaBlend(
    AppColors.primary.withValues(alpha: 0.05),
    LightColors.background,
  );
  static const cardBorderLight = Color(0xFFE4D8C9);
  static const cardDividerLight = Color(0xFFEDE2D3);
  static const cardTextPrimaryLight = Color(0xFF1F3A32);
  static const cardTextSecondaryLight = Color(0xFF4A6359);

  static Color cardHeader(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Color.alphaBlend(
        Colors.white.withValues(alpha: 0.04),
        Theme.of(context).colorScheme.surface,
      );
    }
    return cardHeaderLight;
  }

  static Color cardFooter(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Color.alphaBlend(
        Colors.white.withValues(alpha: 0.025),
        Theme.of(context).colorScheme.surface,
      );
    }
    return cardFooterLight;
  }

  static Color cardTextPrimary(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Theme.of(context).colorScheme.onSurface;
    }
    return cardTextPrimaryLight;
  }

  static Color cardTextSecondary(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.76);
    }
    return cardTextSecondaryLight;
  }

  static Color cardDivider(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Theme.of(context).colorScheme.outlineVariant.withValues(
        alpha: 0.42,
      );
    }
    return cardDividerLight;
  }

  static Color cardBorder(BuildContext context, {required bool isSelected}) {
    if (isSelected) return uiAccent.withValues(alpha: 0.95);
    if (Theme.of(context).brightness == Brightness.dark) {
      return Theme.of(context).colorScheme.outlineVariant.withValues(
        alpha: 0.38,
      );
    }
    return cardBorderLight.withValues(alpha: 0.85);
  }

  static Color filterChipBackground({
    required bool isSelected,
    required bool isDark,
  }) {
    if (isSelected) return uiAccent;
    if (isDark) return uiAccent.withValues(alpha: 0.16);
    return LightColors.cardSurface;
  }

  static Color filterChipForeground({
    required bool isSelected,
    required bool isDark,
  }) {
    if (isSelected) return Colors.white;
    return isDark
        ? const Color(0xFFB8CFC4)
        : uiAccentDark.withValues(alpha: 0.88);
  }

  static Color filterChipBorder({
    required bool isSelected,
    required bool isDark,
  }) {
    if (isSelected) return uiAccent;
    return isDark
        ? uiAccent.withValues(alpha: 0.35)
        : cardBorderLight.withValues(alpha: 0.95);
  }

  /// Outlined+tint chips on animal cards.
  static const breedChipAccent = uiAccent;
  static const purposeChipFrame = AppColors.accent;
  static const summaryChipText = cardTextSecondaryLight;

  /// Subdued chip chrome — blends with card header/footer.
  static Color summaryChipAccent(BuildContext context) {
    return cardTextSecondary(context);
  }

  static Color purposeTextColor(ProductionPurpose purpose) {
    switch (purpose) {
      case ProductionPurpose.breeding:
        return const Color(0xFF9C6B46);
      case ProductionPurpose.meat:
        return const Color(0xFFC98A2E);
      case ProductionPurpose.dairy:
        return const Color(0xFF7E9FB5);
      case ProductionPurpose.work:
        return const Color(0xFF7B838C);
      case ProductionPurpose.dual:
        return const Color(0xFF8E5B5B);
      case ProductionPurpose.companion:
      case ProductionPurpose.undefined:
      case ProductionPurpose.other:
        return purposeChipFrame;
    }
  }

  /// Purpose label tint — recognizable but quieter than full purpose colors.
  static Color purposeSummaryTextColor(ProductionPurpose purpose) {
    return Color.lerp(
          purposeTextColor(purpose),
          summaryChipText,
          0.52,
        ) ??
        summaryChipText;
  }
}
