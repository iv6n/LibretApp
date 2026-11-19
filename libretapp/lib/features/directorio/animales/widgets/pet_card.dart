import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/widgets/app_directory_layout.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_avatar.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_card.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_card_presentation.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_directory_header.dart';
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
    final name = (animal.customName ?? '').trim().isNotEmpty
        ? animal.customName!.trim()
        : animal.species.displayName;
    final speciesColor = AnimalPalette.speciesColor(animal.species);
    final breed = animal.breed.trim();
    final showBreed =
        breed.isNotEmpty &&
        breed.toLowerCase() != 'desconocido' &&
        breed.toLowerCase() != 'sin dato' &&
        breed.toLowerCase() != animal.species.displayName.toLowerCase();
    final illustration = petIllustrationAsset(animal.species);
    final locationName = location?.name;
    final ageLabel = !animal.hasKnownAge
        ? null
        : animal.ageMonths < 12
        ? '${animal.ageMonths} mes${animal.ageMonths == 1 ? '' : 'es'}'
        : '${animal.ageMonths ~/ 12} año${animal.ageMonths ~/ 12 == 1 ? '' : 's'}';
    final indicators =
        indicatorsFor(animal, snapshot: indicatorSnapshot, maxIndicators: 12)
            .where(
              (indicator) => switch (indicator.kind) {
                PurposeIndicatorKind.age ||
                PurposeIndicatorKind.healthState ||
                PurposeIndicatorKind.definePurpose => false,
                _ => true,
              },
            )
            .take(3)
            .toList();
    final healthAlert = animalHealthAlert(animal);
    final selectedOverlay = isSelected
        ? AnimalPalette.uiAccent.withValues(alpha: 0.12)
        : Colors.transparent;
    final cardColor = Color.alphaBlend(
      selectedOverlay,
      AnimalPalette.cardSurface,
    );

    return AppDirectoryCardFrame(
      key: const ValueKey('pet_card'),
      color: cardColor,
      borderColor: AnimalPalette.cardBorder(context, isSelected: isSelected),
      borderWidth: isSelected ? 1.5 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDirectoryCardFrame.cornerRadius),
        onTap: isPreview
            ? null
            : onTap ??
                  () => context.push(AppRoutes.animalDetallePath(animal.uuid)),
        onLongPress: isPreview ? null : onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimalDirectoryHeader(
              avatar: AnimalAvatar(
                borderColor: speciesColor,
                photoPath: animal.profilePhoto,
                fallback: illustration == null
                    ? Icon(
                        Icons.pets_outlined,
                        size: AppDirectoryMetrics.of(context).avatarIconSize,
                        color: speciesColor,
                      )
                    : Image.asset(
                        illustration,
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
              ),
              title: name,
              age: ageLabel,
              stage: 'Mascota',
              stageColor: speciesColor,
              titleFontSize: AppDirectoryMetrics.of(context).petNameFontSize,
              selected: selectionEnabled ? isSelected : null,
              menu: !isPreview && !selectionEnabled && onMenuAction != null
                  ? AnimalQuickMenu(
                      stageLabel: 'Mascota',
                      stageColor: speciesColor,
                      iconColor: AnimalPalette.cardTextSecondary(context),
                      showStageLabel: false,
                      dense: true,
                      onSelected: onMenuAction!,
                      onMenuOpenChanged: onQuickMenuOpenChanged,
                      onPrepareQuickMenu: onPrepareQuickMenu,
                    )
                  : null,
              chips: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  TagChip(
                    label: animal.species.displayName.toUpperCase(),
                    accentColor: speciesColor,
                    textColor: AnimalPalette.cardTextPrimary(context),
                    fontSize: 11,
                    tintOpacity: 0.18,
                    borderOpacity: 0.14,
                    useProvidedTextColorInDark: true,
                  ),
                  if (showBreed)
                    TagChip(
                      label: breed.toUpperCase(),
                      accentColor: AnimalPalette.breedChipAccent,
                      textColor: AnimalPalette.cardTextPrimary(context),
                      fontSize: 11,
                      tintOpacity: 0.18,
                      borderOpacity: 0.14,
                      useProvidedTextColorInDark: true,
                    ),
                ],
              ),
            ),
            AnimalDirectoryCardFooter(
              key: const ValueKey('pet_card_footer'),
              locationLabel: locationName?.trim().isNotEmpty == true
                  ? locationName!.trim()
                  : 'Sin ubicación',
              onLocationTap:
                  isPreview || locationName?.trim().isNotEmpty != true
                  ? null
                  : onLocationTap,
              indicators: indicators,
              purpose: animal.productionPurpose,
              healthAlert: healthAlert,
              isPet: true,
              petSexLabel: animal.sex == Sex.unknown
                  ? null
                  : animal.sex.displayName,
            ),
          ],
        ),
      ),
    );
  }
}
