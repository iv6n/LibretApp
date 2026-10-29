library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_photo.dart';
import 'package:libretapp/features/directorio/animales/widgets/detail_helpers.dart';
import 'package:libretapp/theme/app_theme.dart';

/// Allows long identifiers and enlarged text without clipping the profile.
double animalHeaderHeight(BuildContext context) =>
    (MediaQuery.sizeOf(context).height < 720 ? 216 : 236) +
    (MediaQuery.textScalerOf(context).scale(16) / 16 - 1).clamp(0, 1) * 136;

class CollapsibleAnimalHeader extends StatelessWidget {
  const CollapsibleAnimalHeader({super.key, required this.animal});
  final AnimalEntity animal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
    final illustration = petIllustrationAsset(animal.species);
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
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            else
              Positioned(
                top: safeTop + kToolbarHeight + AppSpacing.sm,
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
                                ? illustration == null
                                      ? 'Sin fotografía de $name'
                                      : 'Ilustración de $name'
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
                                  width: 80,
                                  height: 80,
                                  child: ColoredBox(
                                    color: scheme.primaryContainer,
                                    child: AnimalPhotoImage(
                                      path: animal.profilePhoto,
                                      fallback: illustration == null
                                          ? Icon(
                                              Icons.pets_outlined,
                                              size: 40,
                                              color: scheme.onPrimaryContainer,
                                            )
                                          : Image.asset(
                                              illustration,
                                              fit: BoxFit.contain,
                                              excludeFromSemantics: true,
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
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: scheme.onPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '$identification: ${earTagDisplay(animal)}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: scheme.onPrimary),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  '${animal.species.displayName} · ${animal.sex.displayName} · ${animal.hasKnownAge ? formatAge(animal.ageMonths) : 'Sin dato'}',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: scheme.onPrimary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          Material(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                            child: AppChip(
                              label: animal.status.displayName,
                              tone: animal.status.isInActiveHerd
                                  ? AppChipTone.success
                                  : AppChipTone.neutral,
                            ),
                          ),
                          if (animal.requiresAttention)
                            Material(
                              color: scheme.surface,
                              borderRadius: BorderRadius.circular(AppRadii.sm),
                              child: const AppChip(
                                label: 'Requiere atención',
                                tone: AppChipTone.warning,
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
