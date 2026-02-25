import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/app_shell.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/performance/navigation_tracer.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/animales/application/bloc/animal_bloc.dart';
import 'package:libretapp/features/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/animales/view/animal_detail_page.dart';
import 'package:libretapp/features/animales/view/animales_page.dart';
import 'package:libretapp/features/eventos/view/eventos_page.dart';
import 'package:libretapp/features/inicio/view/inicio_page.dart';
import 'package:libretapp/features/perfil/view/perfil_page.dart';
import 'package:libretapp/features/ubicaciones/view/ubicaciones_page.dart';

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
              path: AppRoutes.animales,
              name: AppRoutes.nameAnimales,
              builder: (context, state) => const AnimalesPage(),
              routes: [
                GoRoute(
                  path: AppRoutes.animalDetalleRelative,
                  name: AppRoutes.nameAnimalDetalle,
                  pageBuilder: (context, state) {
                    final child = ShellChromeScope(
                      visible: false,
                      child: BlocProvider(
                        create: (_) => AnimalBloc(
                          animalRepository: locator<AnimalRepository>(),
                        ),
                        child: AnimalDetailPage(
                          animalUuid: state.pathParameters['uuid']!,
                          showQuickActions: false,
                        ),
                      ),
                    );

                    return CustomTransitionPage<void>(
                      key: state.pageKey,
                      transitionDuration: const Duration(milliseconds: 260),
                      reverseTransitionDuration:
                          const Duration(milliseconds: 220),
                      opaque: true,
                      child: child,
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        final slide = Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).chain(
                          CurveTween(curve: Curves.easeOutCubic),
                        );
                        return SlideTransition(
                          position: animation.drive(slide),
                          child: child,
                        );
                      },
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
