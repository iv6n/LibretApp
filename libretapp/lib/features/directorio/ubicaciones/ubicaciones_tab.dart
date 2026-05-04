/// features \u203a directorio \u203a ubicaciones \u203a ubicaciones_tab \u2014 ubicaciones tab widget within the directorio feature.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_state.dart';

class UbicacionesTab extends StatefulWidget {
  const UbicacionesTab({super.key});

  @override
  State<UbicacionesTab> createState() => _UbicacionesTabState();
}

class _UbicacionesTabState extends State<UbicacionesTab> {
  @override
  void initState() {
    super.initState();
    context.read<UbicacionesTabBloc>().add(const LoadUbicacionesTab());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UbicacionesTabBloc, UbicacionesTabState>(
      builder: (context, state) {
        if (state is UbicacionesTabLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is UbicacionesTabError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is UbicacionesTabLoaded) {
          final ubicaciones = state.displayUbicaciones;

          if (ubicaciones.isEmpty) {
            return const Center(child: Text('No hay ubicaciones registradas'));
          }

          return ListView.builder(
            itemCount: ubicaciones.length,
            itemBuilder: (context, index) {
              final ubicacion = ubicaciones[index];
              return ListTile(
                title: Text(ubicacion.name),
                subtitle: Text(ubicacion.status),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
