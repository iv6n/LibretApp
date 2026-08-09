/// features > biblioteca > view > book_detail_page — one subject book:
/// overview, chapter list, appendices, glossary, and read-only operational
/// tools (checklists/decision guides) from the book's content.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/biblioteca/cubit/book_detail_cubit.dart';
import 'package:libretapp/features/biblioteca/data/book_content.dart';
import 'package:libretapp/features/biblioteca/data/library_manifest.dart';
import 'package:libretapp/features/biblioteca/data/library_repository.dart';
import 'package:libretapp/features/biblioteca/view/chapter_reader_page.dart';
import 'package:libretapp/features/biblioteca/widgets/library_book_card.dart';
import 'package:libretapp/features/biblioteca/widgets/reader_block_view.dart';
import 'package:libretapp/theme/app_theme.dart';

class BookDetailPage extends StatelessWidget {
  const BookDetailPage({required this.bookId, this.initialManifestBook, super.key});

  final String bookId;
  final LibraryManifestBook? initialManifestBook;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookDetailCubit(
        libraryRepository: locator<LibraryRepository>(),
        bookId: bookId,
        initialManifestBook: initialManifestBook,
      ),
      child: const _BookDetailView(),
    );
  }
}

class _BookDetailView extends StatelessWidget {
  const _BookDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookDetailCubit, BookDetailState>(
      builder: (context, state) {
        final book = state.manifestBook;
        return Scaffold(
          appBar: AppBar(title: Text(book?.title ?? 'Biblioteca')),
          body: switch (state.status) {
            BookDetailStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            BookDetailStatus.error => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  state.errorMessage ?? 'No se pudo cargar el libro.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            BookDetailStatus.loaded => _BookDetailBody(
              book: book!,
              content: state.content!,
            ),
          },
        );
      },
    );
  }
}

class _BookDetailBody extends StatelessWidget {
  const _BookDetailBody({required this.book, required this.content});

  final LibraryManifestBook book;
  final BookContent content;

  void _openChapter(BuildContext context, ContentUnit unit) {
    context.pushNamed(
      AppRoutes.namePerfilBibliotecaCapitulo,
      pathParameters: {'id': book.bookId, 'chapterId': unit.chapterId},
      extra: ChapterReaderArgs(book: book, content: content, unit: unit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasGlossary = content.glossary.terms.isNotEmpty;
    final hasTools =
        content.operational.checklists.isNotEmpty ||
        content.operational.decisionGuides.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(book.icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(content.subtitle, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(content.description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            _StatChip(icon: Icons.menu_book_outlined, label: '${content.chapters.length} capítulos'),
            if (content.appendices.isNotEmpty)
              _StatChip(icon: Icons.bookmark_outline, label: '${content.appendices.length} apéndices'),
            if (content.figures.isNotEmpty)
              _StatChip(icon: Icons.image_outlined, label: '${content.figures.length} figuras'),
            if (hasGlossary)
              _StatChip(icon: Icons.translate_outlined, label: '${content.glossary.terms.length} términos'),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Capítulos', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        for (final unit in content.chapters)
          Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                foregroundColor: AppColors.primary,
                child: Text('${unit.number ?? '-'}'),
              ),
              title: Text(unit.title),
              subtitle: unit.estimatedReadTime != null
                  ? Text(unit.estimatedReadTime!)
                  : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openChapter(context, unit),
            ),
          ),
        if (content.appendices.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text('Apéndices', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          for (final unit in content.appendices)
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: ListTile(
                leading: const Icon(Icons.bookmark_outline),
                title: Text(unit.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openChapter(context, unit),
              ),
            ),
        ],
        if (hasTools) ...[
          const SizedBox(height: AppSpacing.md),
          Text('Herramientas', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          for (final checklist in content.operational.checklists)
            _ChecklistCard(checklist: checklist),
          for (final guide in content.operational.decisionGuides)
            _DecisionGuideCard(guide: guide),
        ],
        if (hasGlossary) ...[
          const SizedBox(height: AppSpacing.md),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('Glosario', style: theme.textTheme.titleMedium),
            children: [
              ReaderBlockView(
                blocks: content.glossary.reader.blocks,
                figureAssetPath: book.assetPath,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.checklist});
  final OperationalChecklist checklist;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ExpansionTile(
        leading: const Icon(Icons.checklist_outlined),
        title: Text(checklist.title),
        subtitle: Text(checklist.frequency),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final step in checklist.steps)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_box_outline_blank, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(step)),
                      ],
                    ),
                  ),
                if (checklist.escalation.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    checklist.escalation,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionGuideCard extends StatelessWidget {
  const _DecisionGuideCard({required this.guide});
  final OperationalDecisionGuide guide;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ExpansionTile(
        leading: const Icon(Icons.alt_route_outlined),
        title: Text(guide.title),
        subtitle: Text(guide.trigger),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < guide.steps.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('${i + 1}. ${guide.steps[i]}'),
                  ),
                if (guide.escalation.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    guide.escalation,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
