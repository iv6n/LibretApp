/// features \u203a directorio \u203a lotes \u203a lotes_list_view \u2014 stateless list layout for lotes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/extensions/context_extensions.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_bloc.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_event.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_state.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class LotesListView extends StatefulWidget {
  const LotesListView({super.key});

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
      builder: (context) => AlertDialog(
        title: const Text('Eliminar lote'),
        content: Text(
          '¿Deseas borrar "${lote.nombre}"? Esta acción no se puede deshacer.',
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
    final l10n = AppLocalizations.of(context);
    final bottomInset = ShellInsets.bottomSafePadding(context);
    final listBottomPadding = bottomInset + 2;

    final fabConfig = ShellFabConfig(
      id: 'lotes',
      label: 'Agregar Lote',
      icon: Icons.add,
      heroTag: 'fab_lotes',
      onPressed: _openCreateLotePage,
    );

    return ShellFabConfigScope(
      config: fabConfig,
      child: Scaffold(
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
              l10n: l10n,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLotesContent({
    required BuildContext context,
    required List<LoteEntity> lotes,
    required double listBottomPadding,
    required AppLocalizations l10n,
  }) {
    if (lotes.isEmpty) {
      return _buildEmptyState(context, l10n);
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(10, 2, 10, listBottomPadding),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final lote = lotes[index];
              return _CenteredSection(
                padding: EdgeInsets.zero,
                child: LoteCard(
                  lote: lote,
                  onTap: () => _openLoteDetail(lote),
                  onEdit: () {
                    _openLoteDetail(lote);
                  },
                  onDelete: () {
                    _confirmDeleteLote(lote);
                  },
                ),
              );
            }, childCount: lotes.length),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
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

/// Widget de tarjeta para mostrar un lote
class LoteCard extends StatelessWidget {
  const LoteCard({
    super.key,
    required this.lote,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final LoteEntity lote;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.layers,
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lote.nombre,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (lote.descripcion != null &&
                            lote.descripcion!.isNotEmpty)
                          Text(
                            lote.descripcion!,
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pets, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${lote.animalUuids.length} animal(es)',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatDate(lote.fechaCreacion),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

/// Muestra el sheet para crear un nuevo lote
void showCreateLoteSheet(BuildContext context, AppLocalizations l10n) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _CreateLoteSheet(l10n: l10n),
  );
}

/// Sheet modal para crear lote
class _CreateLoteSheet extends StatefulWidget {
  const _CreateLoteSheet({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_CreateLoteSheet> createState() => _CreateLoteSheetState();
}

class _CreateLoteSheetState extends State<_CreateLoteSheet> {
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _notasController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _descripcionController = TextEditingController();
    _notasController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      context.showErrorSnackBar('Por favor ingresa un nombre para el lote');
      return;
    }

    context.read<LotesBloc>().add(
      CreateLote(
        nombre: nombre,
        descripcion: _descripcionController.text.trim(),
        notas: _notasController.text.trim(),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crear Nuevo Lote',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nombreController,
            decoration: InputDecoration(
              labelText: 'Nombre del lote',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descripcionController,
            decoration: InputDecoration(
              labelText: 'Descripción (opcional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 2,
            controller: _notasController,
            decoration: InputDecoration(
              labelText: 'Notas (opcional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _submitForm,
                  child: const Text('Crear'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
