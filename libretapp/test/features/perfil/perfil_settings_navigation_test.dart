import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/theme/theme_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/core/security/ports/phone_auth_port.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/services/theme_repository.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:libretapp/features/perfil/bloc/perfil_bloc.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';
import 'package:libretapp/features/perfil/view/perfil_settings_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _profile = Perfil(
  id: 'local',
  nombre: 'Ana',
  apellido: 'Pérez',
  email: '',
  telefono: '',
  finca: 'El Rancho',
  direccion: '',
);

class _ProfileRepository implements PerfilRepository {
  @override
  Future<Perfil> fetchPerfil() async => _profile;

  @override
  Future<void> savePerfil(Perfil perfil) async {}

  @override
  Future<void> updatePerfil(Perfil perfil) async {}
}

Future<AppExperienceController> _pumpSettings(
  WidgetTester tester, {
  required WorkspaceKind kind,
  double textScale = 1,
}) async {
  await locator.reset();
  SharedPreferences.setMockInitialValues({});
  final prefs = SharedPrefsService(await SharedPreferences.getInstance());
  const guest = LocalWorkspace(id: 'guest', kind: WorkspaceKind.guest);
  final current = switch (kind) {
    WorkspaceKind.guest => guest,
    WorkspaceKind.account => const LocalWorkspace(
      id: 'account',
      kind: WorkspaceKind.account,
      userId: 'user',
      phoneSuffix: '1234',
    ),
    WorkspaceKind.demo => const LocalWorkspace(
      id: 'demo',
      kind: WorkspaceKind.demo,
    ),
  };
  final registry = WorkspaceRegistry(prefs);
  await registry.replace([
    guest,
    if (kind != WorkspaceKind.guest) current,
  ], current.id);
  final manager = WorkspaceManager(
    registry: registry,
    auth: const UnavailablePhoneAuth(),
  );
  locator.registerSingleton<WorkspaceManager>(manager);
  locator.registerSingleton<SharedPrefsService>(prefs);
  final experience = AppExperienceController(
    prefs.scoped(current.preferencePrefix),
    demo: kind == WorkspaceKind.demo,
  );
  addTearDown(experience.dispose);
  final themeBloc = ThemeBloc(repository: ThemeRepository(prefs));
  final profileBloc = PerfilBloc(_ProfileRepository());
  final router = GoRouter(
    initialLocation: '/perfil',
    routes: [
      GoRoute(
        path: '/perfil',
        builder: (_, _) =>
            const Scaffold(body: PerfilSettingsContent(perfil: _profile)),
      ),
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Center(child: Text('Inicio'))),
      ),
    ],
  );
  addTearDown(() async {
    router.dispose();
    await themeBloc.close();
    await profileBloc.close();
    await locator.reset();
  });
  await tester.pumpWidget(
    AppExperienceScope(
      controller: experience,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: themeBloc),
          BlocProvider.value(value: profileBloc),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return experience;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo usa preferencias unificadas en su espacio', (
    tester,
  ) async {
    final preferences = await _pumpSettings(tester, kind: WorkspaceKind.demo);
    await tester.tap(find.text('Qué vas a registrar'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Tu selección prioriza accesos y no oculta las fichas guardadas.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Bovino'));
    await tester.tap(find.text('Guardar').last);
    await tester.pumpAndSettle();
    expect(preferences.value.preferredSpecies, isNot(contains(Species.cattle)));
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('perfil reúne preferencias y respaldos completos', (
    tester,
  ) async {
    final preferences = await _pumpSettings(tester, kind: WorkspaceKind.guest);
    expect(find.text('Qué vas a registrar'), findsOneWidget);
    expect(find.text('Región y producción'), findsOneWidget);
    expect(
      find.text('Plantas y cultivos en accesos sugeridos'),
      findsOneWidget,
    );
    expect(find.text('Exportar respaldo completo'), findsNothing);
    await tester.tap(find.text('Qué vas a registrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bovino'));
    await tester.tap(find.text('Plantas y cultivos').last);
    await tester.tap(find.text('Guardar').last);
    await tester.pumpAndSettle();
    expect(preferences.value.preferredSpecies, isNot(contains(Species.cattle)));
    expect(preferences.value.includePlants, isFalse);

    await tester.ensureVisible(find.text('Datos y respaldos'));
    await tester.tap(find.text('Datos y respaldos'));
    await tester.pumpAndSettle();
    expect(find.text('Exportar respaldo completo'), findsOneWidget);
    expect(find.text('Importar respaldo completo'), findsOneWidget);
    expect(find.text('Exportar a Excel'), findsOneWidget);
    expect(find.text('Importar hato (Excel o CSV)'), findsOneWidget);
  });

  testWidgets('preferencias de registro admiten cualquier combinación', (
    tester,
  ) async {
    final preferences = await _pumpSettings(tester, kind: WorkspaceKind.guest);
    expect(find.text('Avisos del teléfono'), findsOneWidget);
    await tester.tap(find.text('Qué vas a registrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Canino'));
    await tester.tap(find.text('Plantas y cultivos').last);
    await tester.tap(find.text('Guardar').last);
    await tester.pumpAndSettle();
    expect(preferences.value.preferredSpecies, isNot(contains(Species.canine)));
    expect(preferences.value.includePlants, isFalse);
  });

  testWidgets('Cuenta muestra estados de invitado, verificada y demo', (
    tester,
  ) async {
    for (final kind in WorkspaceKind.values) {
      await _pumpSettings(tester, kind: kind);
      final label = switch (kind) {
        WorkspaceKind.guest => 'Espacio de invitado',
        WorkspaceKind.account => 'Número de teléfono verificado',
        WorkspaceKind.demo => 'Espacio de demostración',
      };
      expect(find.text(label), findsOneWidget);
      await tester.ensureVisible(find.text('Cuenta'));
      await tester.tap(find.text('Cuenta'));
      await tester.pumpAndSettle();
      expect(find.text('Cuenta'), findsWidgets);
      expect(
        find.text(switch (kind) {
          WorkspaceKind.guest =>
            'Los registros permanecen locales. Los respaldos automáticos requieren que los actives en Copias en la nube.',
          WorkspaceKind.account => 'Cerrar sesión',
          WorkspaceKind.demo => 'Salir de la demo',
        }),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('demo bloquea respaldos personales y ofrece su escenario', (
    tester,
  ) async {
    await _pumpSettings(tester, kind: WorkspaceKind.demo);
    await Scrollable.ensureVisible(
      tester.element(find.text('Datos y respaldos')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Datos y respaldos'));
    await tester.pumpAndSettle();
    expect(find.text('No disponible en la demo'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Cargar/restablecer escenario demo'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Cargar/restablecer escenario demo'), findsOneWidget);
  });

  testWidgets('texto ampliado deja accesible el último ajuste', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await _pumpSettings(tester, kind: WorkspaceKind.guest, textScale: 2);
    await tester.scrollUntilVisible(
      find.text('Ayuda, privacidad y soporte'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Ayuda, privacidad y soporte'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Qué vas a registrar'),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Qué vas a registrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Qué vas a registrar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      find.text(
        'Tu selección prioriza accesos y no oculta las fichas guardadas.',
      ),
      findsOneWidget,
    );
  });
}
