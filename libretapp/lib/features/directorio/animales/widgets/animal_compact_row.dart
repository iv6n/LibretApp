/// Two-line directory presentation with identification and urgent information.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

import 'animal_card.dart' show AnimalCardMenuAction, AnimalQuickMenu;
import 'animal_card_presentation.dart';
import 'animal_palette.dart';

class AnimalCompactRow extends StatelessWidget {
  const AnimalCompactRow({
    super.key,
    required this.animal,
    this.location,
    this.indicatorSnapshot,
    this.onTap,
    this.onLocationTap,
    this.onLongPress,
    this.onMenuAction,
    this.onQuickMenuOpenChanged,
    this.onPrepareQuickMenu,
    this.isSelected = false,
    this.selectionEnabled = false,
  });

  final AnimalEntity animal;
  final LocationEntity? location;
  final AnimalIndicatorSnapshot? indicatorSnapshot;
  final VoidCallback? onTap;
  final VoidCallback? onLocationTap;
  final VoidCallback? onLongPress;
  final ValueChanged<AnimalCardMenuAction>? onMenuAction;
  final ValueChanged<bool>? onQuickMenuOpenChanged;
  final Future<void> Function(BuildContext menuContext)? onPrepareQuickMenu;
  final bool isSelected;
  final bool selectionEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customName = animal.customName?.trim() ?? '';
    final hasName = customName.isNotEmpty;
    final species = animal.species.displayName;
    final identification = animal.earTagNumber.trim().isEmpty
        ? identificationDisplay(animal)
        : '#${animal.earTagNumber.trim()}';
    final title = '$identification · ${hasName ? customName : species}';
    final metadata = [
      if (hasName) species,
      location?.name ?? 'Sin ubicación',
    ].join(' · ');
    final alert = compactAnimalAlert(animal, snapshot: indicatorSnapshot);
    final stageColor = AnimalPalette.categoryColor(animal.category);
    final background = AnimalPalette.cardHeader(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: isSelected
          ? Color.alphaBlend(
              AnimalPalette.uiAccent.withValues(alpha: 0.12),
              background,
            )
          : background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AnimalPalette.cardBorder(context, isSelected: isSelected),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap:
            onTap ??
            () => context.push(AppRoutes.animalDetallePath(animal.uuid)),
        onLongPress: onLongPress,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AnimalPalette.cardTextPrimary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      _CompactMetadata(
                        metadata: metadata,
                        species: hasName ? species : null,
                        alert: alert,
                        onLocationTap: onLocationTap,
                      ),
                    ],
                  ),
                ),
                if (selectionEnabled) ...[
                  const SizedBox(width: 8),
                  SizedBox.square(
                    dimension: 48,
                    child: Center(
                      child: Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? stageColor
                            : theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ] else if (onMenuAction != null) ...[
                  const SizedBox(width: 4),
                  AnimalQuickMenu(
                    stageLabel: animal.lifeStage.displayName,
                    stageColor: stageColor,
                    iconColor: AnimalPalette.cardTextSecondary(context),
                    onSelected: onMenuAction!,
                    onMenuOpenChanged: onQuickMenuOpenChanged,
                    onPrepareQuickMenu: onPrepareQuickMenu,
                    showStageLabel: false,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactMetadata extends StatelessWidget {
  const _CompactMetadata({
    required this.metadata,
    required this.species,
    required this.alert,
    required this.onLocationTap,
  });

  final String metadata;
  final String? species;
  final CompactAnimalAlert? alert;
  final VoidCallback? onLocationTap;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontSize: 12,
      color: AnimalPalette.cardTextSecondary(context),
    );
    Widget metadataText() => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onLocationTap,
      child: Text(
        metadata,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    final warning = alert;
    if (warning == null) return metadataText();
    final colors = animalStatusPillColors(
      isDark: Theme.of(context).brightness == Brightness.dark,
      accentColor: warning.accentColor,
    );
    final warningStyle = style?.copyWith(
      fontWeight: FontWeight.w700,
      color: colors.foreground,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        double measure(String text, TextStyle? textStyle) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: textStyle),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          final width = painter.width;
          painter.dispose();
          return width;
        }

        // The warning keeps its natural width first. Ellipsis removes location
        // before species; at large text sizes metadata yields the whole line.
        final warningWidth = measure(warning.label, warningStyle) + 20;
        final metadataMinimum = species == null
            ? 36.0
            : measure(species!, style);
        final showMetadata =
            constraints.maxWidth >= warningWidth + 8 + metadataMinimum;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showMetadata) ...[
              Expanded(child: metadataText()),
              const SizedBox(width: 8),
            ],
            SizedBox(
              width: math.min(warningWidth, constraints.maxWidth),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(warning.icon, size: 15, color: colors.foreground),
                  const SizedBox(width: 4),
                  Expanded(child: Text(warning.label, style: warningStyle)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
