/// features \u203a directorio \u203a animales \u203a widgets \u203a animal_card \u2014 reusable animal card widget.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/widgets/app_directory_layout.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_avatar.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_photo.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_palette.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_card_presentation.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_directory_header.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/l10n/app_localizations.dart';

enum AnimalCardMenuAction {
  viewDetail,
  edit,
  registerWeight,
  registerHealth,
  delete,
}

class AnimalCard extends StatelessWidget {
  const AnimalCard({
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
    this.isPreview = false,
  });

  final AnimalEntity animal;
  final LocationEntity? location;

  /// Record-derived figures for this animal. When null the card falls back to
  /// the denormalized fields on the entity.
  final AnimalIndicatorSnapshot? indicatorSnapshot;
  final VoidCallback? onTap;
  final VoidCallback? onLocationTap;
  final VoidCallback? onLongPress;
  final ValueChanged<AnimalCardMenuAction>? onMenuAction;
  final ValueChanged<bool>? onQuickMenuOpenChanged;
  final Future<void> Function(BuildContext menuContext)? onPrepareQuickMenu;
  final bool isSelected;
  final bool selectionEnabled;

  /// A read-only instance for onboarding and other examples.
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stageColor = AnimalPalette.categoryColor(animal.category);
    final speciesColor = AnimalPalette.speciesColor(animal.species);
    final profile = profileVisualFor(animal, speciesColor);
    final stageLabel =
        animal.lifeStage == LifeStage.unknown || animal.species.isCompanion
        ? animal.species.displayName
        : animal.lifeStage.displayName;
    final purposeLabel = purposeChipShortLabel(animal.productionPurpose);
    final showPurpose = animal.productionPurpose != ProductionPurpose.undefined;
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

    final stageAsset = profile.asset;
    final avatarBorderColor = _avatarBorderColor(animal, context);
    final locationLabel = location?.name ?? 'Sin ubicación';
    final hasEarTag = animal.earTagNumber.trim().isNotEmpty;
    final pendingEarTag = hasPendingEarTag(animal);
    final breedLabel = breedSummary(animal, abbreviated: true);
    final identification = hasEarTag ? animal.earTagNumber.trim() : '';
    final usesEarTag =
        AnimalRegistrationPolicy.forSpecies(
          animal.species,
        ).identificationKind ==
        AnimalIdentificationKind.earTag;
    final headerLabel = usesEarTag && hasEarTag
        ? identification
        : primaryAnimalLabel(animal);
    final customName = (animal.customName ?? '').trim();
    final visualId = (animal.visualId ?? '').trim();
    final nameOrAlias = customName.isNotEmpty ? customName : visualId;
    final rawBreed = animal.breed.trim();
    final showBreedChip =
        rawBreed.isNotEmpty &&
        rawBreed.toLowerCase() != 'sin dato' &&
        rawBreed.toLowerCase() != 'desconocido' &&
        rawBreed.toLowerCase() != animal.species.displayName.toLowerCase() &&
        breedLabel.toLowerCase() != 'desconocido' &&
        breedLabel.toLowerCase() != headerLabel.toLowerCase();
    final ageMonths = animal.ageMonths;
    final ageYears = ageMonths ~/ 12;
    final ageRemainderMonths = ageMonths % 12;
    final ageLabel = !animal.hasKnownAge
        ? 'Sin dato'
        : ageYears > 0
        ? ageRemainderMonths == 0
              ? '$ageYears año${ageYears == 1 ? '' : 's'}'
              : '$ageYears año${ageYears == 1 ? '' : 's'} $ageRemainderMonths mes${ageRemainderMonths == 1 ? '' : 'es'}'
        : _ageLabelUnderOneYear(
            birthDate: animal.birthDate,
            ageMonths: ageRemainderMonths,
          );

    final selectedOverlay = isSelected
        ? AnimalPalette.uiAccent.withValues(alpha: 0.12)
        : Colors.transparent;
    final cardColor = Color.alphaBlend(
      selectedOverlay,
      AnimalPalette.cardSurface,
    );
    final headerSecondaryTextColor = AnimalPalette.cardTextSecondary(context);
    final showQuickMenu =
        !isPreview && !selectionEnabled && onMenuAction != null;
    final secondaryLabel = usesEarTag && hasEarTag
        ? (nameOrAlias.isNotEmpty ? nameOrAlias : animal.species.displayName)
        : pendingEarTag
        ? l10n.animalPendingTag
        : null;
    final statusLabel = animal.status == AnimalStatus.active
        ? ''
        : animal.status.displayName.trim();

