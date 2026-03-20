import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_palette.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

class AnimalCard extends StatelessWidget {
  const AnimalCard({
    super.key,
    required this.animal,
    this.location,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.selectionEnabled = false,
  });

  final AnimalEntity animal;
  final LocationEntity? location;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool selectionEnabled;

  @override
  Widget build(BuildContext context) {
    final stageColor = AnimalPalette.stageColor(animal.lifeStage);
    final profile = profileVisualFor(animal, stageColor);
    final stageLabel = animal.lifeStage.displayName;
    final purposeLabel = _purposeShortLabel(animal.productionPurpose);

    final stageAsset = profile.asset;
    final avatarBorderColor = _avatarBorderColor(animal, context);
    final sexoSymbol = animal.sex == Sex.male ? '♂' : '♀';
    final sexoColor = animal.sex == Sex.male
        ? const Color(0xFF16A0A9)
        : const Color(0xFFBB6BD9);
    final healthColor = colorFromHex(animal.healthStatus.hexColor);
    final riskColor = colorFromHex(animal.riskLevel.hexColor);
    final locationLabel = location?.name ?? 'Sin ubicación';
    final breedLabel = animal.breed.isNotEmpty
        ? animal.breed
        : animal.species.displayName;
    final secondaryLabel = (animal.visualId ?? '').isNotEmpty
        ? animal.visualId!
        : (animal.breed.isNotEmpty ? animal.breed : animal.species.displayName);
    final ageMonths = animal.ageMonths;
    final ageYears = ageMonths ~/ 12;
    final ageRemainderMonths = ageMonths % 12;
    final ageLabel = ageYears > 0
        ? [
            '$ageYears año${ageYears == 1 ? '' : 's'}',
            if (ageRemainderMonths > 0)
              '$ageRemainderMonths mes${ageRemainderMonths == 1 ? '' : 'es'}',
          ].join(' ')
        : '$ageRemainderMonths mes${ageRemainderMonths == 1 ? '' : 'es'}';

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final purposeChipColor = colorScheme.secondary;
    final cardOverlay = theme.brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.035);
    final selectedOverlay = isSelected
        ? stageColor.withValues(alpha: 0.16)
        : Colors.transparent;
    final baseCard = Color.alphaBlend(cardOverlay, colorScheme.surface);
    final cardColor = Color.alphaBlend(selectedOverlay, baseCard);
    final headerColor = theme.brightness == Brightness.dark
        ? Color.alphaBlend(
            Colors.white.withValues(alpha: 0.035),
            colorScheme.surface,
          )
        : const Color.fromARGB(255, 226, 231, 236);
    final headerPrimaryTextColor = theme.brightness == Brightness.dark
        ? colorScheme.onSurface
        : const Color(0xFF233041);
    final headerSecondaryTextColor = theme.brightness == Brightness.dark
        ? colorScheme.onSurface.withValues(alpha: 0.76)
        : const Color(0xFF3A4758);
    final footerColor = theme.brightness == Brightness.dark
        ? Color.alphaBlend(
            Colors.white.withValues(alpha: 0.035),
            colorScheme.surface,
          )
        : const Color.fromARGB(255, 238, 241, 241);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? stageColor.withValues(alpha: 0.95)
              : colorScheme.outlineVariant.withValues(alpha: 0.38),
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
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Avatar(
                        borderColor: avatarBorderColor,
                        stageAsset: stageAsset,
                        profile: profile,
                        profilePhoto: animal.profilePhoto,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    animal.earTagNumber,
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20,
                                      color: headerPrimaryTextColor,
                                      letterSpacing: -0.45,
                                      height: 1.05,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  sexoSymbol,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: sexoColor,
                                    height: 1,
                                  ),
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
                            const SizedBox(height: 2),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
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
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 14),
                                    child: Text(
                                      ageLabel,
                                      style: textTheme.titleSmall?.copyWith(
                                        fontSize: 14,
                                        color: headerSecondaryTextColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            Wrap(
                              spacing: 5,
                              runSpacing: 3,
                              children: [
                                TagChip(label: stageLabel, color: stageColor),
                                TagChip(
                                  label: breedLabel,
                                  color: purposeChipColor,
                                ),
                                TagChip(
                                  label: purposeLabel,
                                  color: purposeChipColor,
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
                  top: BorderSide(
                    color: theme.brightness == Brightness.dark
                        ? colorScheme.outlineVariant.withValues(alpha: 0.42)
                        : const Color(0xFFD9DEE8),
                  ),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
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
                        spacing: 2,
                        runSpacing: 3,
                        children: [
                          _StatusPill(
                            icon: Icons.monitor_heart,
                            label: animal.healthStatus.displayName,
                            color: healthColor,
                            emphasizeGreen: true,
                          ),
                          _StatusPill(
                            icon: Icons.shield_outlined,
                            label: animal.riskLevel.displayName,
                            color: riskColor,
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

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.borderColor,
    required this.stageAsset,
    required this.profile,
    this.profilePhoto,
  });

  final Color borderColor;
  final String stageAsset;
  final AnimalProfileVisual profile;
  final String? profilePhoto;

  @override
  Widget build(BuildContext context) {
    const avatarBackgroundColor = Color.fromARGB(255, 240, 241, 241);
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
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      stageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        profile.fallbackIcon,
                        color: profile.color,
                        size: 30,
                      ),
                    ),
                  )
                : Image.asset(
                    stageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      profile.fallbackIcon,
                      color: profile.color,
                      size: 30,
                    ),
                  ),
          ),
        ),
      ),
    );
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
  return Theme.of(context).colorScheme.outlineVariant;
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
    this.emphasizeGreen = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool emphasizeGreen;

  @override
  Widget build(BuildContext context) {
    final tonedColor = _mutedColor(color, strength: 0.34);
    final bool isGreenTone =
        tonedColor.green > tonedColor.red && tonedColor.green > tonedColor.blue;
    final bool useStrongBg = emphasizeGreen && isGreenTone;
    final Color strongTone = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.2),
      tonedColor,
    );
    final Color pillBg = useStrongBg
        ? strongTone.withValues(alpha: 0.95)
        : tonedColor.withValues(alpha: 0.4);
    final double luminance = pillBg.computeLuminance();
    final bool isLight = luminance > 0.65;
    final Color pillText = isLight ? Colors.black : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: pillText),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
              color: pillText,
            ),
          ),
        ],
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    required this.color,
    this.alpha = 0.80,
  });

  final String label;
  final Color color;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    final tonedColor = _mutedColor(color, strength: 0.5);
    final double luminance = tonedColor.computeLuminance();
    final textColor = luminance > 0.65 ? Colors.black87 : Colors.white;
    final bgColor = tonedColor.withValues(alpha: alpha);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: tonedColor.withValues(alpha: 0.28),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 12,
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
  });

  final Color color;
  final String asset;
  final IconData fallbackIcon;
}

