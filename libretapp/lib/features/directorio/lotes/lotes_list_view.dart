/// features \u203a directorio \u203a lotes \u203a lotes_list_view \u2014 stateless list layout for lotes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_bloc.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_event.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_state.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/lote_card.dart';

class LotesListView extends StatefulWidget {
  const LotesListView({super.key, this.shellInteractionsEnabled = true});

  final bool shellInteractionsEnabled;

  @override
  State<LotesListView> createState() => _LotesListViewState();
}

class _LotesListViewState extends State<LotesListView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    context.read<LotesBloc>().add(const LoadLotes());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openCreateLotePage() async {
    await context.pushNamed(AppRoutes.nameLoteNuevo);
  }

  void _openLoteDetail(LoteEntity lote) {
    context.pushNamed(
      AppRoutes.nameLoteDetalle,
      pathParameters: {'uuid': lote.uuid},
    );
  }

  Future<void> _confirmDeleteLote(LoteEntity lote) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar lote'),
        content: Text(
          '¿Deseas borrar "${lote.name}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      context.read<LotesBloc>().add(DeleteLote(lote.uuid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = ShellInsets.bottomSafePadding(context);
    final listBottomPadding = bottomInset + 2;

    final scaffold = Scaffold(
      body: BlocBuilder<LotesBloc, LotesState>(
        builder: (context, state) {
          if (state is LotesInitial || state is LotesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LotesError) {
            return Center(child: Text(state.message));
          }

          if (state is! LotesLoaded) {
            return const SizedBox.shrink();
          }

          final lotes = state.activeLotes;
          return _buildLotesContent(
            context: context,
            lotes: lotes,
            listBottomPadding: listBottomPadding,
          );
        },
      ),
    );

    if (!widget.shellInteractionsEnabled) return scaffold;

    return ShellFabConfigScope(
      config: ShellFabConfig(
        id: 'lotes',
        label: 'Agregar Lote',
        icon: Icons.add,
        heroTag: 'fab_lotes',
        onPressed: _openCreateLotePage,
      ),
      child: scaffold,
    );
  }

  Widget _buildLotesContent({
    required BuildContext context,
    required List<LoteEntity> lotes,
    required double listBottomPadding,
  }) {
    if (lotes.isEmpty) {
      return _buildEmptyState(context);
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(4, 0, 4, listBottomPadding),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final lote = lotes[index];
              return _CenteredSection(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Slidable(
                  key: ValueKey('slide_${lote.uuid}'),
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.22,
                    children: [
                      SlidableAction(
                        onPressed: (_) => _openLoteDetail(lote),
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        icon: Icons.edit_outlined,
                        label: 'Editar',
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(20),
                        ),
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.22,
                    children: [
                      SlidableAction(
                        onPressed: (_) => _confirmDeleteLote(lote),
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        icon: Icons.delete_outline,
                        label: 'Eliminar',
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(20),
                        ),
                      ),
                    ],
                  ),
                  child: LoteCard(
                    key: ValueKey('lote_${lote.uuid}'),
                    lote: lote,
                    onTap: () => _openLoteDetail(lote),
                    onEdit: () => _openLoteDetail(lote),
                    onDelete: () => _confirmDeleteLote(lote),
                  ),
                ),
              );
            }, childCount: lotes.length),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return _CenteredSection(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Sin lotes',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Crea tu primer lote para comenzar a organizar tus animales',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Sección centrada para mantener respuesta en pantallas grandes
class _CenteredSection extends StatelessWidget {
  const _CenteredSection({required this.child, this.padding = EdgeInsets.zero});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Padding(padding: padding, child: child),
    );
  }
}
