import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_photo.dart';
import 'package:libretapp/l10n/app_localizations.dart';

Widget _testApp(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('es'),
  home: Scaffold(body: child),
);

void main() {
  test('uses FileImage for a local photo path', () async {
    final file = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}'
      'libretapp-local-photo.jpg',
    );
    await file.writeAsBytes([1, 2, 3]);
    addTearDown(() async {
      if (await file.exists()) await file.delete();
    });

    expect(animalPhotoProvider(file.path), isA<FileImage>());
  });

  test('keeps HTTP and HTTPS photo support', () {
    expect(
      animalPhotoProvider('https://example.invalid/animal.jpg'),
      isA<NetworkImage>(),
    );
    expect(
      animalPhotoProvider('http://example.invalid/animal.jpg'),
      isA<NetworkImage>(),
    );
  });

  testWidgets('falls back when a local file does not exist', (tester) async {
    await tester.pumpWidget(
      _testApp(
        const AnimalPhotoImage(
          path: 'Z:/definitely-missing/libretapp-animal.jpg',
          fallback: Icon(Icons.pets, key: Key('fallback')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('fallback')), findsOneWidget);
  });

  testWidgets('removing a photo clears only its reference', (tester) async {
    String? result = 'unchanged';
    await tester.pumpWidget(
      _testApp(
        AnimalPhotoField(
          photoPath: 'Z:/missing/photo.jpg',
          species: Species.cattle,
          onChanged: (value) => result = value,
        ),
      ),
    );

    await tester.tap(find.text('Quitar foto'));

    expect(result, isNull);
  });
}