    return AppDirectoryCardFrame(
      color: cardColor,
      borderColor: AnimalPalette.cardBorder(context, isSelected: isSelected),
      borderWidth: isSelected ? 1.5 : 1,
      margin: const EdgeInsets.only(bottom: 8),
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
                borderColor: avatarBorderColor,
                photoPath: animal.profilePhoto,
                fit: BoxFit.cover,
                fallback: _profileFallback(context, profile, stageAsset),
              ),
              title: headerLabel,
              name: secondaryLabel,
              age: animal.hasKnownAge ? ageLabel : null,
              stage: stageLabel,
              stageColor: stageColor,
              selected: selectionEnabled ? isSelected : null,
              menu: showQuickMenu
                  ? AnimalQuickMenu(
                      stageLabel: stageLabel,
                      stageColor: stageColor,
                      iconColor: headerSecondaryTextColor,
                      showStageLabel: false,
                      onSelected: onMenuAction!,
                      onMenuOpenChanged: onQuickMenuOpenChanged,
                      onPrepareQuickMenu: onPrepareQuickMenu,
                    )
                  : null,
              chips: AnimalIdentityChipRow(
                breedLabel: showBreedChip ? breedLabel.toUpperCase() : null,
                purposeLabel: showPurpose ? purposeLabel.toUpperCase() : null,
                statusLabel: statusLabel.isNotEmpty
                    ? statusLabel.toUpperCase()
                    : null,
                breedAccentColor: AnimalPalette.breedChipAccent,
                breedTextColor: AnimalPalette.cardTextPrimary(context),
                purposeAccentColor: const Color(0xFF9E9485),
                purposeTextColor: const Color(0xFF544639),
                statusAccentColor: AnimalPalette.summaryChipAccent(context),
                statusTextColor: AnimalPalette.summaryChipText,
              ),
            ),
            AnimalDirectoryCardFooter(
              key: const ValueKey('animal_card_footer'),
              locationLabel: locationLabel,
              onLocationTap: isPreview ? null : onLocationTap,
              indicators: indicators,
              purpose: animal.productionPurpose,
              healthAlert: healthAlert,
            ),
          ],
        ),
      ),
    );
  }
}

/// Keeps facts beside the location when they fit, and wraps them below it
/// when the available width or text scale needs more room.
class AnimalCardFooter extends StatelessWidget {
  const AnimalCardFooter({
    super.key,
    this.locationLabel,
    this.onLocationTap,
    required this.indicators,
    required this.purpose,
    this.healthAlert,
    this.identityFact,
  });

  final String? locationLabel;
  final VoidCallback? onLocationTap;
  final List<PurposeIndicator> indicators;
  final ProductionPurpose purpose;
  final CompactAnimalAlert? healthAlert;
  final String? identityFact;

