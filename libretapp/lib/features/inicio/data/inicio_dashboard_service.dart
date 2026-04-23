import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/eventos/data/eventos_model.dart';
import 'package:libretapp/features/eventos/data/eventos_repository.dart';
import 'package:libretapp/features/inicio/data/inicio_dashboard_models.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class InicioDashboardService {
  InicioDashboardService({
    required AnimalRepository animalRepository,
    required LotesRepository lotesRepository,
    required EventosRepository eventosRepository,
    required LocationRepository locationRepository,
    required PerfilRepository perfilRepository,
  }) : _animalRepository = animalRepository,
       _lotesRepository = lotesRepository,
       _eventosRepository = eventosRepository,
       _locationRepository = locationRepository,
       _perfilRepository = perfilRepository;

  final AnimalRepository _animalRepository;
  final LotesRepository _lotesRepository;
  final EventosRepository _eventosRepository;
  final LocationRepository _locationRepository;
  final PerfilRepository _perfilRepository;

  Future<InicioDashboardData> loadDashboard() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final results = await Future.wait<dynamic>([
      _animalRepository.getStatistics(),
      _animalRepository.getAll(),
      _lotesRepository.getActiveLotes(),
      _locationRepository.getAll(),
      _eventosRepository.fetchEventos(),
      _perfilRepository.fetchPerfil(),
    ]);

    final statistics = results[0] as Map<String, dynamic>;
    final animals = results[1] as List<AnimalEntity>;
    final activeLotes = results[2] as List<LoteEntity>;
    final locations = results[3] as List<LocationEntity>;
    final eventos = results[4] as List<Evento>;
    final perfil = results[5] as Perfil;

    final totalAnimals = (statistics['total'] as int?) ?? animals.length;
    final attentionAnimals = (statistics['attention'] as int?) ?? 0;
    final unsyncedAnimals = (statistics['unsynced'] as int?) ?? 0;

    final unvaccinated = animals.where((a) => !a.vaccinated).length;
    final underObservation = animals.where((a) => a.underObservation).length;

    final upcomingEvents =
        eventos.where((e) => !e.fecha.isBefore(today)).toList()
          ..sort((a, b) => a.fecha.compareTo(b.fecha));
    final overdueEvents = eventos.where((e) => e.fecha.isBefore(today)).length;

    final alerts = <InicioAlertItem>[];

    if (attentionAnimals > 0) {
      alerts.add(
        InicioAlertItem(
          title: 'Animales con prioridad alta',
          message: '$attentionAnimals requieren revision inmediata.',
          severity: InicioAlertSeverity.critical,
          targetRoute: AppRoutes.animales,
        ),
      );
    }

    if (overdueEvents > 0) {
      alerts.add(
        InicioAlertItem(
          title: 'Eventos vencidos',
          message: '$overdueEvents actividad(es) quedaron fuera de fecha.',
          severity: InicioAlertSeverity.warning,
          targetRoute: AppRoutes.eventos,
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
          targetRoute: AppRoutes.animales,
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

    if (tasks.isEmpty) {
      tasks.add(
        const InicioTaskItem(
          title: 'Sin pendientes criticos',
          message: 'Puedes revisar reportes o registrar nuevas actividades.',
          targetRoute: AppRoutes.eventos,
        ),
      );
    }

    return InicioDashboardData(
      profileName: perfil.nombre,
      farmName: perfil.finca,
      totalAnimals: totalAnimals,
      attentionAnimals: attentionAnimals,
      unsyncedAnimals: unsyncedAnimals,
      activeLotes: activeLotes.length,
      totalLocations: locations.length,
      upcomingEventsCount: upcomingEvents.length,
      upcomingEvents: upcomingEvents.take(4).toList(growable: false),
      alerts: alerts,
      tasks: tasks,
      lastUpdated: now,
    );
  }
}
