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
import 'package:libretapp/features/directorio/animales/view/quick_register_animal_page.dart';
import 'package:libretapp/features/directorio/animales/view/animal_commercial_form_page.dart';
import 'package:libretapp/features/directorio/directorio.dart';
import 'package:libretapp/features/agenda/agenda.dart';
import 'package:libretapp/features/biblioteca/biblioteca.dart';
import 'package:libretapp/features/finanzas/finanzas.dart';
import 'package:libretapp/features/inicio/inicio.dart';
import 'package:libretapp/features/milking/milking.dart';
import 'package:libretapp/features/perfil/perfil.dart';
import 'package:libretapp/features/reportes/reportes.dart';
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
                      configRepository: DirectorioConfigRepository(
                        locator<SharedPrefsService>(),
                      ),
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
                    child: RegisterAnimalPage(
                      initialSeed: state.extra is AnimalRegistrationSeed
                          ? state.extra! as AnimalRegistrationSeed
                          : null,
                    ),
                  ),
                ),
                GoRoute(
                  path: 'animales/nuevo-rapido',
                  name: AppRoutes.nameAnimalNuevoRapido,
                  pageBuilder: (context, state) => _buildOverlayDetailPage(
                    state: state,
                    child: const QuickRegisterAnimalPage(),
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
                  path: 'animales/:uuid/completar',
                  name: AppRoutes.nameAnimalCompletar,
                  pageBuilder: (context, state) {
                    final uuid = state.pathParameters['uuid'] ?? '';
                    return _buildOverlayDetailPage(
                      state: state,
                      child: RegisterAnimalPage(animalUuid: uuid),
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
                      child: AnimalEditPage(animalUuid: uuid),
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
                      child: AnimalWeightFormPage(
                        animalUuid: uuid,
                        recordId: state.uri.queryParameters['recordId'],
                      ),
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
                      child: AnimalReproductionFormPage(
                        animalUuid: uuid,
                        recordId: state.uri.queryParameters['recordId'],
                      ),
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
                      child: AnimalHealthFormPage(
                        animalUuid: uuid,
                        recordId: state.uri.queryParameters['recordId'],
                      ),
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
                      child: AnimalProductionFormPage(
                        animalUuid: uuid,
                        recordId: state.uri.queryParameters['recordId'],
                      ),
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
                      child: AnimalMovementFormPage(
                        animalUuid: uuid,
                        recordId: state.uri.queryParameters['recordId'],
                      ),
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
                      child: AnimalCommercialFormPage(
                        animalUuid: uuid,
                        recordId: state.uri.queryParameters['recordId'],
                      ),
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
                      child: AnimalCostFormPage(
                        animalUuid: uuid,
                        recordId: state.uri.queryParameters['recordId'],
                      ),
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
                GoRoute(
                  path: 'ubicaciones/nueva',
                  name: AppRoutes.nameUbicacionNueva,
                  pageBuilder: (context, state) {
                    final presetParentUuid = state.extra as String?;
                    return _buildOverlayDetailPage(
                      state: state,
                      child: LocationFormPage(
                        presetParentUuid: presetParentUuid,
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: 'ubicaciones/:uuid',
                  name: AppRoutes.nameUbicacionDetalle,
                  pageBuilder: (context, state) {
                    final uuid = state.pathParameters['uuid'] ?? '';
                    return _buildOverlayDetailPage(
                      state: state,
                      child: BlocProvider(
                        create: (_) => AgendaBloc(
                          locator<AgendaRepository>(),
                          lotesRepository: locator<LotesRepository>(),
                          refreshSignal: locator<AgendaRefreshSignal>(),
                          registrationRepository:
                              locator<AgendaRegistrationRepository>(),
                          registrationReadService:
                              locator<AgendaRegistrationReadService>(),
                        )..add(const LoadAgenda()),
                        child: LocationDetailPage(locationUuid: uuid),
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: 'ubicaciones/:uuid/editar',
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
              path: AppRoutes.agenda,
              name: AppRoutes.nameAgenda,
              builder: (context, state) => BlocProvider(
                create: (_) => AgendaBloc(
                  locator<AgendaRepository>(),
                  lotesRepository: locator<LotesRepository>(),
                  syncService: locator<AgendaReminderSyncService>(),
                  refreshSignal: locator<AgendaRefreshSignal>(),
                  registrationRepository:
                      locator<AgendaRegistrationRepository>(),
                  registrationReadService:
                      locator<AgendaRegistrationReadService>(),
                )..add(const LoadAgenda()),
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
                        create: (_) => AgendaBloc(
                          locator<AgendaRepository>(),
                          lotesRepository: locator<LotesRepository>(),
                          refreshSignal: locator<AgendaRefreshSignal>(),
                          registrationRepository:
                              locator<AgendaRegistrationRepository>(),
                          registrationReadService:
                              locator<AgendaRegistrationReadService>(),
                        ),
                        child: AgendaEntryFormPage(initialDate: initialDate),
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: 'registro',
                  name: AppRoutes.nameAgendaRegistro,
                  pageBuilder: (context, state) {
                    final args = state.extra;
                    if (args is! AgendaRegistrationRouteArgs) {
                      return _buildOverlayDetailPage(
                        state: state,
                        child: const Scaffold(
                          body: Center(
                            child: Text('No se pudo abrir el registro.'),
                          ),
                        ),
                      );
                    }
                    return _buildOverlayDetailPage(
                      state: state,
                      child: BlocProvider.value(
                        value: args.agendaBloc,
                        child: AgendaRegistrationFlowPage(
                          group: args.group,
                          rows: args.rows,
                          animalsById: args.animalsById,
                          existingRegistration: args.existingRegistration,
                        ),
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
                create: (_) => InicioBloc(
                  dashboardService: locator<InicioDashboardService>(),
                  configRepository: locator<DashboardConfigRepository>(),
                  financeService: locator<FinanceSummaryService>(),
                  libraryRepository: locator<LibraryRepository>(),
                )..add(const LoadInicio()),
                child: const InicioPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.reportes,
              name: AppRoutes.nameReportes,
              builder: (context, state) => const ReportesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.perfil,
              name: AppRoutes.namePerfil,
              builder: (context, state) => const PerfilPage(),
              routes: [
                GoRoute(
                  path: 'biblioteca/:id',
                  name: AppRoutes.namePerfilBibliotecaItem,
                  pageBuilder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return _buildOverlayDetailPage(
                      state: state,
                      child: BookDetailPage(
                        bookId: id,
                        initialManifestBook: state.extra is LibraryManifestBook
                            ? state.extra! as LibraryManifestBook
                            : null,
                      ),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: ':chapterId',
                      name: AppRoutes.namePerfilBibliotecaCapitulo,
                      pageBuilder: (context, state) {
                        final args = state.extra;
                        return _buildOverlayDetailPage(
                          state: state,
                          child: args is ChapterReaderArgs
                              ? ChapterReaderPage(args: args)
                              : _ChapterNotFoundPage(
                                  bookId: state.pathParameters['id'] ?? '',
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.ubicacionesLegacy,
      redirect: (context, state) => AppRoutes.directorioUbicacionesPath(),
    ),
    GoRoute(
      path: '${AppRoutes.ubicacionesLegacy}/nueva',
      redirect: (context, state) => AppRoutes.ubicacionNuevaPath(),
    ),
    GoRoute(
      path: '${AppRoutes.ubicacionesLegacy}/:uuid/editar',
      redirect: (context, state) {
        final uuid = state.pathParameters['uuid'] ?? '';
        return AppRoutes.ubicacionEditarPath(uuid);
      },
    ),
    GoRoute(
      path: '${AppRoutes.ubicacionesLegacy}/:uuid',
      redirect: (context, state) {
        final uuid = state.pathParameters['uuid'] ?? '';
        return AppRoutes.ubicacionDetallePath(uuid);
      },
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
          path: 'ordena',
          name: AppRoutes.nameRegistroOrdena,
          pageBuilder: (context, state) => _buildOverlayDetailPage(
            state: state,
            child: RegistroOrdenaPage(
              initialAnimalUuid: state.uri.queryParameters['animalUuid'],
            ),
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
        GoRoute(
          path: 'tratar-lote',
          name: AppRoutes.nameRegistroTratarLote,
          pageBuilder: (context, state) => _buildOverlayDetailPage(
            state: state,
            child: const BulkHealthRegistroPage(),
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

/// Reached only via a direct deep link into a chapter without going through
/// [BookDetailPage] first (normal in-app navigation always supplies
/// [ChapterReaderArgs] via `extra`, since the book's content is already in
/// memory at that point).
class _ChapterNotFoundPage extends StatelessWidget {
  const _ChapterNotFoundPage({required this.bookId});
  final String bookId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capítulo no disponible')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Abre este capítulo desde el libro para cargarlo.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.pushNamed(
                  AppRoutes.namePerfilBibliotecaItem,
                  pathParameters: {'id': bookId},
                ),
                child: const Text('Ir al libro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
