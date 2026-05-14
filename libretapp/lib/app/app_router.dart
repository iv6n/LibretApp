/// app › app_router — configures GoRouter for the entire application.
///
/// Defines all named routes, shell routes, and redirect logic.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/app_shell.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/view/animal_weight_form_page.dart';
import 'package:libretapp/features/directorio/animales/view/animal_cost_form_page.dart';
import 'package:libretapp/features/directorio/animales/view/animal_production_form_page.dart';
import 'package:libretapp/features/directorio/animales/view/animal_movement_form_page.dart';
import 'package:libretapp/features/directorio/animales/view/animal_reproduction_form_page.dart';
import 'package:libretapp/features/directorio/animales/view/animal_health_form_page.dart';
import 'package:libretapp/features/directorio/animales/view/animal_commercial_form_page.dart';
import 'package:libretapp/features/directorio/directorio.dart';
import 'package:libretapp/features/agenda/agenda.dart';
import 'package:libretapp/features/finanzas/finanzas.dart';
import 'package:libretapp/features/inicio/inicio.dart';
import 'package:libretapp/features/perfil/perfil.dart';
import 'package:libretapp/features/registro/registro.dart';
import 'package:libretapp/features/exportar/exportar.dart';
import 'package:libretapp/features/ubicaciones/ubicaciones.dart';

