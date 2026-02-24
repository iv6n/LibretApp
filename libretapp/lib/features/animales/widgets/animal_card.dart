import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/animales/domain/animal_domain.dart';
import 'package:libretapp/features/animales/domain/animal_palette.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class AnimalCard extends StatelessWidget {
  const AnimalCard({
    super.key,
    required this.animal,
    this.location,
    this.batchLabel,
    this.onTap,
  });

  final AnimalEntity animal;
  final LocationEntity? location;
  final String? batchLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap:
            onTap ??
            () => context.push(AppRoutes.animalDetallePath(animal.uuid)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
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
                                '${l10n.labelEarTag}: ${animal.earTagNumber}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
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
                            Text(
                              secondaryLabel,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[900],
                                    fontWeight: FontWeight.w500,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              ageLabel,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _InlineInfo(
                        icon: Icons.place_outlined,
                        label: locationLabel,
                      ),
                    ],
                  ),
                  Wrap(
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
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: stageColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stageColor, width: 1.8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey[800]),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
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