  @override
  Widget build(BuildContext context) {
    if (locationLabel == null &&
        indicators.isEmpty &&
        healthAlert == null &&
        identityFact == null) {
      return const SizedBox.shrink();
    }
    final metrics = AppDirectoryMetrics.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AnimalPalette.cardFooter(context),
        border: Border(
          top: BorderSide(color: AnimalPalette.cardDivider(context)),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: metrics.footerPaddingH),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ordered = _orderedFooterIndicators(indicators, purpose);
          final alert = healthAlert;
          final chipPadding = EdgeInsets.symmetric(
            horizontal: metrics.footerChipPaddingH,
            vertical: TagChip.defaultPadding.vertical,
          );
          final facts = <({Widget widget, double width, String label})>[
            if (identityFact != null)
              (
                widget: TagChip(
                  label: identityFact!,
                  accentColor: AnimalPalette.summaryChipAccent(context),
                  textColor: AnimalPalette.cardTextPrimary(context),
                  fontSize: 11,
                  tintOpacity: 0.10,
                  borderOpacity: 0.28,
                  padding: chipPadding,
                ),
                width: _footerChipWidth(context, identityFact!, chipPadding),
                label: identityFact!,
              ),
            for (final indicator in ordered)
              (
                widget: _indicatorChip(
                  context,
                  indicator,
                  purpose,
                  padding: chipPadding,
                ),
                width: _indicatorChipWidth(context, indicator, chipPadding),
                label: _indicatorDisplayLabel(indicator).toUpperCase(),
              ),
            if (alert != null)
              (
                widget: _StatusPill(
                  icon: alert.icon,
                  label: alert.label,
                  accentColor: alert.accentColor,
                  accessibleLabel: alert.label,
                ),
                width: _statusPillWidth(context, alert),
                label: alert.label,
              ),
          ];
          // The health alert is pinned to the location line so it never floats
          // in the middle of a wrapped run of facts.
          final alertFact = alert == null ? null : facts.removeLast();
          final locationStyle = Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700, fontSize: 12);
          final locationWidth = locationLabel == null
              ? 0.0
              : _measureTextWidth(context, locationLabel!, locationStyle) +
                    metrics.footerIconSize +
                    2;
          final factsWidth =
              facts.fold<double>(0, (width, fact) => width + fact.width) +
              (facts.length > 1 ? (facts.length - 1) * _footerFactSpacing : 0) +
              (alertFact == null
                  ? 0.0
                  : alertFact.width + (facts.isEmpty ? 0 : _footerFactSpacing));
          // Health-critical facts must never be summarised behind `+N`, so a
          // footer carrying them wraps instead of folding.
          final hasPinnedFacts =
              alertFact != null ||
              ordered.any(
                (indicator) => indicator.severity != IndicatorSeverity.neutral,
              );
          final inline =
              locationWidth +
                  factsWidth +
                  (locationLabel != null && facts.isNotEmpty ? 8 : 0) <=
              constraints.maxWidth;
          final factsMaxWidth = inline
              ? constraints.maxWidth - locationWidth - 8
              : constraints.maxWidth;
          final visible = inline || hasPinnedFacts
              ? facts.length
              : _visibleFooterFactCount(
                  widths: [for (final fact in facts) fact.width],
                  maxWidth: factsMaxWidth,
                  badgeWidth: (hidden) =>
                      _footerChipWidth(context, '+$hidden', chipPadding),
                );
          final hiddenFacts = facts.skip(visible).toList();
          final factWidgets = <Widget>[
            for (var index = 0; index < visible; index++)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: facts[index].widget,
              ),
            if (hiddenFacts.isNotEmpty)
              Semantics(
                label: hiddenFacts.map((fact) => fact.label).join('. '),
                child: TagChip(
                  label: '+${hiddenFacts.length}',
                  accentColor: AnimalPalette.summaryChipAccent(context),
                  textColor: AnimalPalette.cardTextPrimary(context),
                  fontSize: 11,
                  tintOpacity: 0.10,
                  borderOpacity: 0.28,
                  padding: chipPadding,
                ),
              ),
          ];
          final location = locationLabel == null
              ? null
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onLocationTap,
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: AppDirectoryMetrics.minTapTarget,
                      ),
                      child: _InlineInfo(
                        icon: Icons.place_outlined,
                        label: locationLabel!,
                      ),
                    ),
                  ),
                );
          if (inline) {
            final inlineFacts = <Widget>[
              ...factWidgets,
              if (alertFact != null) alertFact.widget,
            ];
            return ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppDirectoryMetrics.minTapTarget,
              ),
              child: Row(
                children: [
                  if (location != null)
                    Expanded(child: location)
                  else
                    const Spacer(),
                  if (location != null && inlineFacts.isNotEmpty)
                    const SizedBox(width: 8),
                  for (var index = 0; index < inlineFacts.length; index++) ...[
                    if (index > 0) const SizedBox(width: _footerFactSpacing),
                    inlineFacts[index],
                  ],
                ],
              ),
            );
          }
          // The alert only shares the location line when it leaves the location
          // readable; otherwise it drops to its own right-aligned row.
          final pinAlert =
              alertFact != null &&
              location != null &&
              locationWidth + alertFact.width + 8 <= constraints.maxWidth;
          final hasLeadingRow = location != null || alertFact != null;
          return Padding(
            padding: EdgeInsets.only(top: hasLeadingRow ? 0 : 8, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (location != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: location),
                      if (pinAlert) alertFact.widget,
                    ],
                  ),
                if (!pinAlert && alertFact != null)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                      ),
                      child: alertFact.widget,
                    ),
                  ),
                if (factWidgets.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: hasLeadingRow ? 4 : 0),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      spacing: _footerFactSpacing,
                      runSpacing: _footerFactSpacing,
                      children: factWidgets,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

const double _footerFactSpacing = 4;

/// Reference card footer: symmetric data columns at wide widths and readable
/// wrapped rows on phones.
class AnimalDirectoryCardFooter extends StatelessWidget {
  const AnimalDirectoryCardFooter({
    super.key,
    this.locationLabel,
    this.onLocationTap,
    required this.indicators,
    required this.purpose,
    this.healthAlert,
    this.identityFact,
    this.identityIcon = Icons.pets_outlined,
  });

  final String? locationLabel;
  final VoidCallback? onLocationTap;
  final List<PurposeIndicator> indicators;
  final ProductionPurpose purpose;
  final CompactAnimalAlert? healthAlert;
  final String? identityFact;
  final IconData identityIcon;