final router = GoRouter(
  observers: [NavigationTracer.observer],
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.directorio,
              name: AppRoutes.nameDirectorio,
              builder: (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) =>
                        AnimalesBloc(locator<AnimalRepository>())
                          ..add(const LoadAnimales()),
                  ),
                  BlocProvider(
                    create: (_) => AnimalesTabBloc(locator<AnimalRepository>()),
                  ),
                  BlocProvider(
                    create: (_) => LotesBloc(locator<LotesRepository>()),
                  ),
                  BlocProvider(
                    create: (_) => LotesTabBloc(locator<LotesRepository>()),
                  ),
                  BlocProvider(
                    create: (_) =>
                        UbicacionesTabBloc(locator<LocationRepository>()),
                  ),
                  BlocProvider(
                    create: (context) => DirectorioBloc(
                      animalesTabBloc: context.read<AnimalesTabBloc>(),
                      lotesTabBloc: context.read<LotesTabBloc>(),
                      ubicacionesTabBloc: context.read<UbicacionesTabBloc>(),
                    ),
                  ),
                ],
                child: const DirectorioView(),
              ),
              routes: [
                GoRoute(
                  path: 'animales/nuevo',
                  name: AppRoutes.nameAnimalNuevo,
                  pageBuilder: (context, state) => _buildOverlayDetailPage(
                    state: state,
                    child: const RegisterAnimalPage(),
                  ),
                ),
                GoRoute(
                  path: 'lotes/nuevo',
                  name: AppRoutes.nameLoteNuevo,
                  pageBuilder: (context, state) => _buildOverlayDetailPage(
                    state: state,
                    child: LoteFormPage(),
                  ),
                ),
                GoRoute(
                  path: 'animales/:uuid',
                  name: AppRoutes.nameAnimalDetalle,
                  pageBuilder: (context, state) {
                    final uuid = state.pathParameters['uuid'] ?? '';
                    return _buildOverlayDetailPage(
                      state: state,
                      child: BlocProvider(
                        create: (_) => AnimalBloc(
                          animalRepository: locator<AnimalRepository>(),
                          lotesRepository: locator<LotesRepository>(),
                          weightRepo: locator<WeightRecordRepository>(),
                          healthRepo: locator<HealthRecordRepository>(),
                          productionRepo: locator<ProductionRecordRepository>(),
                          reproductionRepo:
                              locator<ReproductionRecordRepository>(),
                          commercialRepo: locator<CommercialRecordRepository>(),
                          movementRepo: locator<MovementRecordRepository>(),
                          costRepo: locator<CostRecordRepository>(),
                        ),
                        child: AnimalDetailPage(animalUuid: uuid),
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: 'animales/:uuid/editar',
                  name: AppRoutes.nameAnimalEditar,
                  pageBuilder: (context, state) {
                    final uuid = state.pathParameters['uuid'] ?? '';
                    return _buildOverlayDetailPage(
                      state: state,
                      child: RegisterAnimalPage(animalUuid: uuid),
                    );
                  },
                ),
                GoRoute(
                  path: 'animales/:uuid/registros/peso',
                  name: AppRoutes.nameAnimalRegistroPeso,
                  pageBuilder: (context, state) {
                    final uuid = state.pathParameters['uuid'] ?? '';
                    return _buildOverlayDetailPage(
                      state: state,
                      child: AnimalWeightFormPage(animalUuid: uuid),
                    );
                  },
                ),
                GoRoute(
                  path: 'animales/:uuid/registros/reproduccion',
                  name: AppRoutes.nameAnimalRegistroReproduccion,
                  pageBuilder: (context, state) {
                    final uuid = state.pathParameters['uuid'] ?? '';
                    return _buildOverlayDetailPage(
                      state: state,
                      child: AnimalReproductionFormPage(animalUuid: uuid),
                    );
                  },
                ),
                GoRoute(
                  path: 'animales/:uuid/registros/salud',
                  name: AppRoutes.nameAnimalRegistroSalud,
                  pageBuilder: (context, state) {
                    final uuid = state.pathParameters['uuid'] ?? '';
                    return _buildOverlayDetailPage(
                      state: state,
                      child: AnimalHealthFormPage(animalUuid: uuid),
                    );
                  },
                ),
                GoRoute(
                  path: 'animales/:uuid/registros/produccion',
                  name: AppRoutes.nameAnimalRegistroProduccion,
                  pageBuilder: (context, state) {
                    final uuid = state.pathParameters['uuid'] ?? '';
                    return _buildOverlayDetailPage(
                      state: state,
                      child: AnimalProductionFormPage(animalUuid: uuid),
                    );
                  },
                ),
                GoRoute(
                  path: 'animales/:uuid/registros/movimiento',
                  name: AppRoutes.nameAnimalRegistroMovimiento,
                  pageBuilder: (context, state) {
                    final uuid = state.pathParameters['uuid'] ?? '';
                    return _buildOverlayDetailPage(
                      state: state,
                      child: AnimalMovementFormPage(animalUuid: uuid),
                    );
                  },
                ),
                GoRoute(
                  path: 'animales/:uuid/registros/comercial',
                  name: AppRoutes.nameAnimalRegistroComercial,
                  pageBuilder: (context, state) {
                    final uuid = state.pathParameters['uuid'] ?? '';
                    return _buildOverlayDetailPage(
                      state: state,
                      child: AnimalCommercialFormPage(animalUuid: uuid),
                    );
                  },
                ),
                GoRoute(
                  path: 'animales/:uuid/registros/costo',
                  name: AppRoutes.nameAnimalRegistroCosto,
                  pageBuilder: (context, state) {
                    final uuid = state.pathParameters['uuid'] ?? '';
                    return _buildOverlayDetailPage(
                      state: state,
                      child: AnimalCostFormPage(animalUuid: uuid),
                    );
                  },
                ),
                GoRoute(
                  path: 'lotes/:uuid/editar',
                  name: AppRoutes.nameLoteEditar,
                  pageBuilder: (context, state) {
                    final uuid = state.pathParameters['uuid'] ?? '';
                    return _buildOverlayDetailPage(
                      state: state,
                      child: LoteFormPage(loteUuid: uuid),
                    );
                  },
                ),
                GoRoute(
                  path: 'lotes/:uuid',
                  name: AppRoutes.nameLoteDetalle,
                  pageBuilder: (context, state) {
                    final uuid = state.pathParameters['uuid'] ?? '';
                    return _buildOverlayDetailPage(
                      state: state,
                      child: LoteDetailPage(loteUuid: uuid),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.agenda,
              name: AppRoutes.nameAgenda,
              builder: (context, state) => BlocProvider(
                create: (_) =>
                    AgendaBloc(locator<AgendaRepository>())
                      ..add(const LoadAgenda()),
                child: const AgendaPage(),
              ),
              routes: [
                GoRoute(
                  path: 'nuevo',
                  name: AppRoutes.nameAgendaNuevo,
                  pageBuilder: (context, state) {
                    final dateParam = state.uri.queryParameters['date'];
                    final initialDate =
                        DateTime.tryParse(dateParam ?? '') ?? DateTime.now();
                    return _buildOverlayDetailPage(
                      state: state,
                      child: BlocProvider(
                        create: (_) => AgendaBloc(locator<AgendaRepository>()),
                        child: AgendaEntryFormPage(initialDate: initialDate),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.inicio,
              name: AppRoutes.nameInicio,
              builder: (context, state) => BlocProvider(
                create: (_) =>
                    InicioBloc(locator<InicioDashboardService>())
                      ..add(const LoadInicio()),
                child: const InicioPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.ubicaciones,
              name: AppRoutes.nameUbicaciones,
              builder: (context, state) => UbicacionesPage(),
              routes: [
                GoRoute(
                  path: 'nueva',
                  name: AppRoutes.nameUbicacionNueva,
                  pageBuilder: (context, state) => _buildOverlayDetailPage(
                    state: state,
                    child: const LocationFormPage(),
                  ),
                ),
                GoRoute(
                  path: ':uuid',
                  name: AppRoutes.nameUbicacionDetalle,
                  pageBuilder: (context, state) {
                    final uuid = state.pathParameters['uuid'] ?? '';
                    return _buildOverlayDetailPage(
                      state: state,
                      child: BlocProvider(
                        create: (_) =>
                            AgendaBloc(locator<AgendaRepository>())
                              ..add(const LoadAgenda()),
                        child: LocationDetailPage(locationUuid: uuid),
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: ':uuid/editar',
                  name: AppRoutes.nameUbicacionEditar,
                  pageBuilder: (context, state) {
                    final uuid = state.pathParameters['uuid'] ?? '';
                    return _buildOverlayDetailPage(
                      state: state,
                      child: LocationFormPage(locationUuid: uuid),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.perfil,
              name: AppRoutes.namePerfil,
              builder: (context, state) => const PerfilPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.registro,
      name: AppRoutes.nameRegistro,
      pageBuilder: (context, state) =>
          _buildOverlayDetailPage(state: state, child: const RegistroPage()),
      routes: [
        GoRoute(
          path: 'sanitario',
          name: AppRoutes.nameRegistroSanitario,
          pageBuilder: (context, state) => _buildOverlayDetailPage(
            state: state,
            child: const RegistroSanitarioPage(),
          ),
        ),
        GoRoute(
          path: 'peso',
          name: AppRoutes.nameRegistroPeso,
          pageBuilder: (context, state) => _buildOverlayDetailPage(
            state: state,
            child: const RegistroPesoPage(),
          ),
        ),
        GoRoute(
          path: 'produccion',
          name: AppRoutes.nameRegistroProduccion,
          pageBuilder: (context, state) => _buildOverlayDetailPage(
            state: state,
            child: const RegistroProduccionPage(),
          ),
        ),
        GoRoute(
          path: 'reproduccion',
          name: AppRoutes.nameRegistroReproduccion,
          pageBuilder: (context, state) => _buildOverlayDetailPage(
            state: state,
            child: RegistroReproduccionPage(
              preset: state.uri.queryParameters['preset'],
            ),
          ),
        ),
        GoRoute(
          path: 'comercial',
          name: AppRoutes.nameRegistroComercial,
          pageBuilder: (context, state) => _buildOverlayDetailPage(
            state: state,
            child: const RegistroComercialPage(),
          ),
        ),
        GoRoute(
          path: 'movimiento',
          name: AppRoutes.nameRegistroMovimiento,
          pageBuilder: (context, state) => _buildOverlayDetailPage(
            state: state,
            child: const RegistroMovimientoPage(),
          ),
        ),
        GoRoute(
          path: 'costo',
          name: AppRoutes.nameRegistroCosto,
          pageBuilder: (context, state) => _buildOverlayDetailPage(
            state: state,
            child: const RegistroCostoPage(),
          ),
        ),
        GoRoute(
          path: 'ingreso',
          name: AppRoutes.nameRegistroIngreso,
          pageBuilder: (context, state) => _buildOverlayDetailPage(
            state: state,
            child: const RegistroIngresoPage(),
          ),
        ),
        GoRoute(
          path: 'gasto-general',
          name: AppRoutes.nameRegistroGastoGeneral,
          pageBuilder: (context, state) => _buildOverlayDetailPage(
            state: state,
            child: const RegistroGastoGeneralPage(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.finanzas,
      name: AppRoutes.nameFinanzas,
      pageBuilder: (context, state) =>
          _buildOverlayDetailPage(state: state, child: const FinanzasPage()),
    ),
    GoRoute(
      path: AppRoutes.exportar,
      name: AppRoutes.nameExportar,
      pageBuilder: (context, state) =>
          _buildOverlayDetailPage(state: state, child: const ExportarPage()),
    ),
  ],
);

CustomTransitionPage<void> _buildOverlayDetailPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: UiConstants.modalTransitionDuration,
    reverseTransitionDuration: UiConstants.modalReverseTransitionDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}
