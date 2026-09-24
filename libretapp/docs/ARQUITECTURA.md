# Arquitectura y guía de limpieza

## Visión general
- App Flutter modular con barriles para reducir imports: core/, app/, features/, theme/, l10n/. Refactor documentado en [REFACTORING_SUMMARY.md](../REFACTORING_SUMMARY.md).
- Stack: GoRouter para navegación, flutter_bloc + Equatable para estado, GetIt para DI, Isar móvil, Drift/SQLite WASM web, SharedPreferences para settings, theming M3 e i18n generada.
- Entrada en [lib/main.dart](../lib/main.dart): inicializa bindings, sistema UI edge-to-edge, trazadores de rendimiento opcionales, DI (`setupLocator`) y levanta `LibretApp` con `AppBloc` y `ThemeBloc`.

## Arranque, DI y trazas
- DI central con selección de plataforma en [lib/core/di/injection.dart](../lib/core/di/injection.dart): móvil conserva Isar y Web usa Drift; ambos registran los contratos compartidos de finca, sincronización y módulos operativos.
- `AppBloc` en [lib/app/app_bloc.dart](../lib/app/app_bloc.dart): arranque, migración de lotes opcional, resolución/guardar idioma.
- `ThemeBloc` en [lib/app/theme/theme_bloc.dart](../lib/app/theme/theme_bloc.dart): carga/guarda `ThemeMode`, fallback al brillo del sistema.
- Performance hooks: `PerformanceMonitor`, `InteractionTracer`, `NavigationTracer` instanciados en [lib/main.dart](../lib/main.dart) cuando hay debug/profile.

## Navegación y shell
- Router en [lib/app/app_router.dart](../lib/app/app_router.dart) con `GoRouter` + `StatefulShellRoute` de 5 pestañas (directorio, eventos, inicio, ubicaciones, perfil). Observador de navegación: `NavigationTracer`.
- Shell visual en [lib/app/app_shell.dart](../lib/app/app_shell.dart): scaffold con bottom nav personalizado y FAB configurable por rama; maneja visibilidad de chrome y FAB por pestaña, con caches por índice.
- Rutas nombradas centralizadas en [lib/core/router/app_routes.dart](../lib/core/router/app_routes.dart) exportadas vía `core/core.dart`.

## Estado y módulos
- Patrón BLoC + Equatable en app y features. Ejemplos globales: `AppBloc`, `ThemeBloc`. Feature directorio coordina varios blocs: `AnimalesBloc`, `AnimalesTabBloc`, `LotesBloc`, `LotesTabBloc`, `UbicacionesTabBloc`, `DirectorioBloc` (ver [lib/features/directorio/directorio.dart](../lib/features/directorio/directorio.dart)).
- Barriles clave: `core/core.dart`, `app/app_index.dart`, `theme/theme.dart`, `features/*/*.dart` para imports limpios.

## Datos y persistencia
- Persistencia local móvil en [lib/core/database/isar_database.dart](../lib/core/database/isar_database.dart) y contrato compartido en [lib/core/persistence/feature_record_store.dart](../lib/core/persistence/feature_record_store.dart); Web abre Drift con SQLite WASM. SharedPreferences conserva settings y estado de respaldo.
- Los módulos nuevos persisten por UUID, `farmId`, revisión, soft-delete y payload versionado. Animales Web ya usa el mismo contrato; las colecciones legacy restantes se migran progresivamente.
- Seeding/migración descrita en [IMPLEMENTATION_SUMMARY.md](../IMPLEMENTATION_SUMMARY.md).

## Theming y UX chrome
- Temas M3 en [lib/theme/app_theme.dart](../lib/theme/app_theme.dart) exportados por [lib/theme/theme.dart](../lib/theme/theme.dart); define paletas, spacing/radii, tipografía, `ShellChromeTheme` para nav/FAB.
- `MyApp` en [lib/app/app.dart](../lib/app/app.dart): `MaterialApp.router` con locales soportados, `AppTheme.lightTheme`/`darkTheme`, overlay scrim inferior para edge-to-edge, `ResponsiveScaler` (exportado en core widgets).
- Componentes shell/nav/FAB en [lib/app/widgets/widgets.dart](../lib/app/widgets/widgets.dart) y subcomponentes.

## Internacionalización y recursos
- Delegados y locales generados en [lib/l10n](../lib/l10n); selección de idioma via `AppBloc` (persistida en prefs).
- Assets configurados en [pubspec.yaml](../pubspec.yaml): WEBP de ejecución en
  `assets/images/` y maestros PNG 2.5D en `assets/icons_25d_source/`.

## Convenciones de código y módulos
- Lints base: [analysis_options.yaml](../analysis_options.yaml) incluye `flutter_lints`. Sugeridos para endurecer: `prefer_single_quotes`, `sort_constructors_first`, `unawaited_futures`, `prefer_const_constructors`, `exhaustive_switch`, `public_member_api_docs` en core.
- Imports: usar barriles por módulo (core/core.dart, app/app_index.dart, theme/theme.dart, features/*/*.dart). Evitar imports relativos largos; si un símbolo no está en el barril, expórtalo allí.
- Capas: presentación (widgets/screens), aplicación (blocs), dominio (contratos/repos/servicios), infraestructura (Isar/remote). No acceder a infraestructura desde UI sin pasar por aplicación/dominio.
- Rutas: centralizar paths/nombres en `AppRoutes` y navegar por nombre. Mantener llaves de GoRouter en un solo lugar.
- DI: toda instancia global en `setupLocator`; evitar `GetIt` directo en widgets si se puede inyectar vía constructor/BLoC.

## Oportunidades de limpieza y reutilización
- Reducir responsabilidad de repos grandes (p.ej. `animal_repository_isar`): extraer DTOs/servicios de seeding y helpers de consulta para legibilidad/test.
- Documentar contratos de repositorios (inputs/outputs, errores) y políticas de sync/mock vs prod.
- Añadir pruebas unitarias para blocs (`AppBloc`, `ThemeBloc`, directorio tabs) y repos Isar usando isar in-memory; actualmente solo existe el test por defecto en [test/widget_test.dart](../test/widget_test.dart).
- Endurecer lints: orden de imports, `unawaited_futures`, `prefer_const_constructors`, `exhaustive_switch`, `public_member_api_docs` para módulos core.
- Añadir guía de navegación/FAB: cuándo mostrar/ocultar chrome y qué pestañas pueden registrar FAB (`AppShell` bloquea en índices 3 y 5).
- README es genérico; alinear con este doc e incluir setup (Flutter/Dart versions, `flutter pub get`, `flutter gen-l10n`, seeds Isar).

## Backlog técnico sugerido
- Tests: suites para blocs de directorio y repos de datos (streams de Isar), pruebas de router (GoRouter) y visibilidad de chrome/FAB.
- Observabilidad: activar `PerformanceMonitor.attachFrameTimings` con flag y log level configurable.
- Seguridad de datos: validar migraciones/seeding idempotentes y documentar estrategia de borrado/reset.
- UX: definir flujo de búsqueda y tap en resultados en directorio (hay TODO implícito en vistas) y registrar comportamiento de botón central (home/registrar).