  @override
  Widget build(BuildContext context) {
    if (locationLabel == null &&
        indicators.isEmpty &&
        healthAlert == null &&
        identityFact == null) {
      return const SizedBox.shrink();
    }
    final metrics = AppDirectoryMetrics.of(context);
    final ordered = _orderedFooterIndicators(indicators, purpose);
    final isPet = identityFact != null;
    final featuredIndicators = isPet
        ? const <PurposeIndicator>[]
        : ordered
              .where(
                (indicator) => indicator.severity == IndicatorSeverity.neutral,
              )
              .toList()
              .reversed
              .take(2)
              .toList();
    final featuredSet = featuredIndicators.toSet();
    final additionalIndicators = isPet
        ? ordered
        : ordered
              .where(
                (indicator) =>
                    !featuredSet.contains(indicator) &&
                    indicator.severity != IndicatorSeverity.neutral,
              )
              .toList();
    final supplementalFacts = <Widget>[
      for (final indicator in additionalIndicators)
        _indicatorChip(context, indicator, purpose),
      if (healthAlert != null)
        _StatusPill(
          icon: healthAlert!.icon,
          label: healthAlert!.label,
          accentColor: healthAlert!.accentColor,
          accessibleLabel: healthAlert!.label,
        ),
    ];

    Widget location() => Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onLocationTap,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: _InlineInfo(icon: Icons.place_outlined, label: locationLabel!),
        ),
      ),
    );

    Widget identity() =>
        _PetIdentityFact(label: identityFact!, icon: identityIcon);

    Widget metric(PurposeIndicator indicator) =>
        _DirectoryFooterMetric(indicator: indicator);

    Widget divider() => Container(
      width: 1.5,
      height: 32,
      color: AnimalPalette.cardDivider(context),
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AnimalPalette.cardFooter(context),
        border: Border(
          top: BorderSide(color: AnimalPalette.cardDivider(context)),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: metrics.footerPaddingH),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 520;
          final primaryGroups = <Widget>[
            if (locationLabel != null) location(),
            if (isPet) identity(),
            for (final indicator in featuredIndicators) metric(indicator),
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (wide && primaryGroups.length > 1)
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: Row(
                    children: [
                      for (
                        var index = 0;
                        index < primaryGroups.length;
                        index++
                      ) ...[
                        if (index > 0) divider(),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: index == 0 ? 0 : 8,
                            ),
                            child: index == 0 && locationLabel != null
                                ? primaryGroups[index]
                                : Center(child: primaryGroups[index]),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              else ...[
                if (locationLabel != null) location(),
                if (primaryGroups.length > (locationLabel == null ? 0 : 1))
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      if (isPet) identity(),
                      for (final indicator in featuredIndicators)
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth,
                          ),
                          child: metric(indicator),
                        ),
                    ],
                  ),
              ],
              if (supplementalFacts.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(
                    top: wide && primaryGroups.length > 1 ? 4 : 0,
                    bottom: 8,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: _footerFactSpacing,
                    runSpacing: _footerFactSpacing,
                    children: [
                      for (final fact in supplementalFacts)
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth,
                          ),
                          child: fact,
                        ),
                    ],
                  ),
                ),
              if (primaryGroups.isEmpty && supplementalFacts.isEmpty)
                const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

class _DirectoryFooterMetric extends StatelessWidget {
  const _DirectoryFooterMetric({required this.indicator});

  final PurposeIndicator indicator;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 48),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _footerIndicatorIcon(indicator.kind),
          size: AppDirectoryMetrics.of(context).footerIconSize,
          color: AnimalPalette.cardTextPrimary(context),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: TagChip(
            label: _indicatorDisplayLabel(indicator).toUpperCase(),
            accentColor: AnimalPalette.summaryChipAccent(context),
            textColor: AnimalPalette.cardTextPrimary(context),
            fontSize: 12,
            tintOpacity: 0.12,
            borderOpacity: 0.18,
            maxLines: 1,
            useProvidedTextColorInDark: true,
          ),
        ),
      ],
    ),
  );
}

class _PetIdentityFact extends StatelessWidget {
  const _PetIdentityFact({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 48),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 26, color: AnimalPalette.cardTextPrimary(context)),
        const SizedBox(width: 8),
        Flexible(
          child: TagChip(
            label: label,
            accentColor: AnimalPalette.summaryChipAccent(context),
            textColor: AnimalPalette.cardTextPrimary(context),
            fontSize: 13,
            tintOpacity: 0.12,
            borderOpacity: 0.18,
            maxLines: 1,
            useProvidedTextColorInDark: true,
          ),
        ),
      ],
    ),
  );
}

