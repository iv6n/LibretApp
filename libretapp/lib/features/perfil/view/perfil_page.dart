import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/perfil/bloc/perfil_bloc.dart';
import 'package:libretapp/features/perfil/bloc/perfil_event.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';
import 'package:libretapp/features/perfil/view/perfil_view.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PerfilBloc(locator<PerfilRepository>())..add(const LoadPerfil()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Perfil'), elevation: 0),
        body: const PerfilView(),
      ),
    );
  }
}
