import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/animales/bloc/animales_bloc.dart';
import 'package:libretapp/features/animales/bloc/animales_event.dart';
import 'package:libretapp/features/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/animales/view/animales_list_view.dart';

class AnimalesPage extends StatelessWidget {
  const AnimalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AnimalesBloc(locator<AnimalRepository>())..add(const LoadAnimales()),
      child: const AnimalesListView(),
    );
  }
}