IconData _footerIndicatorIcon(PurposeIndicatorKind kind) => switch (kind) {
  PurposeIndicatorKind.milkPerDay => Icons.local_drink_outlined,
  PurposeIndicatorKind.daysInMilk => Icons.water_drop_outlined,
  PurposeIndicatorKind.daysPregnant ||
  PurposeIndicatorKind.overdueCalving ||
  PurposeIndicatorKind.daysOpen ||
  PurposeIndicatorKind.calvingInterval => Icons.calendar_month_outlined,
  PurposeIndicatorKind.weight ||
  PurposeIndicatorKind.dailyGain => Icons.monitor_weight_outlined,
  PurposeIndicatorKind.careDue ||
  PurposeIndicatorKind.milkWithdrawal => Icons.health_and_safety_outlined,
  _ => Icons.info_outline,
};

/// Number of leading facts that keep the footer on a single line, folding the
/// remaining ones into a `+N` chip.
int _visibleFooterFactCount({
  required List<double> widths,
  required double maxWidth,
  required double Function(int hiddenFacts) badgeWidth,
}) {
  final total = widths.length;
  if (total == 0) return 0;
  for (var visible = total; visible > 0; visible--) {
    final hidden = total - visible;
    var width = 0.0;
    for (var index = 0; index < visible; index++) {
      width += widths[index];
    }
    width += (visible - 1) * _footerFactSpacing;
    if (hidden > 0) width += _footerFactSpacing + badgeWidth(hidden);
    if (width <= maxWidth) return visible;
  }
  return 1;
}

List<PurposeIndicator> _orderedFooterIndicators(
  List<PurposeIndicator> indicators,
  ProductionPurpose purpose,
) {
  final medical = indicators
      .where(
        (indicator) => indicator.kind == PurposeIndicatorKind.milkWithdrawal,
      )
      .toList();
  final ordinary = <({int index, PurposeIndicator indicator})>[];
  for (var index = 0; index < indicators.length; index++) {
    final indicator = indicators[index];
    if (indicator.kind == PurposeIndicatorKind.milkWithdrawal) continue;
    ordinary.add((index: index, indicator: indicator));
  }

  int priority(PurposeIndicatorKind kind) => switch (purpose) {
    ProductionPurpose.meat => switch (kind) {
      PurposeIndicatorKind.dailyGain => 1,
      PurposeIndicatorKind.weight => 2,
      _ => 0,
    },
    ProductionPurpose.dairy => switch (kind) {
      PurposeIndicatorKind.milkPerDay => 3,
      PurposeIndicatorKind.daysPregnant ||
      PurposeIndicatorKind.overdueCalving => 2,
      _ => 0,
    },
    ProductionPurpose.breeding => switch (kind) {
      PurposeIndicatorKind.daysPregnant ||
      PurposeIndicatorKind.overdueCalving => 3,
      PurposeIndicatorKind.daysOpen => 2,
      _ => 0,
    },
    ProductionPurpose.dual => switch (kind) {
      PurposeIndicatorKind.overdueCalving => 5,
      PurposeIndicatorKind.daysPregnant => 4,
      PurposeIndicatorKind.milkPerDay => 3,
      PurposeIndicatorKind.weight => 2,
      PurposeIndicatorKind.dailyGain => 1,
      _ => 0,
    },
    _ => 0,
  };

  ordinary.sort((a, b) {
    final rank = priority(
      a.indicator.kind,
    ).compareTo(priority(b.indicator.kind));
    return rank != 0 ? rank : a.index.compareTo(b.index);
  });
  return [for (final entry in ordinary) entry.indicator, ...medical];
}

double _measureTextWidth(BuildContext context, String text, TextStyle? style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  )..layout();
  return painter.width;
}

double _footerChipWidth(
  BuildContext context,
  String label,
  EdgeInsets padding,
) =>
    _measureTextWidth(
      context,
      label,
      const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
    ) +
    padding.horizontal +
    3;

double _indicatorChipWidth(
  BuildContext context,
  PurposeIndicator indicator,
  EdgeInsets padding,
) => _footerChipWidth(
  context,
  _indicatorDisplayLabel(indicator).toUpperCase(),
  padding,
);

String _indicatorDisplayLabel(PurposeIndicator indicator) =>
    indicator.kind == PurposeIndicatorKind.milkWithdrawal
    ? indicator.label.replaceFirst(RegExp(r' días?$'), 'd')
    : indicator.label;

double _statusPillWidth(BuildContext context, CompactAnimalAlert alert) {
  final style = Theme.of(context).textTheme.labelMedium?.copyWith(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    letterSpacing: 0,
  );
  return _measureTextWidth(context, alert.label, style) + 42;
}

Widget _indicatorChip(
  BuildContext context,
  PurposeIndicator indicator,
  ProductionPurpose purpose, {
  EdgeInsets? padding,
}) {
  final neutral = indicator.severity == IndicatorSeverity.neutral;
  return TagChip(
    label: _indicatorDisplayLabel(indicator).toUpperCase(),
    accentColor: animalIndicatorAccentColor(context, indicator),
    textColor: animalIndicatorTextColor(context, indicator, purpose),
    fontSize: 11,
    tintOpacity: neutral ? 0.10 : 0.16,
    borderOpacity: neutral ? 0.28 : 0.55,
    padding: padding,
    useProvidedTextColorInDark: true,
  );
}

