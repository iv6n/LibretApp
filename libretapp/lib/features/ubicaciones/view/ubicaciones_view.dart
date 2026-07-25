/// features › ubicaciones › view › ubicaciones_view — main view for the farm locations list.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/view/ubicaciones_scoped_tab_view.dart';
import 'package:libretapp/features/ubicaciones/view/ubicaciones_search_app_bar.dart';
import 'package:libretapp/features/ubicaciones/widgets/confirm_delete_location_dialog.dart';
import 'package:libretapp/features/ubicaciones/widgets/location_empty_view.dart';
import 'package:libretapp/features/ubicaciones/widgets/ubicaciones_centered_section.dart';
import 'package:libretapp/features/ubicaciones/widgets/ubicaciones_filter_bar.dart';
import 'package:libretapp/features/ubicaciones/widgets/ubicaciones_location_tree.dart';

class UbicacionesView extends StatelessWidget {
  const UbicacionesView({
    super.key,
    this.showHeader = true,
    this.shellInteractionsEnabled = true,
  });

  final bool showHeader;
  final bool shellInteractionsEnabled;

  @override
  Widget build(BuildContext context) {
    // Computed here so MediaQuery changes (keyboard, orientation) always
    // invalidate the padding even when the bloc state hasn't changed.
    final listBottomPadding = ShellInsets.bottomSafePadding(context) + 2;

    // The FAB scope lives outside BlocBuilder so it stays stable. The
    // onPressed reads the current bloc state at press-time instead of
    // capturing selectedUuid at build-time (ShellFabConfig.== ignores onPressed).
    final fabConfig = shellInteractionsEnabled
        ? ShellFabConfig(
            id: 'ubicaciones',
            label: 'Nueva',
            icon: Icons.add,
            heroTag: 'fab_ubicaciones',
            onPressed: () {
              _openCreatePage(context);
            },
          )
        : null;

    final content = BlocBuilder<UbicacionesBloc, UbicacionesState>(
      builder: (context, state) {
        final isSearching = state is UbicacionesLoaded && state.isSearching;
        final scaffold = Scaffold(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showHeader) const UbicacionesSearchAppBar(),
              Expanded(child: _buildBody(context, state, listBottomPadding)),
            ],
          ),
        );

        if (!shellInteractionsEnabled) return scaffold;

        return ShellChromeScope(visible: !isSearching, child: scaffold);
      },
    );

    if (!shellInteractionsEnabled) return content;

    return ShellFabConfigScope(config: fabConfig, child: content);
  }

  Widget _buildBody(
    BuildContext context,
    UbicacionesState state,
    double listBottomPadding,
  ) {
    if (state is UbicacionesInitial || state is UbicacionesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is UbicacionesError) {
      return UbicacionesErrorView(message: state.message);
    }

    if (state is! UbicacionesLoaded) {
      return const SizedBox.shrink();
    }

    // When a root/rancho is selected and not searching, show the tabbed sub-location view.
    final selectedUuid = state.selectedRanchoUuid;
    final isScopedMode =
        selectedUuid != null && !state.isSearching && state.searchQuery.isEmpty;

    if (isScopedMode) {
      final rootLocation = state.allUbicaciones
          .where((l) => l.uuid == selectedUuid)
          .firstOrNull;

      if (rootLocation == null) {
        // Stale UUID (location was deleted) — clear on the next frame and show
        // a brief loader so we don't flash empty-filtered tree state.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.read<UbicacionesBloc>().add(const SelectParentFilter(null));
          }
        });
        return const Center(child: CircularProgressIndicator());
      } else {
        return UbicacionesScopedTabView(
          rootLocation: rootLocation,
          state: state,
          listBottomPadding: listBottomPadding,
          onTap: (location) => _openDetail(context, location.uuid),
          onEdit: (location) {
            _openEditPage(context, location.uuid);
          },
          onDelete: (location) {
            _confirmDelete(context, location);
          },
        );
      }
    }

    final isFiltering =
        state.isSearching ||
        state.searchQuery.isNotEmpty ||
        state.hasActiveFilters;

    final roots = state.treeSnapshot.roots;

    if (roots.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _refresh(context),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (!isFiltering)
              SliverToBoxAdapter(child: UbicacionesFilterBar(state: state)),
            SliverFillRemaining(
              hasScrollBody: false,
              child: UbicacionesCenteredSection(
                padding: EdgeInsets.fromLTRB(16, 12, 16, listBottomPadding),
                child: state.allUbicaciones.isEmpty
                    ? LocationEmptyView(
                        onCreate: () {
                          _openCreatePage(context);
                        },
                      )
                    : const UbicacionesFilteredEmptyView(),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (!isFiltering)
            SliverToBoxAdapter(child: UbicacionesFilterBar(state: state)),
          UbicacionesLocationTree(
            state: state,
            listBottomPadding: listBottomPadding,
            onTap: (location) => _openDetail(context, location.uuid),
            onEdit: (location) {
              _openEditPage(context, location.uuid);
            },
            onDelete: (location) {
              _confirmDelete(context, location);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    context.read<UbicacionesBloc>().add(const LoadUbicaciones());
  }

  void _openDetail(BuildContext context, String uuid) {
    context.push(AppRoutes.ubicacionDetallePath(uuid));
  }

  Future<void> _openCreatePage(BuildContext context) async {
    // Read current selected rancho at press-time so the FAB closure never goes stale.
    final bloc = context.read<UbicacionesBloc>();
    final presetParentUuid = bloc.state is UbicacionesLoaded
        ? (bloc.state as UbicacionesLoaded).selectedRanchoUuid
        : null;

    final created = await context.pushNamed<bool>(
      AppRoutes.nameUbicacionNueva,
      extra: presetParentUuid,
    );
    if (!context.mounted || created != true) return;
    bloc.add(const LoadUbicaciones());
    _showSuccessMessage(context, 'Ubicación creada correctamente');
  }

  Future<void> _openEditPage(BuildContext context, String uuid) async {
    final updated = await context.pushNamed<bool>(
      AppRoutes.nameUbicacionEditar,
      pathParameters: {'uuid': uuid},
    );
    if (!context.mounted || updated != true) return;
    context.read<UbicacionesBloc>().add(const LoadUbicaciones());
    _showSuccessMessage(context, 'Ubicación actualizada correctamente');
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmDelete(
    BuildContext context,
    LocationEntity location,
  ) async {
    final shouldDelete = await confirmDeleteLocation(context, location);
    if (shouldDelete && context.mounted) {
      context.read<UbicacionesBloc>().add(DeleteUbicacion(location.uuid));
    }
  }
}
