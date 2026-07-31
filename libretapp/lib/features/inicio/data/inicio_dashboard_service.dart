/// features \u203a inicio \u203a data \u203a inicio_dashboard_service \u2014 service that aggregates data for the home dashboard.
library;

import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/category.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/sex.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_presentation.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/inicio/data/weather_service.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class InicioDashboardService {
  InicioDashboardService({
    required AnimalRepository animalRepository,
    required LotesRepository lotesRepository,
    required AgendaRepository agendaRepository,
    required LocationRepository locationRepository,
    required PerfilRepository perfilRepository,
    required ReproductionRecordRepository reproductionRepository,
    required WeatherService weatherService,
  }) : _animalRepository = animalRepository,
       _lotesRepository = lotesRepository,
       _agendaRepository = agendaRepository,
       _locationRepository = locationRepository,
       _perfilRepository = perfilRepository,
       _reproductionRepository = reproductionRepository,
       _weatherService = weatherService;

  final AnimalRepository _animalRepository;
  final LotesRepository _lotesRepository;
  final AgendaRepository _agendaRepository;
  final LocationRepository _locationRepository;
  final PerfilRepository _perfilRepository;
  final ReproductionRecordRepository _reproductionRepository;
  final WeatherService _weatherService;

  Future<InicioDashboardData> loadDashboard() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final results = await Future.wait<dynamic>([
      _animalRepository.getStatistics(),
      _animalRepository.getAll(),
      _lotesRepository.getActiveLotes(),
      _locationRepository.getAll(),
      _agendaRepository.fetchEntries(),
      _perfilRepository.fetchPerfil(),
    ]);

    final statistics = results[0] as Map<String, dynamic>;
    final animals = results[1] as List<AnimalEntity>;
    final activeLotes = results[2] as List<LoteEntity>;
    final locations = results[3] as List<LocationEntity>;
    final eventos = results[4] as List<AgendaEntry>;
    final perfil = results[5] as Perfil;

    final totalAnimals = (statistics['total'] as int?) ?? animals.length;
    final attentionAnimals = (statistics['attention'] as int?) ?? 0;
    final unsyncedAnimals = (statistics['unsynced'] as int?) ?? 0;
    final totalAnimalCapacity = locations.fold<int>(
      0,
      (sum, location) => sum + location.capacity,
    );

    final unvaccinated = animals.where((a) => !a.vaccinated).length;
    final underObservation = animals.where((a) => a.underObservation).length;
    final pendingEarTags = animals.where(hasPendingEarTag).length;

    // Category breakdown – only categories with ≥1 animal.
    final categoryTotals = <Category, ({int male, int female})>{};
    for (final animal in animals) {
      final cat = animal.category;
      final prev = categoryTotals[cat] ?? (male: 0, female: 0);
      categoryTotals[cat] = animal.sex == Sex.male
          ? (male: prev.male + 1, female: prev.female)
          : (male: prev.male, female: prev.female + 1);
    }
    final categoryBreakdown = categoryTotals.entries.map((e) {
      return CategorySummary(
        category: e.key,
        total: e.value.male + e.value.female,
        maleCount: e.value.male,
        femaleCount: e.value.female,
      );
    }).toList()..sort((a, b) => b.total.compareTo(a.total));

    bool isOpenAgendaEntry(AgendaEntry entry) =>
        entry.estado != AgendaEstado.completado &&
        entry.estado != AgendaEstado.verificado &&
        entry.estado != AgendaEstado.cancelado;

    final upcomingEvents =
        eventos
            .where((e) => !e.fecha.isBefore(today) && isOpenAgendaEntry(e))
            .toList()
          ..sort((a, b) => a.fecha.compareTo(b.fecha));
    final overdueEvents = eventos
        .where((e) => e.fecha.isBefore(today) && isOpenAgendaEntry(e))
        .length;

    // Calvings in the next 21 days.
    final calvingWindow = today.add(const Duration(days: 21));
    final calvingRaw = await _reproductionRepository.getUpcomingCalvings(
      today,
      calvingWindow,
    );
    final animalMap = {for (final a in animals) a.uuid: a};
    final upcomingCalvings =
        calvingRaw
            .map((c) {
              final animal = animalMap[c.animalUuid];
              if (animal == null) return null;
              final daysRemaining = c.expectedCalvingDate
                  .difference(today)
                  .inDays;
              return CalvingItem(
                animalUuid: c.animalUuid,
                animalTag: animal.earTagNumber,
                animalName: animal.customName,
                expectedDate: c.expectedCalvingDate,
                daysRemaining: daysRemaining,
              );
            })
            .whereType<CalvingItem>()
            .toList(growable: false)
          ..sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));

    final alerts = <InicioAlertItem>[];

    if (attentionAnimals > 0) {
      alerts.add(
        InicioAlertItem(
          title: 'Animales con prioridad alta',
          message: '$attentionAnimals requieren revision inmediata.',
          severity: InicioAlertSeverity.critical,
          targetRoute: AppRoutes.animalesPath(attention: true),
        ),
      );
    }

    if (overdueEvents > 0) {
      alerts.add(
        InicioAlertItem(
          title: 'Eventos vencidos',
          message: '$overdueEvents actividad(es) quedaron fuera de fecha.',
          severity: InicioAlertSeverity.warning,
          targetRoute: AppRoutes.agenda,
        ),
      );
    }

    if (unsyncedAnimals > 0) {
      alerts.add(
        InicioAlertItem(
          title: 'Pendientes de sincronizacion',
          message: '$unsyncedAnimals registros aun no sincronizados.',
          severity: InicioAlertSeverity.info,
          targetRoute: AppRoutes.animales,
        ),
      );
    }

    if (alerts.isEmpty) {
      alerts.add(
        const InicioAlertItem(
          title: 'Operacion estable',
          message: 'No se detectaron alertas criticas por ahora.',
          severity: InicioAlertSeverity.info,
          targetRoute: AppRoutes.inicio,
        ),
      );
    }

    final tasks = <InicioTaskItem>[];

    if (unvaccinated > 0) {
      tasks.add(
        InicioTaskItem(
          title: 'Programar vacunacion',
          message: '$unvaccinated animales sin vacuna registrada.',
          targetRoute: AppRoutes.animales,
        ),
      );
    }

    if (underObservation > 0) {
      tasks.add(
        InicioTaskItem(
          title: 'Seguir animales en observacion',
          message: '$underObservation animales con seguimiento activo.',
          targetRoute: AppRoutes.animalesPath(attention: true),
        ),
      );
    }

    if (locations.isEmpty) {
      tasks.add(
        const InicioTaskItem(
          title: 'Registrar ubicaciones base',
          message: 'Crea al menos una ubicacion para organizar movimientos.',
          targetRoute: AppRoutes.ubicaciones,
        ),
      );
    }

    if (activeLotes.isEmpty) {
      tasks.add(
        const InicioTaskItem(
          title: 'Crear un lote activo',
          message: 'Agrupa animales para gestionar campanas y recorridos.',
          targetRoute: AppRoutes.directorio,
        ),
      );
    }

    if (pendingEarTags > 0) {
      tasks.add(
        InicioTaskItem(
          title: 'Asignar aretes pendientes',
          message:
              '$pendingEarTags animal${pendingEarTags == 1 ? '' : 'es'} '
              '${pendingEarTags == 1 ? 'requiere' : 'requieren'} identificación.',
          targetRoute:
              AppRoutes.animalesPath(pendingEarTag: true),
        ),
      );
    }

    if (tasks.isEmpty) {
      tasks.add(
        const InicioTaskItem(
          title: 'Sin pendientes criticos',
          message: 'Puedes revisar reportes o registrar nuevas actividades.',
          targetRoute: AppRoutes.agenda,
        ),
      );
    }

    // Recent activity – top 5 most recently updated animals.
    final sortedByActivity = List<AnimalEntity>.from(animals)
      ..sort((a, b) => b.lastUpdateDate.compareTo(a.lastUpdateDate));
    final recentActivity = sortedByActivity
        .take(5)
        .map((a) {
          final abbrev = a.category.displayName.substring(0, 1).toUpperCase();
          return RecentActivityItem(
            animalUuid: a.uuid,
            animalTag: a.earTagNumber,
            animalName: a.customName,
            categoryLabel: a.category.displayName,
            categoryAbbrev: abbrev,
            lastUpdate: a.lastUpdateDate,
            photoPath: a.profilePhoto,
          );
        })
        .toList(growable: false);

    final animalCountsByLocation = <String, int>{};
    for (final animal in animals) {
      final locationUuid = animal.currentLocationId;
      if (locationUuid == null || locationUuid.isEmpty) continue;
      animalCountsByLocation.update(
        locationUuid,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    final activeLocations = List<LocationEntity>.from(locations)
      ..sort((a, b) {
        final aActive = a.status == LocationStatus.inUse ? 0 : 1;
        final bActive = b.status == LocationStatus.inUse ? 0 : 1;
        if (aActive != bActive) return aActive.compareTo(bActive);
        final byAnimals = (animalCountsByLocation[b.uuid] ?? 0).compareTo(
          animalCountsByLocation[a.uuid] ?? 0,
        );
        if (byAnimals != 0) return byAnimals;
        return a.name.compareTo(b.name);
      });

    final activeLocationSummaries = activeLocations
        .take(3)
        .map(
          (location) => ActiveLocationSummary(
            uuid: location.uuid,
            name: location.name,
            typeLabel: location.type.label,
            animalCount: animalCountsByLocation[location.uuid] ?? 0,
            capacity: location.capacity,
            surfaceArea: location.surfaceArea,
            waterEvents: location.waters.length,
            pastureEvents: location.pastures.length,
            imageCount: location.imagePaths.length,
          ),
        )
        .toList(growable: false);

    WeatherData? weather;
    try {
      weather = await _weatherService.getCurrentWeather(
        locations: locations,
        address: perfil.direccion,
      );
    } catch (_) {
      // Weather is supplementary: connectivity or location failures must not
      // prevent the operational dashboard from loading.
    }

    return InicioDashboardData(
      profileName: perfil.nombre,
      farmName: perfil.finca,
      totalAnimals: totalAnimals,
      totalAnimalCapacity: totalAnimalCapacity,
      attentionAnimals: attentionAnimals,
      unsyncedAnimals: unsyncedAnimals,
      activeLotes: activeLotes.length,
      totalLocations: locations.length,
      upcomingEventsCount: upcomingEvents.length,
      upcomingEvents: upcomingEvents.take(4).toList(growable: false),
      alerts: alerts,
      tasks: tasks,
      lastUpdated: now,
      categoryBreakdown: categoryBreakdown,
      upcomingCalvings: upcomingCalvings,
      weather: weather,
      recentActivity: recentActivity,
      activeLocations: activeLocationSummaries,
    );
  }
}
