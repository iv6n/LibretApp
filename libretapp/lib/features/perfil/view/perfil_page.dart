/// features › perfil › view › perfil_page — root page for the user profile feature.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/biblioteca/cubit/biblioteca_cubit.dart';
import 'package:libretapp/features/biblioteca/data/library_repository.dart';
import 'package:libretapp/features/perfil/bloc/perfil_bloc.dart';
import 'package:libretapp/features/perfil/bloc/perfil_event.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';
import 'package:libretapp/features/perfil/view/perfil_view.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              PerfilBloc(locator<PerfilRepository>())..add(const LoadPerfil()),
        ),
        BlocProvider(
          create: (_) => BibliotecaCubit(
            libraryRepository: locator<LibraryRepository>(),
          ),
        ),
      ],
      child: const Scaffold(body: PerfilView()),
    );
  }
}
