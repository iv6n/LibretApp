/// features > biblioteca > widgets > library_category_card — library category or item card.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/biblioteca/data/library_item.dart';
import 'package:libretapp/theme/app_theme.dart';

class LibraryCategoryCard extends StatelessWidget {
  const LibraryCategoryCard({
    required this.category,
    required this.itemCount,
    this.onTap,
    super.key,
  });

  final LibraryCategory category;
  final int itemCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(category.icon, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$itemCount artículo${itemCount == 1 ? '' : 's'}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class LibraryItemCard extends StatelessWidget {
  const LibraryItemCard({
    required this.item,
    this.onTap,
    super.key,
  });

  final LibraryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        leading: Icon(item.category.icon, color: AppColors.primary),
        title: Text(item.title),
        subtitle: Text(item.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.isPremium)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.star, size: 16, color: AppColors.amber),
              ),
            if (item.contentType == LibraryContentType.pdf)
              const Icon(Icons.picture_as_pdf_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}
