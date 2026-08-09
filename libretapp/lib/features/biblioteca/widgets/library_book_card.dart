/// features > biblioteca > widgets > library_book_card — card for a subject
/// book in the library catalog (the "book of books" top-level grouping).
library;

import 'package:flutter/material.dart';
import 'package:libretapp/features/biblioteca/data/library_manifest.dart';
import 'package:libretapp/theme/app_theme.dart';

const _bookIcons = <String, IconData>{
  'agriculture': Icons.agriculture_outlined,
  'bovinos': Icons.cruelty_free_outlined,
  'caprinos': Icons.terrain_outlined,
  'equinos': Icons.directions_walk,
  'mascotas': Icons.favorite_outline,
  'suelos': Icons.landscape_outlined,
  'ovinos': Icons.grass_outlined,
};

extension LibraryManifestBookIcon on LibraryManifestBook {
  IconData get icon => _bookIcons[bookId] ?? Icons.menu_book_outlined;
}

class LibraryBookCard extends StatelessWidget {
  const LibraryBookCard({required this.book, this.onTap, super.key});

  final LibraryManifestBook book;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(book.icon, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${book.mainChapters} capítulo${book.mainChapters == 1 ? '' : 's'}',
                      style: theme.textTheme.labelSmall,
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
