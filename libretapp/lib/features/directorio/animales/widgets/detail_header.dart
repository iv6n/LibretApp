library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_photo.dart';
import 'package:libretapp/features/directorio/animales/widgets/detail_helpers.dart';
import 'package:libretapp/theme/app_theme.dart';

/// Keeps the identity visible while allowing larger labels to grow naturally.
double animalHeaderHeight(BuildContext context, AnimalEntity animal) {
  final scale = (MediaQuery.textScalerOf(context).scale(16) / 16 - 1).clamp(
    0.0,
    1.0,
  );
  final name = primaryAnimalLabel(animal);
  final identifier = earTagDisplay(animal);
  return 192 +
      scale * 144 +
      (name.length > 20 ? 24 : 0) +
      (identifier.length > 24 ? 16 : 0) +
      (animal.requiresAttention ? 28 : 0);
}

class CollapsibleAnimalHeader extends StatelessWidget {
  const CollapsibleAnimalHeader({super.key, required this.animal});
  final AnimalEntity animal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<AppStatusTheme>();
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final delta = settings == null
        ? 0.0
        : settings.maxExtent - settings.minExtent;
    final collapse = delta <= 0
        ? 0.0
        : (1 - (settings!.currentExtent - settings.minExtent) / delta).clamp(
            0.0,
            1.0,
          );
    final compact = collapse > 0.6;
    final name = primaryAnimalLabel(animal);
    final identification = AnimalRegistrationPolicy.forSpecies(
      animal.species,
    ).identificationLabel;
    final identificationValue = earTagDisplay(animal);
    final shortIdentification = animal.species == Species.cattle
        ? 'Arete $identificationValue'
        : '$identification: $identificationValue';
    final showIdentification =
        identificationValue != 'Sin identificación' &&
        identificationValue != name;
    final facts = <String>[
      animal.species.displayName,
      if (animal.sex != Sex.unknown) animal.sex.displayName,
      if (animal.hasKnownAge) formatAge(animal.ageMonths),
    ];
    final illustration =
        petIllustrationAsset(animal.species) ?? stageAsset(animal.lifeStage);
    Widget illustrationPlaceholder() => Icon(
      Icons.pets_outlined,
      size: 32,
      color: scheme.onPrimaryContainer,
    );
    final safeTop = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: scheme.primary,
      child: ClipRect(
        child: Stack(
          children: [
            if (compact)
              Positioned(
                top: safeTop,
                bottom: 0,
                left: 56,
                right: 104,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      if (animal.requiresAttention) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Tooltip(
                          message: 'Requiere atención',
                          child: Icon(
                            Icons.warning_amber_rounded,
                            size: 20,
                            color: scheme.onPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else
              Positioned(
                top: safeTop + kToolbarHeight + AppSpacing.xs,
                left: AppSpacing.md,
                right: AppSpacing.md,
                child: Opacity(
                  opacity: (1 - collapse / 0.6).clamp(0.0, 1.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            button: (animal.profilePhoto ?? '')
                                .trim()
                                .isNotEmpty,
                            label: (animal.profilePhoto ?? '').trim().isEmpty
                                ? 'Ilustración de $name'
                                : 'Fotografía de $name',
                            child: InkWell(
                              onTap: (animal.profilePhoto ?? '').trim().isEmpty
                                  ? null
                                  : () => showAnimalPhoto(
                                      context,
                                      path: animal.profilePhoto,
                                      name: name,
                                    ),
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.lg,
                                ),
                                child: SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: ColoredBox(
                                    color: scheme.primaryContainer,
                                    child: AnimalPhotoImage(
                                      path: animal.profilePhoto,
                                      fallback: Image.asset(
                                        illustration,
                                        fit: BoxFit.contain,
                                        excludeFromSemantics: true,
                                        frameBuilder:
                                            (
                                              context,
                                              child,
                                              frame,
                                              wasSynchronouslyLoaded,
                                            ) =>
                                                wasSynchronouslyLoaded ||
                                                    frame != null
                                                ? child
                                                : illustrationPlaceholder(),
                                        errorBuilder: (_, _, _) =>
                                            illustrationPlaceholder(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: scheme.onPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                if (showIdentification) ...[
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    shortIdentification,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: scheme.onPrimary),
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  facts.join(' · '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: scheme.onPrimary),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Wrap(
                                  spacing: AppSpacing.xs,
                                  runSpacing: AppSpacing.xs,
                                  children: [
                                    _HeaderStatusPill(
                                      label: animal.status.displayName,
                                      color: animal.status.isInActiveHerd
                                          ? (statusColors?.success ??
                                                AppColors.success)
                                          : scheme.onSurfaceVariant,
                                    ),
                                    if (animal.requiresAttention)
                                      _HeaderStatusPill(
                                        label: 'Requiere atención',
                                        color:
                                            statusColors?.warning ??
                                            AppColors.warning,
                                        icon: Icons.warning_amber_rounded,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStatusPill extends StatelessWidget {
  const _HeaderStatusPill({
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
