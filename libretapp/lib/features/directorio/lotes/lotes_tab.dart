import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_state.dart';

class LotesTab extends StatefulWidget {
  const LotesTab({super.key});

  @override
  State<LotesTab> createState() => _LotesTabState();
}

class _LotesTabState extends State<LotesTab> {
  @override
  void initState() {
    super.initState();
    context.read<LotesTabBloc>().add(const LoadLotesTab());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LotesTabBloc, LotesTabState>(
      builder: (context, state) {
        if (state is LotesTabLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is LotesTabError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is LotesTabLoaded) {
          final lotes = state.displayLotes;

          if (lotes.isEmpty) {
            return const Center(child: Text('No hay lotes registrados'));
          }

          return ListView.builder(
            itemCount: lotes.length,
            itemBuilder: (context, index) {
              final lote = lotes[index];
              final nombre = _getLoteName(lote);
              return ListTile(
                title: Text(nombre),
                subtitle: Text(_getLoteDescription(lote)),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  String _getLoteName(dynamic lote) {
    if (lote is Map && lote.containsKey('nombre')) {
      return lote['nombre'] as String? ?? 'Sin nombre';
    }
    return 'Lote';
  }

  String _getLoteDescription(dynamic lote) {
    if (lote is Map && lote.containsKey('descripcion')) {
      return lote['descripcion'] as String? ?? '';
    }
    return '';
  }
}
