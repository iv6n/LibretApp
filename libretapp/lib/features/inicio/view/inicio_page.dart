import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/inicio/bloc/inicio_bloc.dart';
import 'package:libretapp/features/inicio/bloc/inicio_event.dart';
import 'package:libretapp/features/inicio/bloc/inicio_state.dart';
import 'package:libretapp/features/inicio/view/inicio_view.dart';
import 'package:libretapp/l10n/app_localizations.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navHome),
        elevation: 0,
        actions: [
          BlocBuilder<InicioBloc, InicioState>(
            buildWhen: (previous, current) =>
                previous.isLoading != current.isLoading,
            builder: (context, state) {
              if (state.isLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              return IconButton(
                tooltip: 'Actualizar panel',
                onPressed: () {
                  context.read<InicioBloc>().add(const RefreshInicio());
                },
                icon: const Icon(Icons.refresh),
              );
            },
          ),
        ],
      ),
      body: const InicioView(),
    );
  }
}
