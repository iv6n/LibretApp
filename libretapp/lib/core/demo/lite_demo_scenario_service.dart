import 'package:libretapp/core/demo/demo_identity.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';

/// Small domestic scenario, installed exclusively in a disposable workspace.
/// Stable IDs make a retry after partial failure safe; a completed install
/// preserves edits until the demo is discarded.
class LiteDemoScenarioService {
  LiteDemoScenarioService({
    required this.workspace,
    required this.animals,
    required this.cultivations,
    required this.agenda,
    required this.preferences,
  });

  final LocalWorkspace workspace;
  final AnimalRepository animals;
  final CultivationRepository cultivations;
  final AgendaRepository agenda;
  final SharedPrefsService preferences;
  static const installedKey = 'demo.lite.installed.v1';

  Future<void> install({DateTime? referenceDate}) async {
    if (!workspace.isDemo) {
      throw StateError('Los ejemplos solo se preparan en un espacio de demo.');
    }
    if (preferences.getBool(installedKey) == true) return;
    final now = referenceDate ?? DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    final luna = _pet('Luna', Species.canine, Sex.female, day);
    final milo = _pet('Milo', Species.feline, Sex.male, day);
    await animals.save(luna);
    await animals.save(milo);
    final plant = CultivationEntity(
      uuid: demoId('lite-plant', 'monstera'),
      name: 'Mi monstera',
      plantingDate: day.subtract(const Duration(days: 30)),
      lastWateredDate: day.subtract(const Duration(days: 1)),
      wateringFrequencyDays: 3,
      notes: 'Planta de ejemplo. Puedes editar su ficha.',
      createdAt: day,
      updatedAt: day,
    );
    final garden = CultivationEntity(
      uuid: demoId('lite-plant', 'huerto'),
      name: 'Huerto de aromáticas',
      variety: 'Albahaca y hierbabuena',
      scale: CultivationScale.group,
      quantity: 4,
      plantingDate: day.subtract(const Duration(days: 14)),
      lastWateredDate: day,
      wateringFrequencyDays: 2,
      notes: 'Huerto pequeño de ejemplo, sin ubicación obligatoria.',
      createdAt: day,
      updatedAt: day,
    );
    await cultivations.upsert(plant);
    await cultivations.upsert(garden);
    await agenda.saveEntries([
      _activity(
        'juego',
        'Jugar con Milo',
        'Cuidado general',
        day.add(const Duration(hours: 18)),
        petUuid: milo.uuid,
        created: day,
      ),
      _activity(
        'cita',
        'Cita de Luna',
        'Cita veterinaria',
        day.add(const Duration(days: 1, hours: 10)),
        petUuid: luna.uuid,
        created: day,
      ),
      _activity(
        'riego',
        'Regar el huerto',
        'Riego',
        day.add(const Duration(days: 2, hours: 9)),
        plantUuid: garden.uuid,
        created: day,
      ),
    ]);
    // Set only after every repository succeeded. No notifications are requested.
    await preferences.setBool(installedKey, true);
  }

  AnimalEntity _pet(String name, Species species, Sex sex, DateTime day) =>
      AnimalEntity(
        uuid: demoId('lite-pet', name.toLowerCase()),
        earTagNumber: '',
        customName: name,
        visualId: name,
        species: species,
        category: Category.other,
        lifeStage: AnimalTaxonomy.resolveLifeStage(
          species: species,
          sex: sex,
          ageMonths: 24,
        ),
        sex: sex,
        breed: 'Mestizo',
        birthDate: DateTime(day.year - 2, day.month, day.day),
        birthDatePrecision: BirthDatePrecision.estimated,
        ageMonths: 24,
        healthStatus: HealthStatus.good,
        vaccinated: false,
        dewormed: false,
        hasVitamins: false,
        hasChronicIssues: false,
        reproductiveStatus: ReproductiveStatus.unknown,
        productionPurpose: ProductionPurpose.companion,
        productionStage: ProductionStage.unknown,
        productionSystem: ProductionSystem.unknown,
        underObservation: false,
        requiresAttention: false,
        riskLevel: RiskLevel.low,
        notes: 'Mascota ficticia para explorar LibretApp.',
        gallery: const [],
        synced: false,
        creationDate: day,
        lastUpdateDate: day,
      );

  AgendaEntry _activity(
    String slug,
    String title,
    String type,
    DateTime date, {
    required DateTime created,
    String? petUuid,
    String? plantUuid,
  }) => AgendaEntry(
    id: demoId('lite-activity', slug),
    titulo: title,
    descripcion: 'Actividad ficticia. Prueba a editarla o completarla.',
    fecha: date,
    tipo: type,
    animalIds: petUuid == null ? const [] : [petUuid],
    loteIds: const [],
    cropUuid: plantUuid,
    ubicacion: '',
    estado: AgendaEstado.pendiente,
    completedAnimalIds: const [],
    notas: 'Ejemplo de demostración',
    sourceType: 'lite',
    sourceId: demoId('lite-plan', slug),
    actionKind: 'liteReminder',
    createdAt: created,
    updatedAt: created,
  );
}
