import 'dart:io';
import 'dart:math' show max;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/detail_helpers.dart';
import 'package:libretapp/l10n/app_localizations.dart';

// ── Constants ───────────────────────────────────────────────────────────
const double _kExpandedHeight = 175.0;
const double _kPhotoExpanded = 76.0;
const double _kPhotoCollapsed = 32.0;
const double _kRadiusExpanded = 20.0;
const double _kNameExpandedFont = 18.0;
const double _kNameCollapsedFont = 16.0;

/// Collapsible header delegate used inside a [SliverAppBar.flexibleSpace].
/// Uses a single avatar+name widget that morphs position and size while
/// collapsing, avoiding jumps between separate expanded/collapsed widgets.
class CollapsibleAnimalHeader extends StatelessWidget {
  const CollapsibleAnimalHeader({super.key, required this.animal});

  final AnimalEntity animal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stageColor = detailStageColor(animal.lifeStage);
    final riskColor = detailColorFromHex(animal.riskLevel.hexColor);
    final healthColor = detailColorFromHex(animal.healthStatus.hexColor);
    final asset = stageAsset(animal.lifeStage);
    final sexoSymbol = animal.sex == Sex.male ? '♂' : '♀';
    final hasPhoto =
        animal.profilePhoto != null && animal.profilePhoto!.isNotEmpty;

    return LayoutBuilder(
      builder: (context, _) {
        // Read the FlexibleSpaceBarSettings ancestor to frive collapse %.
        final settings = context
            .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
        final double t; // 0 = expanded, 1 = collapsed
        if (settings != null) {
          final deltaExtent = settings.maxExtent - settings.minExtent;
          t = deltaExtent > 0
              ? (1.0 -
                        (settings.currentExtent - settings.minExtent) /
                            deltaExtent)
                    .clamp(0.0, 1.0)
              : 0.0;
        } else {
          t = 0.0;
        }

        // ── Derived values ──────────────────────────────────────────────
        final tPosition = Curves.easeInOutCubic.transform(t);
        final tSize = Curves.easeOutCubic.transform(t);
        final tFastFade = Curves.easeInOut.transform(
          ((t - 0.02) / 0.5).clamp(0.0, 1.0),
        );
        final tSubtitleFade = Curves.easeInOutCubic.transform(
          ((t - 0.05) / 0.46).clamp(0.0, 1.0),
        );
        final tChipFade = Curves.easeInOutCubic.transform(
          ((t - 0.06) / 0.58).clamp(0.0, 1.0),
        );

        final safeTop = MediaQuery.paddingOf(context).top;
        final photoSize = lerpDouble(_kPhotoExpanded, _kPhotoCollapsed, tSize)!;
        final photoRadius = lerpDouble(_kRadiusExpanded, photoSize / 2, tSize)!;
        final titleFontSize = lerpDouble(
          _kNameExpandedFont,
          _kNameCollapsedFont,
          tSize,
        )!;
        final badgeOpacity = (1.0 - tFastFade).clamp(0.0, 1.0);
        final subtitleOpacity = (1.0 - tSubtitleFade).clamp(0.0, 1.0);
        final chipOpacity = (1.0 - tChipFade).clamp(0.0, 1.0);
        final subtitleText =
            '${l10n.labelEarTag}: ${animal.earTagNumber} · ${animal.lifeStage.displayName}';
        final displayName = (() {
          final customName = animal.customName?.trim();
          if (customName != null && customName.isNotEmpty) return customName;
          final visualId = animal.visualId?.trim();
          if (visualId != null && visualId.isNotEmpty) return visualId;
          return animal.earTagNumber;
        })();
        final borderRadius = _kRadiusExpanded * (1.0 - t);

        // Start under toolbar in expanded mode, end next to back arrow.
        final startX = 15.0;
        final endX = 70.0;
        final startY = safeTop + kToolbarHeight + 28;
        final endY = safeTop + (kToolbarHeight - photoSize) / 2;
        final rowX = lerpDouble(startX, endX, tPosition)!;
        final rowY = lerpDouble(startY, endY, tPosition)!;
        final double rowTop = max(safeTop + 8.0, rowY - 35).toDouble();
        final rowRight = lerpDouble(16.0, 106.0, tPosition)!;

        // ── Gradient background ─────────────────────────────────────────
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [stageColor, stageColor.withValues(alpha: 0.85)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(borderRadius),
              bottomRight: Radius.circular(borderRadius),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: rowX,
                right: rowRight,
                top: rowTop,
                child: Row(
                  children: [
                    _AnimalPhoto(
                      size: photoSize,
                      radius: photoRadius,
                      stageColor: stageColor,
                      asset: asset,
                      hasPhoto: hasPhoto,
                      photoPath: animal.profilePhoto,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: titleFontSize,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitleOpacity > 0) ...[
                            SizedBox(height: 4 * subtitleOpacity),
                            Opacity(
                              opacity: subtitleOpacity,
                              child: Text(
                                subtitleText,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (chipOpacity > 0) ...[
                      const SizedBox(width: 6),
                      Opacity(
                        opacity: chipOpacity,
                        child: BadgeChip(
                          label: '${animal.sex.displayName} $sexoSymbol',
                          color: Colors.white.withValues(alpha: 0.96),
                          textColor: stageColor.withValues(alpha: 0.95),
                          borderColor: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (badgeOpacity > 0)
                Positioned(
                  left: 100,
                  right: 24,
                  top: safeTop + kToolbarHeight + _kPhotoExpanded - 6,
                  child: Opacity(
                    opacity: badgeOpacity,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        BadgeChip(
                          label:
                              '${l10n.animalHealth}: ${animal.healthStatus.displayName}',
                          color: Colors.white.withValues(alpha: 0.14),
                          textColor: Colors.white,
                          borderColor: healthColor,
                        ),
                        BadgeChip(
                          label: l10n.animalRisk(animal.riskLevel.displayName),
                          color: Colors.white.withValues(alpha: 0.14),
                          textColor: Colors.white,
                          borderColor: riskColor,
                        ),
                        if (animal.requiresAttention)
                          BadgeChip(
                            label: l10n.animalRequiresAttention,
                            color: Colors.red.withValues(alpha: 0.14),
                            textColor: Colors.white,
                            borderColor: Colors.red,
                          ),
                        if (animal.underObservation)
                          BadgeChip(
                            label: l10n.animalUnderObservation,
                            color: Colors.orange.withValues(alpha: 0.14),
                            textColor: Colors.white,
                            borderColor: Colors.orange,
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// The expanded height the [SliverAppBar] should use.
double get animalHeaderExpandedHeight => _kExpandedHeight;

// ── Private helpers ─────────────────────────────────────────────────────

class _AnimalPhoto extends StatelessWidget {
  const _AnimalPhoto({
    required this.size,
    required this.radius,
    required this.stageColor,
    required this.asset,
    required this.hasPhoto,
    this.photoPath,
  });

  final double size;
  final double radius;
  final Color stageColor;
  final String asset;
  final bool hasPhoto;
  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(max(0, radius - 2)),
            child: SizedBox(
              width: size,
              height: size,
              child: hasPhoto
                  ? Image.file(
                      File(photoPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _assetFallback(),
                    )
                  : _assetFallback(),
            ),
          ),
          if (size > 64)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF56D27A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _assetFallback() {
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) =>
          Icon(Icons.pets, size: size * 0.45, color: stageColor),
    );
  }
}

class BadgeChip extends StatelessWidget {
  const BadgeChip({
    super.key,
    required this.label,
    required this.color,
    this.textColor = Colors.black,
    this.borderColor,
  });

  final String label;
  final Color color;
  final Color textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
