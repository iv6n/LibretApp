/// features > biblioteca > widgets > reader_block_view — renders the
/// `reader` layer of book-content.json. Per APP_CONTENT_CONTRACT.md in the
/// content repo, `reader` is the only layer safe to show as reading text;
/// this widget is the sole place that layer gets turned into UI.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:libretapp/features/biblioteca/data/reader_block.dart';
import 'package:libretapp/theme/app_theme.dart';

class ReaderBlockView extends StatelessWidget {
  const ReaderBlockView({
    required this.blocks,
    required this.figureAssetPath,
    super.key,
  });

  /// The chapter/appendix/glossary's reader blocks, in order.
  final List<ReaderBlock> blocks;

  /// Resolves a [FigureBlock.path] (e.g. `assets/figures/x.svg`) to a full
  /// Flutter asset path for this book.
  final String Function(String relativePath) figureAssetPath;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks) _buildBlock(context, block),
      ],
    );
  }

  Widget _buildBlock(BuildContext context, ReaderBlock block) {
    final theme = Theme.of(context);
    return switch (block) {
      HeadingBlock(:final level, :final text) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
        child: Text(
          text,
          style: level <= 1
              ? theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)
              : level == 2
              ? theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)
              : theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      ParagraphBlock(:final text) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
      ),
      ListBlock(:final ordered, :final items) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        ordered ? '${i + 1}.' : '•',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        items[i],
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      QuoteBlock(:final text) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.primary, width: 3),
          ),
          color: AppColors.primary.withValues(alpha: 0.05),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      TableBlock(:final header, :final body) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              for (final col in header) DataColumn(label: Text(col)),
            ],
            rows: [
              for (final row in body)
                DataRow(cells: [for (final cell in row) DataCell(Text(cell))]),
            ],
          ),
        ),
      ),
      DividerBlock() => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Divider(),
      ),
      FigureBlock(:final path, :final alt) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: SvgPicture.asset(
            figureAssetPath(path),
            semanticsLabel: alt,
            placeholderBuilder: (_) => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ),
      MetadataBlock(:final items) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(item, style: theme.textTheme.bodySmall),
              ),
          ],
        ),
      ),
      UnknownBlock() => const SizedBox.shrink(),
    };
  }
}
