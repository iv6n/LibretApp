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

  group('Directorio tabs inline menu', () {
    testWidgets('shows tab rows with lotes hidden by default', (tester) async {
      await tester.pumpWidget(_tabsMenuHost());

      expect(find.text('Animales'), findsOneWidget);
      expect(find.text('Ubicaciones'), findsOneWidget);
      expect(find.text('Lotes'), findsOneWidget);

      final lotesCheckbox = tester.widget<Checkbox>(
        find.byKey(
          const ValueKey<String>('directorio_menu_visible_lotes'),
        ),
      );
      expect(lotesCheckbox.value, isFalse);
    });

    testWidgets('can show lotes directly from the menu', (tester) async {
      Set<DirectorioSection>? latestVisible;
      await tester.pumpWidget(
        _tabsMenuHost(onChanged: (_, visible) => latestVisible = visible),
      );

      await tester.tap(
        find.byKey(
          const ValueKey<String>('directorio_menu_visible_lotes'),
        ),
      );
      await tester.pumpAndSettle();

      expect(latestVisible, contains(DirectorioSection.lotes));
      final lotesCheckbox = tester.widget<Checkbox>(
        find.byKey(
          const ValueKey<String>('directorio_menu_visible_lotes'),
        ),
      );
      expect(lotesCheckbox.value, isTrue);
    });

    testWidgets('moves ubicaciones before animales with the up arrow', (
      tester,
    ) async {
      List<DirectorioSection>? latestOrder;
      await tester.pumpWidget(
        _tabsMenuHost(onChanged: (order, _) => latestOrder = order),
      );

      await tester.tap(
        find.byKey(
          const ValueKey<String>('directorio_menu_move_up_ubicaciones'),
        ),
      );
      await tester.pumpAndSettle();

      expect(latestOrder, isNotNull);
      expect(latestOrder!.take(2), [
        DirectorioSection.ubicaciones,
        DirectorioSection.animales,
      ]);
    });

    testWidgets('does not allow hiding every section', (tester) async {
      await tester.pumpWidget(
        _tabsMenuHost(
          orderedSections: const [DirectorioSection.animales],
          visibleSections: const {DirectorioSection.animales},
        ),
      );

      await tester.tap(
        find.byKey(
          const ValueKey<String>('directorio_menu_visible_animales'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('El directorio debe mostrar al menos una categoria.'),
        findsOneWidget,
      );
      final animalesCheckbox = tester.widget<Checkbox>(
        find.byKey(
          const ValueKey<String>('directorio_menu_visible_animales'),
        ),
      );
      expect(animalesCheckbox.value, isTrue);
    });
  });
}

Widget _tabsMenuHost({
  List<DirectorioSection> orderedSections = defaultDirectorioSectionOrder,
  Set<DirectorioSection> visibleSections = defaultDirectorioVisibleSections,
  void Function(List<DirectorioSection>, Set<DirectorioSection>)? onChanged,
}) {
  final order = List<DirectorioSection>.of(orderedSections);
  final visible = Set<DirectorioSection>.of(visibleSections);

  void emitChange() => onChanged?.call(
    List<DirectorioSection>.of(order),
    Set<DirectorioSection>.of(visible),
  );

  return MaterialApp(
    home: StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          body: DirectorioTabsMenuContent(
            orderedSections: order,
            visibleSections: visible,
            labelForSection: _labelForSection,
            iconForSection: _iconForSection,
            onVisibilityChanged: (section, value) {
              if (!value && visible.length == 1 && visible.contains(section)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'El directorio debe mostrar al menos una categoria.',
                    ),
                  ),
                );
                return;
              }
              setState(() {
                if (value) {
                  visible.add(section);
                } else {
                  visible.remove(section);
                }
                emitChange();
              });
            },
            onMoveSection: (section, delta) {
              setState(() {
                final currentIndex = order.indexOf(section);
                final nextIndex = currentIndex + delta;
                if (currentIndex < 0 ||
                    nextIndex < 0 ||
                    nextIndex >= order.length) {
                  return;
                }
                final moved = order.removeAt(currentIndex);
                order.insert(nextIndex, moved);
                emitChange();
              });
            },
          ),
        );
      },
    ),
  );
}

String _labelForSection(DirectorioSection section) {
  switch (section) {
    case DirectorioSection.animales:
      return 'Animales';
    case DirectorioSection.lotes:
      return 'Lotes';
    case DirectorioSection.ubicaciones:
      return 'Ubicaciones';
  }
}

IconData _iconForSection(DirectorioSection section) {
  switch (section) {
    case DirectorioSection.animales:
      return Icons.pets;
    case DirectorioSection.lotes:
      return Icons.fence;
    case DirectorioSection.ubicaciones:
      return Icons.location_on_outlined;
  }
}
