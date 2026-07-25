/// features › ubicaciones › widgets › location_empty_view — empty-state view for the locations list.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/widgets/app_empty_state.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';

class LocationEmptyView extends StatelessWidget {
  const LocationEmptyView({super.key, required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.map_outlined,
      title: 'No hay ubicaciones registradas',
      message: 'Agrega tu primera ubicación para empezar a gestionarla.',
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Crear ubicación'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () =>
                context.read<UbicacionesBloc>().add(const LoadUbicaciones()),
            icon: const Icon(Icons.refresh),
            label: const Text('Recargar'),
          ),
        ],
      ),
    );
  }
}

class UbicacionesFilteredEmptyView extends StatelessWidget {
  const UbicacionesFilteredEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.search_off_outlined,
      title: 'Sin coincidencias',
      message: 'Prueba con otros filtros o limpia la búsqueda.',
      action: OutlinedButton.icon(
        onPressed: () =>
            context.read<UbicacionesBloc>().add(const ClearAllFilters()),
        icon: const Icon(Icons.filter_alt_off_outlined),
        label: const Text('Limpiar filtros'),
      ),
    );
  }
}

class UbicacionesErrorView extends StatelessWidget {
  const UbicacionesErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.error_outline,
      title: 'No se pudieron cargar las ubicaciones',
      message: message,
      action: FilledButton.icon(
        onPressed: () =>
            context.read<UbicacionesBloc>().add(const LoadUbicaciones()),
        icon: const Icon(Icons.refresh),
        label: const Text('Reintentar'),
      ),
    );
  }
}
