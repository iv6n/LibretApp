import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/onboarding/onboarding_startup_service.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPrefsService> preferences(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPrefsService(await SharedPreferences.getInstance());
  }

  test('a fresh empty installation shows the welcome screen', () async {
    final prefs = await preferences({});
    final service = OnboardingStartupService(
      preferences: prefs,
      animalRepository: _AnimalRepository(const []),
    );

    expect(await service.shouldShowWelcome(), isTrue);
    expect(prefs.getBool(PrefsKeys.onboardingCompletedV1), isNull);
  });

  test(
    'an existing user skips welcome and receives the migration mark',
    () async {
      final prefs = await preferences({});
      final service = OnboardingStartupService(
        preferences: prefs,
        animalRepository: _AnimalRepository([_FakeAnimal()]),
      );

      expect(await service.shouldShowWelcome(), isFalse);
      expect(prefs.getBool(PrefsKeys.onboardingCompletedV1), isTrue);
    },
  );

  test('the versioned completion preference skips the data lookup', () async {
    final prefs = await preferences({PrefsKeys.onboardingCompletedV1: true});
    final repository = _AnimalRepository(const []);
    final service = OnboardingStartupService(
      preferences: prefs,
      animalRepository: repository,
    );

    expect(await service.shouldShowWelcome(), isFalse);
    expect(repository.lookupCount, 0);
  });
}

class _AnimalRepository implements AnimalRepository {
  _AnimalRepository(this.animals);

  final List<AnimalEntity> animals;
  int lookupCount = 0;

  @override
  Future<List<AnimalEntity>> getAllIncludingInactive() async {
    lookupCount++;
    return animals;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAnimal implements AnimalEntity {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