class AnimalQuickMenu extends StatelessWidget {
  const AnimalQuickMenu({
    super.key,
    required this.stageLabel,
    required this.stageColor,
    required this.iconColor,
    required this.onSelected,
    this.onMenuOpenChanged,
    this.onPrepareQuickMenu,
    this.showStageLabel = true,
  });

  final String stageLabel;
  final Color stageColor;
  final Color iconColor;
  final ValueChanged<AnimalCardMenuAction> onSelected;
  final ValueChanged<bool>? onMenuOpenChanged;
  final Future<void> Function(BuildContext menuContext)? onPrepareQuickMenu;
  final bool showStageLabel;

  Future<void> _openMenu(BuildContext context) async {
    onMenuOpenChanged?.call(true);
    try {
      await onPrepareQuickMenu?.call(context);
      if (!context.mounted) return;

      final button = context.findRenderObject() as RenderBox?;
      if (button == null) return;

      // The preparation callback may scroll this card; the context is checked
      // immediately above before resolving its new overlay position.
      // ignore: use_build_context_synchronously
      final overlayContext = Overlay.of(context).context;
      final overlay = overlayContext.findRenderObject() as RenderBox;
      final origin = button.localToGlobal(Offset.zero, ancestor: overlay);
      final menuTop = origin.dy + button.size.height + 2;

      // ignore: use_build_context_synchronously
      final selected = await showMenu<AnimalCardMenuAction>(
        context: context,
        useRootNavigator: true,
        position: RelativeRect.fromRect(
          Rect.fromLTWH(origin.dx, menuTop, button.size.width, 0),
          Offset.zero & overlay.size,
        ),
        items: _buildAnimalCardMenuItems(),
      );

      if (selected != null) {
        onSelected(selected);
      }
    } finally {
      onMenuOpenChanged?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Acciones',
      child: Semantics(
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openMenu(context),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showStageLabel)
                  TagChip(
                    fontSize: 10,
                    label: stageLabel.toUpperCase(),
                    accentColor: stageColor,
                    outlined: false,
                  ),
                Icon(Icons.more_vert, size: 24, color: iconColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<PopupMenuEntry<AnimalCardMenuAction>> _buildAnimalCardMenuItems() {
  return [
    const PopupMenuItem(
      value: AnimalCardMenuAction.viewDetail,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.visibility_outlined, size: 20),
        title: Text('Ver detalle'),
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    ),
    const PopupMenuItem(
      value: AnimalCardMenuAction.edit,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.edit_outlined, size: 20),
        title: Text('Editar'),
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    ),
    const PopupMenuItem(
      value: AnimalCardMenuAction.registerWeight,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.monitor_weight_outlined, size: 20),
        title: Text('Registrar peso'),
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    ),
    const PopupMenuItem(
      value: AnimalCardMenuAction.registerHealth,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.medical_services_outlined, size: 20),
        title: Text('Registrar salud'),
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    ),
    const PopupMenuDivider(),
    PopupMenuItem(
      value: AnimalCardMenuAction.delete,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          Icons.delete_outline,
          size: 20,
          color: Colors.red.shade700,
        ),
        title: Text('Eliminar', style: TextStyle(color: Colors.red.shade700)),
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    ),
  ];
}

/// Species illustration used by [AnimalAvatar] when there is no photo.
Widget _profileFallback(
  BuildContext context,
  AnimalProfileVisual profile,
  String stageAsset,
) {
  final image = Image.asset(
    stageAsset,
    width: double.infinity,
    height: double.infinity,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => Icon(
      profile.fallbackIcon,
      color: profile.color,
      size: AppDirectoryMetrics.of(context).avatarIconSize,
    ),
  );
  final filter = profile.colorFilter;
  if (filter == null) return image;
  return ColorFiltered(colorFilter: filter, child: image);
}

Color _avatarBorderColor(AnimalEntity animal, BuildContext context) {
  if (animal.healthStatus == HealthStatus.critical ||
      animal.riskLevel == RiskLevel.critical) {
    return const Color(0xFFD93A2F);
  }
  if (animal.requiresAttention) {
    return const Color(0xFFE2B100);
  }
  if (animal.underObservation) {
    return const Color(0xFFE1882F);
  }
  return AnimalPalette.speciesColor(animal.species);
}

