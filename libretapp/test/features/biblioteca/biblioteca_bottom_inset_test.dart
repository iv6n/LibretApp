import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/biblioteca/cubit/biblioteca_cubit.dart';
import 'package:libretapp/features/biblioteca/data/library_repository.dart';
import 'package:libretapp/features/biblioteca/view/biblioteca_tab.dart';
import 'package:libretapp/features/biblioteca/widgets/library_book_card.dart';
import 'package:libretapp/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'catalog scrolls under the dock and ends with its last book clear',
    (tester) async {
      const size = Size(390, 568);
      const dockInset = 105.0;
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: MediaQuery(
            data: const MediaQueryData(
              size: size,
              padding: EdgeInsets.only(bottom: dockInset),
            ),
            child: BlocProvider(
              create: (_) =>
                  BibliotecaCubit(libraryRepository: AssetLibraryRepository()),
              child: const Scaffold(body: BibliotecaTab()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final list = find.byType(ListView);
      expect(list, findsOneWidget);
      expect(tester.getRect(list).bottom, size.height);
      final scrollable = tester.state<ScrollableState>(
        find.descendant(of: list, matching: find.byType(Scrollable)),
      );
      expect(scrollable.position.maxScrollExtent, greaterThan(0));
      scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
      await tester.pumpAndSettle();

      final lastBook = find.byType(LibraryBookCard).last;
      expect(
        tester.getRect(lastBook).bottom,
        lessThan(size.height - dockInset),
      );
      expect(lastBook.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
