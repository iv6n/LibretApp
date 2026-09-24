/// features › ubicaciones › view › ubicaciones_page — root page for the ubicaciones feature.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/directorio/cultivos/view/cultivation_usage_scope.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/view/ubicaciones_view.dart';

class UbicacionesPage extends StatelessWidget {
  UbicacionesPage({
    super.key,
    LocationRepository? repository,
    AnimalRepository? animalRepository,
    CultivationRepository? cultivationRepository,
    this.showHeader = true,
    this.shellInteractionsEnabled = true,
  }) : _repository = repository ?? locator<LocationRepository>(),
       _animalRepository =
           animalRepository ??
           (locator.isRegistered<AnimalRepository>()
               ? locator<AnimalRepository>()
               : null),
       _cultivationRepository =
           cultivationRepository ??
           (locator.isRegistered<CultivationRepository>()
               ? locator<CultivationRepository>()
               : null);

  final LocationRepository _repository;
  final AnimalRepository? _animalRepository;
  final CultivationRepository? _cultivationRepository;
  final bool showHeader;
  final bool shellInteractionsEnabled;

  @override
  Widget build(BuildContext context) {
    final content = BlocProvider(
      create: (context) =>
          UbicacionesBloc(_repository, animalRepository: _animalRepository)
            ..add(const LoadUbicaciones()),
      child: UbicacionesView(
        showHeader: showHeader,
        shellInteractionsEnabled: shellInteractionsEnabled,
      ),
    );
    final cultivationRepository = _cultivationRepository;
    if (cultivationRepository == null) return content;
    return StreamBuilder<List<CultivationEntity>>(
      stream: cultivationRepository.watchAll(),
      initialData: const [],
      builder: (context, snapshot) => CultivationUsageScope(
        cultivations: snapshot.data ?? const [],
        child: content,
      ),
    );
  }
}
