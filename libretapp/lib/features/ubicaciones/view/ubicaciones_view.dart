import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/widgets/widgets.dart';
import 'package:libretapp/app/app_shell.dart';

class UbicacionesView extends StatefulWidget {
  const UbicacionesView({super.key});

  @override
  State<UbicacionesView> createState() => _UbicacionesViewState();
}

class _UbicacionesViewState extends State<UbicacionesView> {
  final TextEditingController _searchController = TextEditingController();
  late final AnimalRepository _animalRepository;
  Map<String, int> _animalCounts = <String, int>{};

  @override
  void initState() {
    super.initState();
    _animalRepository = locator<AnimalRepository>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshCounts(List<LocationEntity> locations) async {
    final ids = locations.map((e) => e.uuid).toSet();
    final animals = await _animalRepository.getAll();
    final counts = <String, int>{};
    for (final animal in animals) {
      final locId = animal.currentPaddockId ?? animal.initialLocationId;
      if (locId == null || !ids.contains(locId)) continue;
      counts[locId] = (counts[locId] ?? 0) + 1;
    }

    if (!mounted) return;
    setState(() => _animalCounts = counts);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = AppShell.bottomSafePadding(context);
    final fabBottomPadding = AppShell.fabDockPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicaciones'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<UbicacionesBloc>().add(const LoadUbicaciones()),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(76),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: LocationSearchBar(
              controller: _searchController,
              onChanged: (value) {
                if (value.trim().isEmpty) {
                  context.read<UbicacionesBloc>().add(const LoadUbicaciones());
                } else {
                  context.read<UbicacionesBloc>().add(SearchUbicaciones(value));
                }
              },
            ),
          ),
        ),
      ),
      body: BlocConsumer<UbicacionesBloc, UbicacionesState>(
        listener: (context, state) {
          if (state is UbicacionesError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is UbicacionesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UbicacionesLoaded) {
            _refreshCounts(state.ubicaciones);
            if (state.ubicaciones.isEmpty) {
              return const LocationEmptyView();
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<UbicacionesBloc>().add(const LoadUbicaciones()),
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset + 2),
                itemCount: state.ubicaciones.length,
                separatorBuilder: (context, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final ubicacion = state.ubicaciones[index];
                  return LocationCard(
                    location: ubicacion,
                    animalCount: _animalCounts[ubicacion.uuid] ?? 0,
                    onEdit: () => _openForm(context, initial: ubicacion),
                    onDelete: () => _confirmDelete(context, ubicacion),
                  );
                },
              ),
            );
          }

          if (state is UbicacionesError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: fabBottomPadding),
        child: FloatingActionButton.extended(
          onPressed: () => _openForm(context),
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('Agregar'),
        ),
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context, {
    LocationEntity? initial,
  }) async {
    final created = await showModalBottomSheet<LocationEntity>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: LocationFormSheet(initial: initial),
      ),
    );

    if (!context.mounted || created == null) return;
    context.read<UbicacionesBloc>().add(UpsertUbicacion(created));
  }

  Future<void> _confirmDelete(
    BuildContext context,
    LocationEntity location,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ubicación'),
        content: Text(
          '¿Deseas borrar "${location.name}"? Esta acción no se puede deshacer.',
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

    if (shouldDelete == true && context.mounted) {
      context.read<UbicacionesBloc>().add(DeleteUbicacion(location.uuid));
    }
  }
}