AnimalProfileVisual profileVisualFor(AnimalEntity animal, Color stageColor) {
  switch (animal.lifeStage) {
    case LifeStage.calf:
    case LifeStage.calfMale:
    case LifeStage.calfFemale:
    case LifeStage.colt:
    case LifeStage.filly:
      return AnimalProfileVisual(
        color: stageColor,
        asset: 'assets/images/becerro.png',
        fallbackIcon: Icons.child_care,
      );
    case LifeStage.heifer:
      return AnimalProfileVisual(
        color: stageColor,
        asset: 'assets/images/vaquilla.png',
        fallbackIcon: Icons.pets,
      );
    case LifeStage.cow:
      return AnimalProfileVisual(
        color: stageColor,
        asset: 'assets/images/vaca.png',
        fallbackIcon: Icons.pets,
      );
    case LifeStage.bull:
    case LifeStage.youngBull:
      return AnimalProfileVisual(
        color: stageColor,
        asset: 'assets/images/toro.png',
        fallbackIcon: Icons.agriculture,
      );
    case LifeStage.horse:
    case LifeStage.mare:
      return AnimalProfileVisual(
        color: stageColor,
        asset: 'assets/images/caballo.png',
        fallbackIcon: Icons.pets,
      );
    case LifeStage.donkey:
    case LifeStage.donkeyFemale:
      return AnimalProfileVisual(
        color: stageColor,
        asset: 'assets/images/burro.png',
        fallbackIcon: Icons.pets,
      );
    case LifeStage.mule:
      return AnimalProfileVisual(
        color: stageColor,
        asset: 'assets/images/mula.png',
        fallbackIcon: Icons.pets,
      );
    case LifeStage.steer:
      return AnimalProfileVisual(
        color: stageColor,
        asset: 'assets/images/novillo.png',
        fallbackIcon: Icons.pets,
      );
  }
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

String _purposeShortLabel(ProductionPurpose purpose) {
  switch (purpose) {
    case ProductionPurpose.meat:
      return 'Carne';
    case ProductionPurpose.dairy:
      return 'Leche';
    case ProductionPurpose.breeding:
      return 'Cría';
    case ProductionPurpose.dual:
      return 'Dual';
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