class _InlineInfo extends StatelessWidget {
  const _InlineInfo({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(
          icon,
          size: AppDirectoryMetrics.of(context).footerIconSize,
          color: AnimalPalette.cardTextPrimary(context),
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AnimalPalette.cardTextPrimary(context),
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    this.accentColor,
    this.accessibleLabel,
  });

  final IconData icon;
  final String label;
  final Color? accentColor;
  final String? accessibleLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = animalStatusPillColors(
      isDark: false,
      accentColor: accentColor,
    );

    return Tooltip(
      message: accessibleLabel ?? label,
      child: Semantics(
        label: accessibleLabel ?? label,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: colors.foreground),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0,
                    color: colors.foreground,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    required this.accentColor,
    this.textColor,
    this.fontSize = 12,
    this.tintOpacity = 0.15,
    this.borderOpacity = 0.72,
    this.outlined = true,
    this.solidAlpha = 0.80,
    this.maxLines,
    this.padding,
    this.useProvidedTextColorInDark = false,
  });

  /// Matches the default chip density; callers that lay chips out on a single
  /// line can tighten it.
  static const EdgeInsets defaultPadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 3.5,
  );

  final String label;
  final Color accentColor;
  final Color? textColor;
  final double fontSize;
  final double tintOpacity;
  final double borderOpacity;
  final bool outlined;
  final double solidAlpha;
  final int? maxLines;
  final EdgeInsets? padding;
  final bool useProvidedTextColorInDark;

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding ?? defaultPadding;
    if (!outlined) {
      final tonedColor = _mutedColor(accentColor, strength: 0.5);
      final luminance = tonedColor.computeLuminance();
      final labelColor = luminance > 0.65 ? Colors.black87 : Colors.white;

      return Container(
        padding: resolvedPadding,
        decoration: BoxDecoration(
          color: tonedColor.withValues(alpha: solidAlpha),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: tonedColor.withValues(alpha: 0.28),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          maxLines: maxLines,
          overflow: maxLines == null
              ? TextOverflow.clip
              : TextOverflow.ellipsis,
          softWrap: maxLines == null,
          style: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w800,
            fontSize: fontSize,
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final labelColor =
        theme.brightness == Brightness.dark && !useProvidedTextColorInDark
        ? theme.colorScheme.onSurface
        : textColor ?? accentColor;

    return Container(
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: tintOpacity),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: borderOpacity),
          width: 1,
        ),
      ),
      child: Text(
        label,
        maxLines: maxLines,
        overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
        softWrap: maxLines == null,
        style: TextStyle(
          color: labelColor,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

/// Keeps all identity chips visible and lets the row grow when needed.
class AnimalIdentityChipRow extends StatelessWidget {
  const AnimalIdentityChipRow({
    super.key,
    this.breedLabel,
    this.purposeLabel,
    this.statusLabel,
    required this.breedAccentColor,
    required this.breedTextColor,
    required this.purposeAccentColor,
    required this.purposeTextColor,
    this.statusAccentColor,
    this.statusTextColor,
  });

  final String? breedLabel;
  final String? purposeLabel;
  final String? statusLabel;
  final Color breedAccentColor;
  final Color breedTextColor;
  final Color purposeAccentColor;
  final Color purposeTextColor;
  final Color? statusAccentColor;
  final Color? statusTextColor;

  @override
  Widget build(BuildContext context) {
    final chips =
        <({String label, String semanticLabel, Color accent, Color text})>[
          if (breedLabel != null)
            (
              label: breedLabel!,
              semanticLabel: 'Raza $breedLabel',
              accent: breedAccentColor,
              text: breedTextColor,
            ),
          if (purposeLabel != null)
            (
              label: purposeLabel!,
              semanticLabel: 'Propósito $purposeLabel',
              accent: purposeAccentColor,
              text: purposeTextColor,
            ),
          if (statusLabel != null)
            (
              label: statusLabel!,
              semanticLabel: 'Estado $statusLabel',
              accent: statusAccentColor ?? breedAccentColor,
              text: statusTextColor ?? breedTextColor,
            ),
        ];
    return LayoutBuilder(
      builder: (context, constraints) => Wrap(
        spacing: _identityChipSpacing,
        runSpacing: _identityChipSpacing,
        children: [
          for (final chip in chips)
            Semantics(
              label: chip.semanticLabel,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: _identityChip(chip.label, chip.accent, chip.text),
              ),
            ),
        ],
      ),
    );
  }

  Widget _identityChip(String label, Color accent, Color text) => TagChip(
    label: label,
    accentColor: accent,
    textColor: text,
    fontSize: 11,
    tintOpacity: 0.18,
    borderOpacity: 0.14,
    useProvidedTextColorInDark: true,
  );
}

/// Spacing between identity chips.
const double _identityChipSpacing = 4;

class AnimalProfileVisual {
  const AnimalProfileVisual({
    required this.color,
    required this.asset,
    required this.fallbackIcon,
    this.colorFilter,
  });

  final Color color;
  final String asset;
  final IconData fallbackIcon;
  final ColorFilter? colorFilter;
}

AnimalProfileVisual profileVisualFor(AnimalEntity animal, Color stageColor) {
  return AnimalProfileVisual(
    color: stageColor,
    asset:
        petIllustrationAsset(animal.species) ??
        AnimalTaxonomy.assetForStage(animal.lifeStage),
    colorFilter: null,
    fallbackIcon: animal.species == Species.poultry
        ? Icons.egg_alt_outlined
        : animal.species == Species.canine
        ? Icons.pets
        : Icons.agriculture,
  );
}

Color colorFromHex(String hex) {
  return animalColorFromHex(hex);
}

Color _mutedColor(Color color, {double strength = 0.4}) {
  final mutedBase = Color.lerp(color, const Color(0xFF9AA7B5), strength);
  return mutedBase ?? color;
}

String _ageLabelUnderOneYear({
  required DateTime birthDate,
  required int ageMonths,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final birth = DateTime(birthDate.year, birthDate.month, birthDate.day);
  final safeMonths = ageMonths < 0 ? 0 : ageMonths;

  if (birth.isAfter(today)) {
    return '0 meses';
  }

  var monthAnchor = _addMonthsClamped(birth, safeMonths);
  var monthsForLabel = safeMonths;

  while (monthAnchor.isAfter(today) && monthsForLabel > 0) {
    monthsForLabel -= 1;
    monthAnchor = _addMonthsClamped(birth, monthsForLabel);
  }

  final days = today.difference(monthAnchor).inDays;
  final monthText = '$monthsForLabel mes${monthsForLabel == 1 ? '' : 'es'}';

  if (days <= 0) {
    return monthText;
  }

  if (monthsForLabel == 0) {
    return '$days día${days == 1 ? '' : 's'}';
  }

  return '$monthText $days día${days == 1 ? '' : 's'}';
}

DateTime _addMonthsClamped(DateTime date, int monthsToAdd) {
  final totalMonths = date.month - 1 + monthsToAdd;
  final targetYear = date.year + (totalMonths ~/ 12);
  final targetMonth = (totalMonths % 12) + 1;
  final maxDay = _daysInMonth(targetYear, targetMonth);
  final targetDay = date.day > maxDay ? maxDay : date.day;
  return DateTime(targetYear, targetMonth, targetDay);
}

int _daysInMonth(int year, int month) {
  final firstDayNextMonth = month == 12
      ? DateTime(year + 1, 1, 1)
      : DateTime(year, month + 1, 1);
  return firstDayNextMonth.subtract(const Duration(days: 1)).day;
}

String normalizeEarTag(String input) {
  return input.replaceAll(RegExp(r'[^0-9]'), '');
}

class FormattedEarTag extends StatelessWidget {
  const FormattedEarTag({
    super.key,
    required this.earTag,
    required this.prefixStyle,
    required this.separatorStyle,
    required this.suffixStyle,
  });

  final String earTag;
  final TextStyle? prefixStyle;
  final TextStyle? separatorStyle;
  final TextStyle? suffixStyle;

  @override
  Widget build(BuildContext context) {
    final digits = normalizeEarTag(earTag);
    if (digits.length != 12) {
      return Text(
        earTag,
        style: suffixStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final prefix = digits.substring(0, 8);
    final suffix = digits.substring(8, 12);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$prefix ', style: prefixStyle),
          TextSpan(text: '-', style: separatorStyle),
          TextSpan(text: suffix, style: suffixStyle),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Severity drives the chip colour so a withdrawal period or an overdue
/// calving reads differently from a plain statistic, reusing the same warning
/// palette the pending-ear-tag chip and the avatar border already use.
String purposeChipShortLabel(ProductionPurpose purpose) {
  switch (purpose) {
    case ProductionPurpose.meat:
      return 'Engorda';
    case ProductionPurpose.dairy:
      return 'Leche';
    case ProductionPurpose.breeding:
      return 'Cría';
    case ProductionPurpose.dual:
      return 'Doble prop.';
    case ProductionPurpose.work:
      return 'Trabajo';
    case ProductionPurpose.companion:
      return 'Compañía';
    case ProductionPurpose.sport:
      return 'Deporte';
    case ProductionPurpose.eggs:
      return 'Postura';
    case ProductionPurpose.fiber:
      return 'Fibra';
    case ProductionPurpose.guard:
      return 'Guardia';
    case ProductionPurpose.undefined:
      return 'Por definir';
    case ProductionPurpose.other:
      return 'Otro';
  }
}
