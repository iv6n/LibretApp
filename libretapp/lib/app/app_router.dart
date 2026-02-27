import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/app_shell.dart';
import 'package:libretapp/core/core.dart';
import 'package:libretapp/features/directorio/directorio.dart';
import 'package:libretapp/features/eventos/eventos.dart';
import 'package:libretapp/features/inicio/inicio.dart';
import 'package:libretapp/features/perfil/perfil.dart';
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
                  path: 'animales/:uuid',
                  name: AppRoutes.nameAnimalDetalle,
                  builder: (context, state) {
                    final uuid = state.pathParameters['uuid'] ?? '';
                    return BlocProvider(
                      create: (_) => AnimalBloc(
                        animalRepository: locator<AnimalRepository>(),
                        lotesRepository: locator<LotesRepository>(),
                      ),
                      child: AnimalDetailPage(animalUuid: uuid),
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
              builder: (context, state) => const InicioPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.ubicaciones,
              name: AppRoutes.nameUbicaciones,
              builder: (context, state) => UbicacionesPage(),
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
  ],
);
