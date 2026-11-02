import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/widgets/app_search_bar.dart';
import 'package:libretapp/l10n/app_localizations.dart';

void main() {
  testWidgets('single search action clears text before closing', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    final changes = <String>[];
    var clears = 0;
    var closes = 0;
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: AppSearchBar(
                controller: controller,
                focusNode: focusNode,
                singleClearOrCloseAction: true,
                onChanged: changes.add,
                onClear: () => clears++,
                onClose: () => closes++,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.clear), findsNothing);
    await tester.tap(find.byIcon(Icons.close));
    expect(closes, 1);

    await tester.enterText(find.byType(TextField), 'vaca');
    await tester.pump();
    expect(find.byIcon(Icons.clear), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(changes.last, isEmpty);
    expect(clears, 1);
    expect(focusNode.hasFocus, isTrue);
    expect(closes, 1);

    await tester.tap(find.byIcon(Icons.close));
    expect(closes, 2);
  });
}
