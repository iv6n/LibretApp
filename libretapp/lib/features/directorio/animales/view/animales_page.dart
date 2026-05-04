/// features \u203a directorio \u203a animales \u203a view \u203a animales_page \u2014 root page for the animal directory tab.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_bloc.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_event.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_event.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/animales/view/animales_list_view.dart';

class AnimalesPage extends StatelessWidget {
  const AnimalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AnimalesBloc(locator<AnimalRepository>())
                ..add(const LoadAnimales()),
        ),
        BlocProvider(
          create: (_) =>
              LotesTabBloc(locator<LotesRepository>())
                ..add(const LoadLotesTab()),
        ),
      ],
      child:
          const AnimalesListView(), // Animal page now only displays animal list.
    );
  }
}
