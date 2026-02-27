import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_palette.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

class AnimalCard extends StatelessWidget {
  const AnimalCard({
    super.key,
    required this.animal,
    this.location,
    this.onTap,
  });

  final AnimalEntity animal;
  final LocationEntity? location;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final stageColor = AnimalPalette.stageColor(animal.lifeStage);
    final profile = profileVisualFor(animal, stageColor);
    final stageLabel = animal.lifeStage.displayName;

    final stageAsset = profile.asset;
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
    final cardOverlay = theme.brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04);
    final cardColor = Color.alphaBlend(cardOverlay, colorScheme.surface);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      color: cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap:
            onTap ??
            () => context.push(AppRoutes.animalDetallePath(animal.uuid)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(
                    stageColor: stageColor,
                    stageAsset: stageAsset,
                    profile: profile,
                  ),
                  const SizedBox(width: 7),
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
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  color: colorScheme.onSurface,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            Text(
                              sexoSymbol,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: sexoColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                secondaryLabel,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                ageLabel,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.64,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children: [
                            TagChip(label: stageLabel, color: stageColor),
                            TagChip(
                              label: breedLabel,
                              color: const Color.fromARGB(255, 83, 155, 148),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _InlineInfo(
                      icon: Icons.place_outlined,
                      label: locationLabel,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 4,
                        runSpacing: 2,
                        children: [
                          _StatusPill(
                            icon: Icons.monitor_heart,
                            label: animal.healthStatus.displayName,
                            color: healthColor,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.stageColor,
    required this.stageAsset,
    required this.profile,
  });

  final Color stageColor;
  final String stageAsset;
  final AnimalProfileVisual profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: stageColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: stageColor, width: 1.4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Image.asset(
            stageAsset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Icon(profile.fallbackIcon, color: stageColor, size: 30),
          ),
        ),
      ),
    );
  }
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
          size: 18,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.82),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
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
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double luminance = color.computeLuminance();
    final bool isLight = luminance > 0.65;
    final Color pillText = isLight ? Colors.black : Colors.white;
    final Color pillBg = color.withValues(alpha: 0.24);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: pillText),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
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
  const TagChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double luminance = color.computeLuminance();
    final textColor = luminance > 0.65 ? Colors.black87 : Colors.white;
    final bgColor = color.withValues(alpha: 0.24);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
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
