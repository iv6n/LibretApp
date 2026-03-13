import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/bloc/directorio_state.dart';
import 'package:libretapp/features/directorio/view/directorio_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('openDirectorioSearchResult', () {
    testWidgets('navigates to animal detail route', (tester) async {
      final router = _buildRouter();

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('trigger-animal')));
      await tester.pumpAndSettle();

      expect(find.text('animal:animal-1'), findsOneWidget);
    });

    testWidgets('navigates to lote detail route', (tester) async {
      final router = _buildRouter();

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('trigger-lote')));
      await tester.pumpAndSettle();

      expect(find.text('lote:lote-1'), findsOneWidget);
    });

    testWidgets('navigates to ubicacion detail route', (tester) async {
      final router = _buildRouter();

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('trigger-ubicacion')));
      await tester.pumpAndSettle();

      expect(find.text('ubicacion:ubicacion-1'), findsOneWidget);
    });

    testWidgets('does not crash when target route is missing', (tester) async {
      final router = _buildRouterWithoutAnimalRoute();

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('trigger-animal')));
      await tester.pumpAndSettle();

      expect(find.byType(_SearchTriggerView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const _SearchTriggerView(),
      ),
      GoRoute(
        path: '/directorio/animales/:uuid',
        name: AppRoutes.nameAnimalDetalle,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'] ?? '';
          return _TargetPage(text: 'animal:$uuid');
        },
      ),
      GoRoute(
        path: '/directorio/lotes/:uuid',
        name: AppRoutes.nameLoteDetalle,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'] ?? '';
          return _TargetPage(text: 'lote:$uuid');
        },
      ),
      GoRoute(
        path: '/ubicaciones/:uuid',
        name: AppRoutes.nameUbicacionDetalle,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'] ?? '';
          return _TargetPage(text: 'ubicacion:$uuid');
        },
      ),
    ],
  );
}

GoRouter _buildRouterWithoutAnimalRoute() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const _SearchTriggerView(),
      ),
      GoRoute(
        path: '/directorio/lotes/:uuid',
        name: AppRoutes.nameLoteDetalle,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'] ?? '';
          return _TargetPage(text: 'lote:$uuid');
        },
      ),
      GoRoute(
        path: '/ubicaciones/:uuid',
        name: AppRoutes.nameUbicacionDetalle,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'] ?? '';
          return _TargetPage(text: 'ubicacion:$uuid');
        },
      ),
    ],
  );
}

class _SearchTriggerView extends StatelessWidget {
  const _SearchTriggerView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            key: const Key('trigger-animal'),
            onPressed: () => openDirectorioSearchResult(
              context,
              const CombinedSearchResult(
                type: CombinedSearchType.animal,
                id: 'animal-1',
                name: 'Animal A',
              ),
            ),
            child: const Text('Animal'),
          ),
          ElevatedButton(
            key: const Key('trigger-lote'),
            onPressed: () => openDirectorioSearchResult(
              context,
              const CombinedSearchResult(
                type: CombinedSearchType.lote,
                id: 'lote-1',
                name: 'Lote A',
              ),
            ),
            child: const Text('Lote'),
          ),
          ElevatedButton(
            key: const Key('trigger-ubicacion'),
            onPressed: () => openDirectorioSearchResult(
              context,
              const CombinedSearchResult(
                type: CombinedSearchType.ubicacion,
                id: 'ubicacion-1',
                name: 'Ubicacion A',
              ),
            ),
            child: const Text('Ubicacion'),
          ),
        ],
      ),
    );
  }
}

class _TargetPage extends StatelessWidget {
  const _TargetPage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(text)));
  }
}
