/// features > biblioteca > view > biblioteca_tab — educational library tab,
/// currently rendered inside Perfil's tab bar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/widgets/app_empty_state.dart';
import 'package:libretapp/core/widgets/app_search_bar.dart';
import 'package:libretapp/features/biblioteca/cubit/biblioteca_cubit.dart';
import 'package:libretapp/features/biblioteca/data/library_item.dart';
import 'package:libretapp/features/biblioteca/widgets/library_category_card.dart';
import 'package:libretapp/theme/app_theme.dart';

class BibliotecaTab extends StatefulWidget {
  const BibliotecaTab({super.key});

  @override
  State<BibliotecaTab> createState() => _BibliotecaTabState();
}

class _BibliotecaTabState extends State<BibliotecaTab>
    with AutomaticKeepAliveClientMixin {
  LibraryCategory? _filter;
  final _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<BibliotecaCubit>().loadBiblioteca();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    context.read<BibliotecaCubit>().loadBiblioteca(query: query);
    setState(() => _filter = null);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<BibliotecaCubit, BibliotecaState>(
      builder: (context, state) {
        final items = _filter == null
            ? state.items
            : state.items
                  .where((i) => i.category == _filter)
                  .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                0,
              ),
              child: AppSearchBar(
                controller: _searchController,
                hintText: 'Buscar en biblioteca…',
                onChanged: _search,
                onClear: () {
                  _searchController.clear();
                  _search('');
                },
              ),
            ),
            if (state.status == BibliotecaLoadStatus.loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.status == BibliotecaLoadStatus.error)
              Expanded(
                child: AppEmptyState(
                  icon: Icons.error_outline,
                  title: 'Error al cargar biblioteca',
                  message: state.errorMessage,
                ),
              )
            else if (_filter == null && state.query.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.amber),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Contenido de demostración — preparado para PDF y premium.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  children: [
                    _FeaturedLibraryCard(
                      item: state.items.isNotEmpty
                          ? state.items.first
                          : _mockFeaturedItem,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lectura completa proximamente'),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...LibraryCategory.values.map((cat) {
                      final count = state.items
                          .where((i) => i.category == cat)
                          .length;
                      if (count == 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: LibraryCategoryCard(
                          category: cat,
                          itemCount: count,
                          onTap: () => setState(() => _filter = cat),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ] else
              Expanded(
                child: items.isEmpty
                    ? const AppEmptyState(
                        icon: Icons.menu_book_outlined,
                        title: 'Sin resultados',
                        message: 'Prueba otra búsqueda o categoría.',
                      )
                    : ListView(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        children: [
                          if (_filter != null)
                            TextButton.icon(
                              onPressed: () => setState(() => _filter = null),
                              icon: const Icon(Icons.arrow_back),
                              label: Text(_filter!.label),
                            ),
                          ...items.map(
                            (item) => LibraryItemCard(
                              item: item,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${item.title} — lectura completa próximamente',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
          ],
        );
      },
    );
  }
}

const _mockFeaturedItem = LibraryItem(
  id: 'mock-location-playbook',
  title: 'Checklist de recorrido del rancho',
  summary:
      'Guia rapida para revisar agua, potreros, corrales y pendientes antes de mover animales.',
  category: LibraryCategory.guides,
  contentType: LibraryContentType.guide,
  tags: ['recorrido', 'ubicaciones', 'manejo'],
);

class _FeaturedLibraryCard extends StatelessWidget {
  const _FeaturedLibraryCard({
    required this.item,
    required this.onTap,
  });

  final LibraryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
            color: Color.alphaBlend(
              AppColors.primary.withValues(alpha: 0.06),
              theme.colorScheme.surface,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.category.icon, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destacado',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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
