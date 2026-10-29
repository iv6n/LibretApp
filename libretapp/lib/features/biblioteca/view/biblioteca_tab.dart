/// features > biblioteca > view > biblioteca_tab — library catalog: the
/// "book of books" list of subject books, currently rendered inside
/// Perfil's tab bar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/shell_insets.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/widgets/app_empty_state.dart';
import 'package:libretapp/core/widgets/app_search_bar.dart';
import 'package:libretapp/features/biblioteca/cubit/biblioteca_cubit.dart';
import 'package:libretapp/features/biblioteca/data/library_manifest.dart';
import 'package:libretapp/features/biblioteca/widgets/library_book_card.dart';
import 'package:libretapp/theme/app_theme.dart';

class BibliotecaTab extends StatefulWidget {
  const BibliotecaTab({super.key});

  @override
  State<BibliotecaTab> createState() => _BibliotecaTabState();
}

class _BibliotecaTabState extends State<BibliotecaTab>
    with AutomaticKeepAliveClientMixin {
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
  }

  void _openBook(BuildContext context, LibraryManifestBook book) {
    context.pushNamed(
      AppRoutes.namePerfilBibliotecaItem,
      pathParameters: {'id': book.bookId},
      extra: book,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<BibliotecaCubit, BibliotecaState>(
      builder: (context, state) {
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
                hintText: 'Buscar en la biblioteca…',
                onChanged: _search,
                onClear: () {
                  _searchController.clear();
                  _search('');
                },
              ),
            ),
            if (state.status == BibliotecaLoadStatus.loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (state.status == BibliotecaLoadStatus.error)
              Expanded(
                child: AppEmptyState(
                  icon: Icons.error_outline,
                  title: 'Error al cargar la biblioteca',
                  message: state.errorMessage,
                ),
              )
            else if (state.books.isEmpty)
              const Expanded(
                child: AppEmptyState(
                  icon: Icons.menu_book_outlined,
                  title: 'Sin resultados',
                  message: 'Prueba otra búsqueda.',
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md + ShellInsets.bottomSafePadding(context),
                  ),
                  children: [
                    for (final book in state.books)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: LibraryBookCard(
                          book: book,
                          onTap: () => _openBook(context, book),
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
