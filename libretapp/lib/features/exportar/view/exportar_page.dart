/// features › exportar › view › exportar_page — UI for selecting and exporting data.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/export_service.dart';
import 'package:libretapp/features/exportar/cubit/export_cubit.dart';
import 'package:libretapp/features/exportar/widgets/export_selection_panel.dart';

class ExportarPage extends StatelessWidget {
  const ExportarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExportCubit(locator<ExportService>()),
      child: const ExportResultListener(
        child: Scaffold(
          appBar: _ExportarAppBar(),
          body: _ExportarBody(),
        ),
      ),
    );
  }
}

class _ExportarAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ExportarAppBar();

  @override
  Widget build(BuildContext context) => AppBar(title: const Text('Exportar a Excel'));

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ExportarBody extends StatelessWidget {
  const _ExportarBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Selecciona qué datos exportar',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Se generará un archivo .xlsx con una hoja por cada sección seleccionada. '
          'Luego podrás compartirlo por WhatsApp, Telegram, correo u otras apps.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        const Card(child: ExportSelectionPanel()),
      ],
    );
  }
}
