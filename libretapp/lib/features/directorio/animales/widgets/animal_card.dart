/// features \u203a directorio \u203a animales \u203a widgets \u203a animal_card \u2014 reusable animal card widget.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_palette.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

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
    this.onTap,
    this.onLongPress,
    this.onMenuAction,
    this.onQuickMenuOpenChanged,
    this.onPrepareQuickMenu,
    this.isSelected = false,
    this.selectionEnabled = false,
  });

  final AnimalEntity animal;
  final LocationEntity? location;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<AnimalCardMenuAction>? onMenuAction;
  final ValueChanged<bool>? onQuickMenuOpenChanged;
  final Future<void> Function(BuildContext menuContext)? onPrepareQuickMenu;
  final bool isSelected;
  final bool selectionEnabled;

  @override
  Widget build(BuildContext context) {
    final stageColor = AnimalPalette.categoryColor(animal.category);
    final speciesColor = AnimalPalette.speciesColor(animal.species);
    final profile = profileVisualFor(animal, speciesColor);
    final stageLabel = animal.lifeStage.displayName;
    final purposeLabel = _purposeShortLabel(animal.productionPurpose);
    final showPurpose = animal.productionPurpose != ProductionPurpose.undefined;
    final purposeKpiLabel = _purposeKpiLabel(animal);

    final stageAsset = profile.asset;
    final avatarBorderColor = _avatarBorderColor(animal, context);
    final healthAccentColor = _isNeutralHealthStatus(animal.healthStatus)
        ? null
        : colorFromHex(animal.healthStatus.hexColor);
    final riskAccentColor = _isNeutralRiskLevel(animal.riskLevel)
        ? null
        : colorFromHex(animal.riskLevel.hexColor);
    final locationLabel = location?.name ?? 'Sin ubicación';
    final hasEarTag = animal.earTagNumber.trim().isNotEmpty;
    final breedLabel = breedSummary(animal, abbreviated: true);
    final headerLabel = primaryAnimalLabel(animal);
    final secondaryLabel = hasEarTag
        ? ((animal.customName ?? '').trim().isNotEmpty
              ? animal.customName!.trim()
              : (animal.visualId ?? '').trim().isNotEmpty
              ? animal.visualId!.trim()
              : breedSummary(animal))
        : earTagDisplay(animal);
    final ageMonths = animal.ageMonths;
    final ageYears = ageMonths ~/ 12;
    final ageRemainderMonths = ageMonths % 12;
    final ageLabel = ageYears > 0
        ? ageRemainderMonths == 0
              ? '$ageYears año${ageYears == 1 ? '' : 's'}'
              : '$ageYears año${ageYears == 1 ? '' : 's'} $ageRemainderMonths mes${ageRemainderMonths == 1 ? '' : 'es'}'
        : _ageLabelUnderOneYear(
            birthDate: animal.birthDate,
            ageMonths: ageRemainderMonths,
          );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final cardOverlay = theme.brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.035);
    final selectedOverlay = isSelected
        ? AnimalPalette.uiAccent.withValues(alpha: 0.12)
        : Colors.transparent;
    final baseCard = Color.alphaBlend(cardOverlay, colorScheme.surface);
    final cardColor = Color.alphaBlend(selectedOverlay, baseCard);
    final headerColor = AnimalPalette.cardHeader(context);
    final headerPrimaryTextColor = AnimalPalette.cardTextPrimary(context);
    final headerSecondaryTextColor = AnimalPalette.cardTextSecondary(context);
    final footerColor = AnimalPalette.cardFooter(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AnimalPalette.cardBorder(context, isSelected: isSelected),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      elevation: 1.2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap:
            onTap ??
            () => context.push(AppRoutes.animalDetallePath(animal.uuid)),
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: headerColor),
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _Avatar(
                        borderColor: avatarBorderColor,
                        stageAsset: stageAsset,
                        profile: profile,
                        colorFilter: profile.colorFilter,
                        profilePhoto: animal.profilePhoto,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: hasEarTag
                                      ? FormattedEarTag(
                                          earTag: animal.earTagNumber,
                                          prefixStyle: textTheme.titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                color: headerPrimaryTextColor,
                                                letterSpacing: -0.45,
                                                height: 1.05,
                                              ),
                                          separatorStyle: textTheme.titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 20,
                                                color: headerPrimaryTextColor,
                                                letterSpacing: 1.8,
                                                height: 1.05,
                                              ),
                                          suffixStyle: textTheme.titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18,
                                                color: headerPrimaryTextColor,
                                                letterSpacing: -0.45,
                                                height: 1.05,
                                              ),
                                        )
                                      : Text(
                                          headerLabel,
                                          style: textTheme.titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18,
                                                color: headerPrimaryTextColor,
                                                height: 1.05,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                ),
                                const SizedBox(width: 6),
                                if (!selectionEnabled && onMenuAction != null)
                                  _AnimalCardQuickMenu(
                                    stageLabel: stageLabel,
                                    stageColor: stageColor,
                                    iconColor: headerSecondaryTextColor,
                                    onSelected: onMenuAction!,
                                    onMenuOpenChanged: onQuickMenuOpenChanged,
                                    onPrepareQuickMenu: onPrepareQuickMenu,
                                  )
                                else
                                  TagChip(
                                    fontSize: 10,
                                    label: stageLabel.toUpperCase(),
                                    accentColor: stageColor,
                                    outlined: false,
                                  ),
                                if (selectionEnabled) ...[
                                  const SizedBox(width: 6),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? stageColor
                                          : Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? stageColor
                                            : Theme.of(
                                                context,
                                              ).colorScheme.outlineVariant,
                                        width: 1.4,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 16,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  child: Text(
                                    secondaryLabel,
                                    style: textTheme.titleMedium?.copyWith(
                                      color: headerPrimaryTextColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  child: Text(
                                    ageLabel,
                                    style: textTheme.titleSmall?.copyWith(
                                      fontSize: 12,
                                      color: headerSecondaryTextColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                  ),
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
                                  label: breedLabel.toUpperCase(),
                                  accentColor: AnimalPalette.summaryChipAccent(
                                    context,
                                  ),
                                  textColor: AnimalPalette.summaryChipText,
                                  tintOpacity: 0.10,
                                  borderOpacity: 0.28,
                                ),
                                if (showPurpose)
                                  TagChip(
                                    fontSize: 11,
                                    label: purposeLabel.toUpperCase(),
                                    accentColor:
                                        AnimalPalette.summaryChipAccent(
                                          context,
                                        ),
                                    textColor:
                                        AnimalPalette.purposeSummaryTextColor(
                                          animal.productionPurpose,
                                        ),
                                    tintOpacity: 0.10,
                                    borderOpacity: 0.28,
                                  ),
                                if (showPurpose && purposeKpiLabel != null)
                                  TagChip(
                                    fontSize: 11,
                                    label: purposeKpiLabel.toUpperCase(),
                                    accentColor:
                                        AnimalPalette.summaryChipAccent(
                                          context,
                                        ),
                                    textColor:
                                        AnimalPalette.purposeSummaryTextColor(
                                          animal.productionPurpose,
                                        ),
                                    tintOpacity: 0.10,
                                    borderOpacity: 0.28,
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
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: footerColor,
                border: Border(
                  top: BorderSide(color: AnimalPalette.cardDivider(context)),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
              child: Row(
                children: [
                  SizedBox(
                    child: _InlineInfo(
                      icon: Icons.place_outlined,
                      label: locationLabel,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _StatusPill(
                            icon: Icons.add_circle,
                            label: animal.healthStatus.displayName,
                            accentColor: healthAccentColor,
                          ),
                          _StatusPill(
                            icon: Icons.shield_outlined,
                            label: animal.riskLevel.displayName,
                            accentColor: riskAccentColor,
                          ),
                        ],
                      ),
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

class _AnimalCardQuickMenu extends StatelessWidget {
  const _AnimalCardQuickMenu({
    required this.stageLabel,
    required this.stageColor,
    required this.iconColor,
    required this.onSelected,
    this.onMenuOpenChanged,
    this.onPrepareQuickMenu,
  });

  final String stageLabel;
  final Color stageColor;
  final Color iconColor;
  final ValueChanged<AnimalCardMenuAction> onSelected;
  final ValueChanged<bool>? onMenuOpenChanged;
  final Future<void> Function(BuildContext menuContext)? onPrepareQuickMenu;

  Future<void> _openMenu(BuildContext context) async {
    onMenuOpenChanged?.call(true);
    try {
      await onPrepareQuickMenu?.call(context);
      if (!context.mounted) return;

      final button = context.findRenderObject() as RenderBox?;
      if (button == null) return;

      final overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      final origin = button.localToGlobal(Offset.zero, ancestor: overlay);
      final menuTop = origin.dy + button.size.height + 2;

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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openMenu(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.borderColor,
    required this.stageAsset,
    required this.profile,
    this.colorFilter,
    this.profilePhoto,
  });

  final Color borderColor;
  final String stageAsset;
  final AnimalProfileVisual profile;
  final ColorFilter? colorFilter;
  final String? profilePhoto;

  @override
  Widget build(BuildContext context) {
    final avatarBackgroundColor = AnimalPalette.avatarBackgroundLight;
    final hasPhoto = (profilePhoto ?? '').trim().isNotEmpty;
    final photoUri = Uri.tryParse((profilePhoto ?? '').trim());
    final canLoadNetworkPhoto =
        hasPhoto &&
        photoUri != null &&
        (photoUri.scheme == 'http' || photoUri.scheme == 'https');

    return Material(
      elevation: 2.2,
      shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(18),
      color: avatarBackgroundColor,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: avatarBackgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: canLoadNetworkPhoto
                ? Image.network(
                    profilePhoto!.trim(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildProfileAsset(),
                  )
                : _buildProfileAsset(),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAsset() {
    final image = Image.asset(
      stageAsset,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          Icon(profile.fallbackIcon, color: profile.color, size: 30),
    );
    final filter = colorFilter;
    if (filter == null) return image;
    return ColorFiltered(colorFilter: filter, child: image);
  }
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
          size: 22,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.82),
        ),
        const SizedBox(width: 2),
        SizedBox(
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
}

bool _isNeutralHealthStatus(HealthStatus status) {
  switch (status) {
    case HealthStatus.good:
    case HealthStatus.excellent:
    case HealthStatus.unknown:
      return true;
    case HealthStatus.fair:
    case HealthStatus.poor:
    case HealthStatus.critical:
      return false;
  }
}

bool _isNeutralRiskLevel(RiskLevel level) {
  switch (level) {
    case RiskLevel.none:
    case RiskLevel.low:
      return true;
    case RiskLevel.medium:
    case RiskLevel.high:
    case RiskLevel.critical:
      return false;
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    this.accentColor,
  });

  final IconData icon;
  final String label;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = _statusPillColors(isDark: isDark, accentColor: accentColor);

    return Container(
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
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0,
              color: colors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

({Color background, Color foreground, Color border}) _statusPillColors({
  required bool isDark,
  required Color? accentColor,
}) {
  if (accentColor == null) {
    final foreground = isDark
        ? const Color(0xFFB8C0CA)
        : const Color(0xFF5A6575);
    return (
      background: isDark ? const Color(0xFF3A424D) : const Color(0xFFE8ECF0),
      foreground: foreground,
      border: foreground.withValues(alpha: isDark ? 0.28 : 0.24),
    );
  }

  final toned = _mutedColor(accentColor, strength: isDark ? 0.18 : 0.28);
  final foreground = Color.lerp(
    toned,
    isDark ? Colors.white : const Color(0xFF1E2836),
    isDark ? 0.28 : 0.42,
  )!;
  return (
    background: toned.withValues(alpha: isDark ? 0.24 : 0.16),
    foreground: foreground,
    border: toned.withValues(alpha: isDark ? 0.42 : 0.38),
  );
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
  });

  final String label;
  final Color accentColor;
  final Color? textColor;
  final double fontSize;
  final double tintOpacity;
  final double borderOpacity;
  final bool outlined;
  final double solidAlpha;

  @override
  Widget build(BuildContext context) {
    if (!outlined) {
      final tonedColor = _mutedColor(accentColor, strength: 0.5);
      final luminance = tonedColor.computeLuminance();
      final labelColor = luminance > 0.65 ? Colors.black87 : Colors.white;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
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
          style: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w800,
            fontSize: fontSize,
          ),
        ),
      );
    }

    final labelColor = textColor ?? accentColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
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
        style: TextStyle(
          color: labelColor,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

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
    asset: AnimalTaxonomy.assetForStage(animal.lifeStage),
    colorFilter: null,
    fallbackIcon: animal.species == Species.poultry
        ? Icons.egg_alt_outlined
        : animal.species == Species.canine
        ? Icons.pets
        : Icons.agriculture,
  );
}

Color colorFromHex(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
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

String _purposeShortLabel(ProductionPurpose purpose) {
  switch (purpose) {
    case ProductionPurpose.meat:
      return 'Engorda';
    case ProductionPurpose.dairy:
      return 'Leche';
    case ProductionPurpose.breeding:
      return 'Cría';
    case ProductionPurpose.dual:
      return 'Reproductor';
    case ProductionPurpose.work:
      return 'Trabajo';
    case ProductionPurpose.companion:
      return 'Compañía';
    case ProductionPurpose.undefined:
      return 'Por definir';
    case ProductionPurpose.other:
      return 'Otro';
  }
}

/// Contextual KPI shown next to the purpose chip. Returns null when there is
/// no meaningful data for the animal's purpose.
String? _purposeKpiLabel(AnimalEntity animal) {
  switch (animal.productionPurpose) {
    case ProductionPurpose.meat:
      final weight = animal.weight;
      if (weight == null || weight <= 0) return null;
      final weightText = _formatKg(weight);
      final gain = animal.dailyGainEstimate;
      if (gain != null && gain > 0) {
        return '$weightText +${_formatKg(gain)}/día';
      }
      return weightText;
    case ProductionPurpose.dual:
    case ProductionPurpose.breeding:
      if (animal.reproductiveStatus == ReproductiveStatus.pregnant) {
        final months = _pregnancyMonths(animal);
        if (months != null) {
          return '$months ${months == 1 ? 'mes' : 'meses'} preñez';
        }
        return 'Gestante';
      }
      return _reproductiveShortLabel(animal.reproductiveStatus);
    case ProductionPurpose.dairy:
      switch (animal.reproductiveStatus) {
        case ReproductiveStatus.lactating:
          return 'Lactante';
        case ReproductiveStatus.dry:
          return 'Seca';
        case ReproductiveStatus.pregnant:
          final months = _pregnancyMonths(animal);
          if (months != null) {
            return '$months ${months == 1 ? 'mes' : 'meses'} preñez';
          }
          return 'Gestante';
        case ReproductiveStatus.virgin:
        case ReproductiveStatus.active:
        case ReproductiveStatus.neutered:
        case ReproductiveStatus.retired:
        case ReproductiveStatus.unknown:
          return null;
      }
    case ProductionPurpose.work:
      final years = animal.ageMonths ~/ 12;
      if (years > 0) {
        return '$years año${years == 1 ? '' : 's'}';
      }
      final months = animal.ageMonths;
      if (months <= 0) return null;
      return '$months ${months == 1 ? 'mes' : 'meses'}';
    case ProductionPurpose.companion:
    case ProductionPurpose.undefined:
    case ProductionPurpose.other:
      return null;
  }
}

String? _reproductiveShortLabel(ReproductiveStatus status) {
  switch (status) {
    case ReproductiveStatus.virgin:
      return 'Virgen';
    case ReproductiveStatus.active:
      return 'Activa';
    case ReproductiveStatus.lactating:
      return 'Lactante';
    case ReproductiveStatus.dry:
      return 'Seca';
    case ReproductiveStatus.pregnant:
      return 'Gestante';
    case ReproductiveStatus.neutered:
    case ReproductiveStatus.retired:
    case ReproductiveStatus.unknown:
      return null;
  }
}

/// Standard bovine gestation length in days (see reproduction_scheduler).
const int _gestationDays = 283;

int? _pregnancyMonths(AnimalEntity animal) {
  final now = DateTime.now();
  DateTime? serviceDate = animal.lastServiceDate ?? animal.firstServiceDate;
  if (serviceDate == null && animal.expectedCalvingDate != null) {
    serviceDate = animal.expectedCalvingDate!.subtract(
      const Duration(days: _gestationDays),
    );
  }
  if (serviceDate == null) return null;
  if (serviceDate.isAfter(now)) return 0;

  final days = now.difference(serviceDate).inDays;
  var months = (days / 30.44).floor();
  if (months < 0) months = 0;
  if (months > 9) months = 9;
  return months;
}

String _formatKg(double value) {
  final rounded = value % 1 == 0
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
  return '$rounded kg';
}
