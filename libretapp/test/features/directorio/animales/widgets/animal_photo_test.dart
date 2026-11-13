import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_avatar.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_card.dart';
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

  testWidgets('fills the animal card avatar frame without an inner gutter', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(AnimalCard(animal: _testAnimal(), onTap: () {})),
    );
    await tester.pumpAndSettle();

    final image = find.byType(Image);
    expect(image, findsOneWidget);
    final avatarSize = tester.getSize(find.byType(AnimalAvatar)).width;
    final photoSize = tester.getSize(image);
    // Only the thin border ring may separate the photo from the avatar frame.
    expect(avatarSize - photoSize.width, inInclusiveRange(4, 16));
    expect(avatarSize - photoSize.height, inInclusiveRange(4, 16));
    expect(tester.widget<Image>(image).fit, BoxFit.cover);
  });
}

AnimalEntity _testAnimal() {
  final now = DateTime(2025, 1, 1);
  return AnimalEntity(
    uuid: 'animal-card-test',
    earTagNumber: 'TAG-1',
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: 'Criolla',
    birthDate: now.subtract(const Duration(days: 900)),
    ageMonths: 30,
    healthStatus: HealthStatus.good,
    vaccinated: false,
    dewormed: false,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.undefined,
    productionStage: ProductionStage.unknown,
    productionSystem: ProductionSystem.unknown,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.low,
    gallery: const [],
    synced: false,
    creationDate: now,
    lastUpdateDate: now,
  );
}
