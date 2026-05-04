/// app › app_router — configures GoRouter for the entire application.
///
/// Defines all named routes, shell routes, and redirect logic.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/app_shell.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/directorio.dart';
import 'package:libretapp/features/eventos/eventos.dart';
import 'package:libretapp/features/finanzas/finanzas.dart';
import 'package:libretapp/features/inicio/inicio.dart';
import 'package:libretapp/features/perfil/perfil.dart';
import 'package:libretapp/features/registro/registro.dart';
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
              path: AppRoutes.eventos,
              name: AppRoutes.nameEventos,
              builder: (context, state) => const EventosPage(),
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
                      child: LocationDetailPage(locationUuid: uuid),
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
            child: const RegistroReproduccionPage(),
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
