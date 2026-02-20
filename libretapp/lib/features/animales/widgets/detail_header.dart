import 'package:flutter/material.dart';
import 'package:libretapp/features/animales/domain/animal_domain.dart';
import 'package:libretapp/features/animales/widgets/detail_helpers.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class DetailHeader extends StatelessWidget {
  const DetailHeader({super.key, required this.animal});

  final AnimalEntity animal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = detailStageColor(animal.lifeStage);
    final riskColor = detailColorFromHex(animal.riskLevel.hexColor);
    final healthColor = detailColorFromHex(animal.healthStatus.hexColor);
    final asset = stageAsset(animal.lifeStage);
    final sexoSymbol = animal.sex == Sex.male ? '♂' : '♀';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.85),
            color.withValues(alpha: 0.65),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    asset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.pets, size: 30, color: color),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal.visualId ?? l10n.valueNotAssigned,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.labelEarTag} ${animal.earTagNumber}  ·  ${animal.lifeStage.displayName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              BadgeChip(
                label: '${animal.sex.displayName} $sexoSymbol',
                color: Colors.white,
                textColor: color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
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
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
        ),
      ),
    );
  }
}
