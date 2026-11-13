/// features \u203a inicio \u203a widgets \u203a quick_summary_section \u2014 summary statistics section on the home dashboard.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/category.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/theme/app_theme.dart';

/// Canonical display order for categories in the animal summary.
const _kCategoryOrder = <Category>[
  // Bovinos
  Category.cow,
  Category.bull,
  Category.heifer,
  Category.youngBull,
  Category.steer,
  Category.calf,
  Category.weaned,
  Category.oxen,
  // Genericos / otras especies
  Category.production,
  Category.reproduction,
  Category.fattening,
  Category.grower,
  Category.juvenile,
  Category.work,
  Category.guard,
  Category.other,
];

List<CategorySummary> sortedCategoryBreakdown(List<CategorySummary> items) {
  final ordered = <CategorySummary>[];
  for (final cat in _kCategoryOrder) {
    final match = items.where((s) => s.category == cat);
    if (match.isNotEmpty) ordered.add(match.first);
  }
  for (final item in items) {
    if (!ordered.any((s) => s.category == item.category)) ordered.add(item);
  }
  return ordered;
}

class QuickSummarySection extends StatelessWidget {
  const QuickSummarySection({required this.data, super.key});

  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    final items = sortedCategoryBreakdown(data.categoryBreakdown);
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 2),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) => _CategoryCard(summary: items[i]),
      ),
    );
  }
}

/// Animal categories shown as a single horizontal row in the dashboard.
class AnimalCategoryRow extends StatelessWidget {
  const AnimalCategoryRow({required this.data, super.key});

  final InicioDashboardData data;

  @override
  Widget build(BuildContext context) {
    final items = sortedCategoryBreakdown(data.categoryBreakdown);
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Por categoría',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 2),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) => AnimalCategoryCard(
              summary: items[index],
              onTap: () => context.push(AppRoutes.directorio),
            ),
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
        return 'assets/images/becerro.webp';
      case Category.heifer:
        return 'assets/images/vaquilla.webp';
      case Category.youngBull:
        return 'assets/images/toro.webp';
      case Category.steer:
        return 'assets/images/novillo.webp';
      case Category.cow:
        return 'assets/images/vaca.webp';
      case Category.bull:
        return 'assets/images/toro.webp';
      case Category.oxen:
        return 'assets/images/novillo.webp';
      case Category.weaned:
        return 'assets/images/becerro.webp';
      case Category.juvenile:
        return 'assets/images/becerro.webp';
      case Category.grower:
        return 'assets/images/novillo.webp';
      case Category.fattening:
        return 'assets/images/novillo.webp';
      case Category.production:
        return 'assets/images/vaca.webp';
      case Category.reproduction:
        return 'assets/images/toro.webp';
      case Category.work:
        return 'assets/images/caballo.webp';
      case Category.guard:
        return 'assets/images/canino.webp';
      case Category.other:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final imagePath = _imagePath(summary.category);

    return SizedBox(
      width: 88,
      child: Material(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: () => context.push(AppRoutes.directorio),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.25),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (imagePath != null)
                      Image.asset(
                        imagePath,
                        height: 44,
                        width: 44,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.pets, size: 44),
                      )
                    else
                      const Icon(Icons.pets, size: 44),
                    const SizedBox(height: 4),
                    Text(
                      summary.category.displayName,
                      style: theme.textTheme.labelSmall,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Semantics(
                      label:
                          'Machos ${summary.maleCount}, hembras ${summary.femaleCount}',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.male,
                            size: 11,
                            color: Colors.blue.shade400,
                          ),
                          Text(
                            '${summary.maleCount}',
                            style: theme.textTheme.labelSmall,
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.female,
                            size: 11,
                            color: Colors.pink.shade300,
                          ),
                          Text(
                            '${summary.femaleCount}',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Count badge top-right
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${summary.total}',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimalCategoryCard extends StatelessWidget {
  const AnimalCategoryCard({
    required this.summary,
    required this.onTap,
    this.width = 112,
    super.key,
  });

  final CategorySummary summary;
  final VoidCallback onTap;
  final double width;

  static String? imagePath(Category cat) {
    switch (cat) {
      case Category.calf:
        return 'assets/images/becerro.webp';
      case Category.heifer:
        return 'assets/images/vaquilla.webp';
      case Category.youngBull:
        return 'assets/images/toro.webp';
      case Category.steer:
        return 'assets/images/novillo.webp';
      case Category.cow:
        return 'assets/images/vaca.webp';
      case Category.bull:
        return 'assets/images/toro.webp';
      case Category.oxen:
        return 'assets/images/novillo.webp';
      case Category.weaned:
        return 'assets/images/becerro.webp';
      case Category.juvenile:
        return 'assets/images/becerro.webp';
      case Category.grower:
        return 'assets/images/novillo.webp';
      case Category.fattening:
        return 'assets/images/novillo.webp';
      case Category.production:
        return 'assets/images/vaca.webp';
      case Category.reproduction:
        return 'assets/images/toro.webp';
      case Category.work:
        return 'assets/images/caballo.webp';
      case Category.guard:
        return 'assets/images/canino.webp';
      case Category.other:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final img = imagePath(summary.category);

    return SizedBox(
      width: width,
      child: Material(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.2),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (img != null)
                      Image.asset(
                        img,
                        height: 60,
                        width: 60,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.pets, size: 60),
                      )
                    else
                      const Icon(Icons.pets, size: 60),
                    const SizedBox(height: 6),
                    Text(
                      summary.category.displayName,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.male, size: 13, color: Colors.blue.shade400),
                        Text(
                          '${summary.maleCount}',
                          style: theme.textTheme.labelSmall,
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.female,
                          size: 13,
                          color: Colors.pink.shade300,
                        ),
                        Text(
                          '${summary.femaleCount}',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${summary.total}',
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
