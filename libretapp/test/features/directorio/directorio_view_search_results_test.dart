import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/bloc/directorio_state.dart';
import 'package:libretapp/features/directorio/view/directorio_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DirectorioSearchResultsPanel', () {
    testWidgets('shows correct icon and label by type', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DirectorioSearchResultsPanel(
              results: [
                CombinedSearchResult(
                  type: CombinedSearchType.animal,
                  id: 'animal-1',
                  name: 'Animal Match',
                ),
                CombinedSearchResult(
                  type: CombinedSearchType.lote,
                  id: 'lote-1',
                  name: 'Lote Match',
                ),
                CombinedSearchResult(
                  type: CombinedSearchType.ubicacion,
                  id: 'ubicacion-1',
                  name: 'Ubicacion Match',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('animal'), findsOneWidget);
      expect(find.text('lote'), findsOneWidget);
      expect(find.text('ubicacion'), findsOneWidget);

      expect(find.byIcon(Icons.pets), findsOneWidget);
      expect(find.byIcon(Icons.agriculture), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('tap on item opens expected detail route', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              return const Scaffold(
                body: DirectorioSearchResultsPanel(
                  results: [
                    CombinedSearchResult(
                      type: CombinedSearchType.lote,
                      id: 'lote-42',
                      name: 'Lote Tap',
                    ),
                  ],
                ),
              );
            },
          ),
          GoRoute(
            path: '/directorio/lotes/:uuid',
            name: AppRoutes.nameLoteDetalle,
            builder: (context, state) {
              final uuid = state.pathParameters['uuid'] ?? '';
              return Scaffold(body: Center(child: Text('lote:$uuid')));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lote Tap'));
      await tester.pumpAndSettle();

      expect(find.text('lote:lote-42'), findsOneWidget);
    });
  });
}
