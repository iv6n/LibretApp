/// features \u203a inicio \u203a widgets \u203a quick_summary_section \u2014 summary statistics section on the home dashboard.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/category.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/theme/app_theme.dart';

class QuickSummarySection extends StatelessWidget {
  const QuickSummarySection({required this.data, super.key});

  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    final items = data.categoryBreakdown;
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Resumen Rápido',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: Text(
                'Total: ${data.totalAnimals}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 2),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) => _CategoryCard(summary: items[i]),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.summary});

  final CategorySummary summary;

  static String? _imagePath(Category cat) {
    switch (cat) {
      case Category.calf:
        return 'assets/images/becerro.png';
      case Category.heifer:
        return 'assets/images/vaquilla.png';
      case Category.youngBull:
        return 'assets/images/toro.png';
      case Category.steer:
        return 'assets/images/novillo.png';
      case Category.cow:
        return 'assets/images/vaca.png';
      case Category.bull:
        return 'assets/images/toro.png';
      case Category.oxen:
        return 'assets/images/novillo.png';
      case Category.weaned:
        return 'assets/images/becerro.png';
      case Category.other:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final imagePath = _imagePath(summary.category);
    final showSexBreakdown = summary.maleCount > 0 && summary.femaleCount > 0;

    return Container(
      width: 92,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 4),
              if (imagePath != null)
                Image.asset(
                  imagePath,
                  height: 52,
                  width: 52,
                  fit: BoxFit.contain,
                )
              else
                const Icon(Icons.pets, size: 52),
              const SizedBox(height: 6),
              Text(
                summary.category.displayName,
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (showSexBreakdown) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.male, size: 13, color: Colors.blue.shade400),
                    Text(
                      '${summary.maleCount}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(width: 5),
                    Icon(Icons.female, size: 13, color: Colors.pink.shade300),
                    Text(
                      '${summary.femaleCount}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
          // Count badge – top-right corner
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${summary.total}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
