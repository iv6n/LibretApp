/// features \u203a ubicaciones \u203a view \u203a ubicaciones_page \u2014 root page for the ubicaciones feature.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/view/ubicaciones_view.dart';

class UbicacionesPage extends StatelessWidget {
  UbicacionesPage({super.key, LocationRepository? repository})
    : _repository = repository ?? locator<LocationRepository>();

  final LocationRepository _repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          UbicacionesBloc(_repository)..add(const LoadUbicaciones()),
      child: const UbicacionesView(),
    );
  }
}
