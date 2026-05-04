/// features \u203a eventos \u203a view \u203a eventos_page \u2014 root page for the eventos feature.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/eventos/bloc/eventos_bloc.dart';
import 'package:libretapp/features/eventos/bloc/eventos_event.dart';
import 'package:libretapp/features/eventos/data/eventos_repository.dart';
import 'package:libretapp/features/eventos/view/eventos_view.dart';

class EventosPage extends StatelessWidget {
  const EventosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          EventosBloc(locator<EventosRepository>())..add(const LoadEventos()),
      child: const EventosView(),
    );
  }
}
