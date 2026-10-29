import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_card.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_card_presentation.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_palette.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_photo.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

/// Companion animal card using the same compact structure as [AnimalCard].
class PetCard extends StatelessWidget {
  const PetCard({
    super.key,
    required this.animal,
    this.location,
    this.indicatorSnapshot,
    this.onTap,
    this.onLongPress,
    this.onLocationTap,
    this.onMenuAction,
    this.onQuickMenuOpenChanged,
    this.onPrepareQuickMenu,
    this.isSelected = false,
    this.selectionEnabled = false,
    this.isPreview = false,
  });

  final AnimalEntity animal;
  final LocationEntity? location;

  /// Preserves the grouped directory-card API for mixed animal lists.
  final AnimalIndicatorSnapshot? indicatorSnapshot;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onLocationTap;
  final ValueChanged<AnimalCardMenuAction>? onMenuAction;
  final ValueChanged<bool>? onQuickMenuOpenChanged;
  final Future<void> Function(BuildContext menuContext)? onPrepareQuickMenu;
  final bool isSelected;
  final bool selectionEnabled;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name = (animal.customName ?? '').trim().isNotEmpty
        ? animal.customName!.trim()
        : animal.species.displayName;
    final speciesColor = AnimalPalette.speciesColor(animal.species);
    final breed = animal.breed.trim();
    final illustration = petIllustrationAsset(animal.species);
    final locationName = location?.name;
    final ageLabel = !animal.hasKnownAge
        ? 'Edad sin dato'
        : animal.ageMonths < 12
        ? '${animal.ageMonths} meses'
        : '${animal.ageMonths ~/ 12} años';
    final cardOverlay = theme.brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.035);
    final selectedOverlay = isSelected
        ? AnimalPalette.uiAccent.withValues(alpha: 0.12)
        : Colors.transparent;
    final cardColor = Color.alphaBlend(
      selectedOverlay,
      Color.alphaBlend(cardOverlay, colors.surface),
    );

    return Card(
      key: const ValueKey('pet_card'),
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      color: cardColor,
      elevation: 1.2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AnimalPalette.cardBorder(context, isSelected: isSelected),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: isPreview
            ? null
            : onTap ??
                  () => context.push(AppRoutes.animalDetallePath(animal.uuid)),
        onLongPress: isPreview ? null : onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AnimalPalette.cardHeader(context),
              ),
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
              child: Row(
                children: [
                  Material(
                    elevation: 2.2,
                    shadowColor: colors.shadow.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                    color: AnimalPalette.avatarBackgroundLight,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AnimalPalette.avatarBackgroundLight,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: speciesColor, width: 1.5),
                      ),
                      padding: const EdgeInsets.all(1.5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.5),
                        child: AnimalPhotoImage(
                          path: animal.profilePhoto,
                          fit: BoxFit.cover,
                          fallback: illustration == null
                              ? Icon(
                                  Icons.pets_outlined,
                                  size: 36,
                                  color: speciesColor,
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: AnimalPalette.cardTextPrimary(context),
                                  height: 1.05,
                                ),
                              ),
                            ),
                            if (selectionEnabled)
                              Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isSelected
                                    ? speciesColor
                                    : colors.outline,
                              )
                            else if (!isPreview && onMenuAction != null)
                              AnimalQuickMenu(
                                stageLabel: 'Mascota',
                                stageColor: speciesColor,
                                iconColor: AnimalPalette.cardTextSecondary(
                                  context,
                                ),
                                showStageLabel: false,
                                onSelected: onMenuAction!,
                                onMenuOpenChanged: onQuickMenuOpenChanged,
                                onPrepareQuickMenu: onPrepareQuickMenu,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 5,
                          runSpacing: 3,
                          children: [
                            TagChip(
                              fontSize: 11,
                              label: 'MASCOTA',
                              accentColor: speciesColor,
                              textColor: AnimalPalette.summaryChipText,
                              tintOpacity: 0.10,
                              borderOpacity: 0.28,
                            ),
                            TagChip(
                              fontSize: 11,
                              label: animal.species.displayName.toUpperCase(),
                              accentColor: speciesColor,
                              textColor: AnimalPalette.summaryChipText,
                              tintOpacity: 0.10,
                              borderOpacity: 0.28,
                            ),
                            if (breed.isNotEmpty)
                              TagChip(
                                fontSize: 11,
                                label: breed.toUpperCase(),
                                accentColor: AnimalPalette.summaryChipAccent(
                                  context,
                                ),
                                textColor: AnimalPalette.summaryChipText,
                                tintOpacity: 0.10,
                                borderOpacity: 0.28,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$ageLabel · ${animal.sex.displayName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: 12,
                            color: AnimalPalette.cardTextSecondary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              key: const ValueKey('pet_card_footer'),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AnimalPalette.cardFooter(context),
                border: Border(
                  top: BorderSide(color: AnimalPalette.cardDivider(context)),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  if (locationName?.isNotEmpty == true) ...[
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isPreview ? null : onLocationTap,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 48),
                              child: _FooterInfo(label: locationName!),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                  Flexible(
                    child: Align(
                      alignment: locationName?.isNotEmpty == true
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: _HealthPill(animal: animal),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterInfo extends StatelessWidget {
  const _FooterInfo({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.max,
    children: [
      Icon(
        Icons.place_outlined,
        size: 22,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.82),
      ),
      const SizedBox(width: 2),
      Flexible(
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.82),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

class _HealthPill extends StatelessWidget {
  const _HealthPill({required this.animal});
  final AnimalEntity animal;

  @override
  Widget build(BuildContext context) {
    final neutral = isNeutralAnimalHealthStatus(animal.healthStatus);
    final tint = neutral
        ? Theme.of(context).colorScheme.primary
        : Color(
            int.parse(animal.healthStatus.hexColor.replaceFirst('#', '0xff')),
          );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tint.withValues(alpha: .4)),
      ),
      child: Text(
        animal.healthStatus == HealthStatus.unknown
            ? 'Sin dato'
            : animal.healthStatus.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: tint,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
