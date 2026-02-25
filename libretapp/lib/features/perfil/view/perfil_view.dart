import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/app/theme/theme_bloc.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/features/perfil/bloc/perfil_bloc.dart';
import 'package:libretapp/features/perfil/bloc/perfil_state.dart';
import 'package:libretapp/features/perfil/widgets/widgets.dart';

class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = ShellInsets.bottomSafePadding(context);

    return BlocBuilder<PerfilBloc, PerfilState>(
      builder: (context, state) {
        if (state is PerfilLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PerfilLoaded || state is PerfilUpdated) {
          final perfil = state is PerfilLoaded
              ? state.perfil
              : (state as PerfilUpdated).perfil;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 2),
            child: Column(
              children: [
                const ProfileAvatar(),
                const SizedBox(height: 16),
                Text(
                  '${perfil.nombre} ${perfil.apellido}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                ProfileField(label: 'Email', value: perfil.email),
                const SizedBox(height: 16),
                ProfileField(label: 'Teléfono', value: perfil.telefono),
                const SizedBox(height: 16),
                ProfileField(label: 'Finca', value: perfil.finca),
                const SizedBox(height: 16),
                ProfileField(label: 'Dirección', value: perfil.direccion),
                const SizedBox(height: 32),
                const _ThemeToggleTile(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Editar Perfil'),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is PerfilError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ThemeToggleTile extends StatelessWidget {
  const _ThemeToggleTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDark = state.themeMode == ThemeMode.dark;
        return SwitchListTile(
          title: const Text('Tema oscuro'),
          subtitle: const Text('Activa o desactiva el modo oscuro'),
          value: isDark,
          onChanged: (_) => context.read<ThemeBloc>().add(
            ThemeModeChanged(isDark ? ThemeMode.light : ThemeMode.dark),
          ),
        );
      },
    );
  }
}
