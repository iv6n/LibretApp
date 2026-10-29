import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/sex.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_dto.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/lite/lite_pet_service.dart';
import 'package:libretapp/features/lite/lite_visibility.dart';

class _AnimalRepo extends AnimalRepository {
  final records = <String, AnimalEntity>{};
  @override
  Future<AnimalEntity> save(AnimalEntity animal) async =>
      records[animal.uuid] = animal;
  @override
  Future<AnimalEntity> update(AnimalEntity animal) async =>
      records[animal.uuid] = animal;
  @override
  Future<AnimalEntity?> getByUuid(String uuid) async => records[uuid];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailingPrefs extends SharedPrefsService {
  _FailingPrefs(super.prefs);
  @override
  Future<void> setString(String key, String value) async =>
      throw StateError('disco');
}

AgendaEntry _task(String id, List<String> animalIds, {String? cropUuid}) =>
    AgendaEntry(
      id: id,
      titulo: id,
      descripcion: '',
      fecha: DateTime(2030),
      tipo: 'Cita',
      animalIds: animalIds,
      loteIds: const [],
      cropUuid: cropUuid,
      ubicacion: '',
      estado: AgendaEstado.pendiente,
      completedAnimalIds: const [],
      notas: '',
      sourceType: 'lite',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'experiencia distinta por espacio y cambio fallido conserva el modo',
    () async {
      SharedPreferences.setMockInitialValues({});
      final raw = await SharedPreferences.getInstance();
      final first = AppExperienceController(
        SharedPrefsService(raw, prefix: 'workspace.a.'),
      );
      final second = AppExperienceController(
        SharedPrefsService(raw, prefix: 'workspace.b.'),
      );
      await first.setExperience(AppExperience.lite);
      expect(second.experience, AppExperience.complete);
      expect(
        AppExperienceController(
          SharedPrefsService(raw, prefix: 'workspace.a.'),
        ).isLite,
        isTrue,
      );
      await first.setExperience(AppExperience.complete);
      await first.setExperience(AppExperience.lite);
      expect(first.isLite, isTrue);
      final failing = AppExperienceController(_FailingPrefs(raw));
      await expectLater(
        failing.setExperience(AppExperience.lite),
        throwsStateError,
      );
      expect(failing.experience, AppExperience.complete);
    },
  );

  test(
    'alta mínima conserva edad y sexo desconocidos incluso en DTO',
    () async {
      final repo = _AnimalRepo();
      final pet = await LitePetService(
        repo,
      ).create(const LitePetInput(name: 'Mora', species: Species.feline));
      expect(pet.sex, Sex.unknown);
      expect(pet.hasKnownAge, isFalse);
      expect(pet.knownBirthDate, isNull);
      final dto = AnimalDto.fromEntity(pet);
      expect(dto.birthDate, isEmpty);
      expect(dto.ageMonths, -1);
      expect(dto.toEntity().hasKnownAge, isFalse);
    },
  );

  test(
    'editar en Lite aplica parche a ficha más reciente y conserva campos ocultos',
    () async {
      final repo = _AnimalRepo();
      final service = LitePetService(repo);
      final pet = await service.create(
        const LitePetInput(name: 'Mora', species: Species.feline),
      );
      final before = const LitePetInput(name: 'Mora', species: Species.feline);
      repo.records[pet.uuid] = pet.copyWith(
        sireUuid: 'padre',
        damUuid: 'madre',
        currentLocationId: 'casa',
        notes: 'historial completo',
      );
      final updated = await service.patch(
        pet.uuid,
        before,
        const LitePetInput(name: 'Mora Azul', species: Species.feline),
      );
      expect(updated.customName, 'Mora Azul');
      expect(updated.sireUuid, 'padre');
      expect(updated.damUuid, 'madre');
      expect(updated.currentLocationId, 'casa');
      expect(updated.notes, 'historial completo');
    },
  );

  test('tarea que mezcla mascota y ganado queda solo en Completa', () async {
    final plant = CultivationEntity(
      name: 'Albahaca',
      plantingDate: DateTime(2026),
    );
    final field = CultivationEntity(
      name: 'Parcela',
      plantingDate: DateTime(2026),
      scale: CultivationScale.area,
    );
    expect(LiteVisibility.domesticPlant(plant), isTrue);
    expect(LiteVisibility.domesticPlant(field), isFalse);
    expect(
      LiteVisibility.agendaEntry(
        _task('cita', ['pet']),
        {'pet'},
        {plant.uuid},
        showPlants: true,
      ),
      isTrue,
    );
    expect(
      LiteVisibility.agendaEntry(
        _task('mixta', ['pet', 'cow']),
        {'pet'},
        {plant.uuid},
        showPlants: true,
      ),
      isFalse,
    );
    expect(
      LiteVisibility.agendaEntry(
        _task('riego', [], cropUuid: plant.uuid),
        {'pet'},
        {plant.uuid},
        showPlants: false,
      ),
      isFalse,
    );
  });
}
