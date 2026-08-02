/// core › demo › builders › demo_agenda_workforce — workers, a team, and
/// manually-created agenda tasks.
///
/// Automatic reminders (health/reproduction/care) are never authored here —
/// they are derived by `AgendaReminderSyncService.sync()`, called once at
/// the end of `DemoScenarioService.install()`, from the health/reproduction/
/// care records the other builders already wrote. Every id here uses
/// `demoId(...)`, which never starts with `auto:`, so `sync()`'s
/// manual/automatic split always keeps these as manual entries.
library;

import 'package:libretapp/core/demo/builders/demo_animals.dart';
import 'package:libretapp/core/demo/builders/demo_locations.dart';
import 'package:libretapp/core/demo/demo_dates.dart';
import 'package:libretapp/core/demo/demo_identity.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/workforce_model.dart';

String demoWorkerUuid(String slug) => demoId('worker', slug);
String demoTeamUuid(String slug) => demoId('team', slug);

const String workerOwnerSlug = 'rodrigo-valenzuela';
const String workerForemanSlug = 'ismael-duarte';
const String workerHandSlug = 'juan-felix';
const String workerVetHelperSlug = 'maria-robles';
const String teamCuadrillaSlug = 'cuadrilla-rancho';

List<WorkerProfile> buildDemoWorkers({required DateTime reference}) {
  WorkerProfile worker(String slug, String name, String role, {String? phone}) {
    return WorkerProfile(
      id: demoWorkerUuid(slug),
      name: name,
      role: role,
      phone: phone,
      active: true,
      createdAt: reference,
      updatedAt: reference,
    );
  }

  return [
    worker(workerOwnerSlug, 'Rodrigo Valenzuela (DEMO)', WorkerRole.owner),
    worker(
      workerForemanSlug,
      'Ismael Duarte (DEMO)',
      WorkerRole.supervisor,
      phone: '662-000-0002',
    ),
    worker(
      workerHandSlug,
      'Juan Félix (DEMO)',
      WorkerRole.worker,
      phone: '662-000-0003',
    ),
    worker(
      workerVetHelperSlug,
      'María Robles (DEMO)',
      WorkerRole.worker,
      phone: '662-000-0004',
    ),
  ];
}

List<WorkTeam> buildDemoTeams({required DateTime reference}) {
  return [
    WorkTeam(
      id: demoTeamUuid(teamCuadrillaSlug),
      name: 'Cuadrilla Rancho (DEMO)',
      memberIds: [
        demoWorkerUuid(workerForemanSlug),
        demoWorkerUuid(workerHandSlug),
        demoWorkerUuid(workerVetHelperSlug),
      ],
      active: true,
      createdAt: reference,
      updatedAt: reference,
    ),
  ];
}

List<AgendaEntry> buildDemoAgendaEntries({required DateTime reference}) {
  String loc(String slug) => demoId('location', slug);
  AgendaEntry base({
    required String slug,
    required String titulo,
    required String descripcion,
    required DateTime fecha,
    required String tipo,
    List<String> animalIds = const [],
    String? locationSlug,
    String estado = AgendaEstado.pendiente,
    String prioridad = AgendaPrioridad.normal,
    String? assigneeSlug,
    String? workTeamSlug,
    List<AgendaChecklistItem> checklist = const [],
    String notas = '',
    DateTime? fechaCompletado,
    String? blockedReason,
  }) {
    return AgendaEntry(
      id: demoId('agenda', slug),
      titulo: titulo,
      descripcion: descripcion,
      fecha: fecha,
      tipo: tipo,
      animalIds: animalIds,
      loteIds: const [],
      ubicacion: locationSlug != null
          ? 'Rancho El Mezquite — DEMO'
          : 'Sin ubicación',
      estado: estado,
      completedAnimalIds: const [],
      notas: notas,
      fechaCompletado: fechaCompletado,
      locationUuid: locationSlug != null ? loc(locationSlug) : null,
      prioridad: prioridad,
      assigneeId: assigneeSlug != null ? demoWorkerUuid(assigneeSlug) : null,
      workTeamId: workTeamSlug != null ? demoTeamUuid(workTeamSlug) : null,
      createdById: demoWorkerUuid(workerOwnerSlug),
      createdAt: daysBefore(fecha, 3),
      updatedAt: fecha,
      checklist: checklist,
      blockedReason: blockedReason,
    );
  }

  return [
    // Vencida.
    base(
      slug: 'cerco-potrero-sur',
      titulo: 'Reparar cerco — Potrero Sur',
      descripcion: 'Revisar y reparar tramo de cerco dañado por el ganado.',
      fecha: daysBefore(reference, 5),
      tipo: 'Mantenimiento',
      locationSlug: locPotreroSurSlug,
      prioridad: AgendaPrioridad.alta,
      assigneeSlug: workerForemanSlug,
      notas: 'Registro de demostración.',
    ),
    // Hoy, con checklist.
    base(
      slug: 'recorrido-diario',
      titulo: 'Recorrido diario del hato',
      descripcion: 'Verificar agua, sombra y estado general del hato.',
      fecha: reference,
      tipo: 'Manejo',
      locationSlug: locRanchSlug,
      prioridad: AgendaPrioridad.normal,
      assigneeSlug: workerHandSlug,
      checklist: [
        AgendaChecklistItem(
          id: demoId('checklist', 'recorrido-agua'),
          label: 'Revisar abrevaderos',
        ),
        AgendaChecklistItem(
          id: demoId('checklist', 'recorrido-sombra'),
          label: 'Revisar sombra en corrales',
        ),
        AgendaChecklistItem(
          id: demoId('checklist', 'recorrido-hato'),
          label: 'Contar animales por potrero',
          completed: true,
          completedById: demoWorkerUuid(workerHandSlug),
          completedAt: reference,
        ),
      ],
      notas: 'Registro de demostración.',
    ),
    // Próxima semana.
    base(
      slug: 'vacunacion-programada',
      titulo: 'Preparar vacunación programada',
      descripcion: 'Alistar insumos para la siguiente ronda de vacunación.',
      fecha: daysAfter(reference, 3),
      tipo: 'Sanidad',
      locationSlug: locCorralPrincipalSlug,
      prioridad: AgendaPrioridad.normal,
      workTeamSlug: teamCuadrillaSlug,
      notas: 'Registro de demostración.',
    ),
    base(
      slug: 'siembra-milpa',
      titulo: 'Revisar riego de apoyo en milpa',
      descripcion: 'Confirmar riego de apoyo tras la última lluvia registrada.',
      fecha: daysAfter(reference, 6),
      tipo: 'Cultivo',
      locationSlug: locMilpaSlug,
      prioridad: AgendaPrioridad.baja,
      assigneeSlug: workerHandSlug,
      notas: 'Registro de demostración.',
    ),
    // Completada.
    base(
      slug: 'entrega-becerro',
      titulo: 'Entrega de becerro vendido',
      descripcion: 'Coordinar transporte y entrega al comprador.',
      fecha: daysBefore(reference, 10),
      tipo: 'Comercial',
      animalIds: [demoAnimalUuid(aniVendidaSlug)],
      estado: AgendaEstado.completado,
      fechaCompletado: daysBefore(reference, 10),
      prioridad: AgendaPrioridad.alta,
      assigneeSlug: workerOwnerSlug,
      notas: 'Registro de demostración.',
    ),
    // Verificada.
    base(
      slug: 'revision-cuarentena',
      titulo: 'Revisión de vaquilla en cuarentena',
      descripcion: 'Verificar evolución de vaquilla de compra reciente.',
      fecha: daysBefore(reference, 15),
      tipo: 'Sanidad',
      animalIds: [demoAnimalUuid(aniPrietitaSlug)],
      locationSlug: locCuarentenaSlug,
      estado: AgendaEstado.verificado,
      fechaCompletado: daysBefore(reference, 14),
      prioridad: AgendaPrioridad.urgente,
      assigneeSlug: workerVetHelperSlug,
      notas: 'Registro de demostración.',
    ),
    // Cancelada.
    base(
      slug: 'visita-proveedor',
      titulo: 'Visita de proveedor de alimento',
      descripcion: 'Visita reprogramada por el proveedor.',
      fecha: daysBefore(reference, 8),
      tipo: 'Administrativo',
      estado: AgendaEstado.cancelado,
      prioridad: AgendaPrioridad.baja,
      assigneeSlug: workerOwnerSlug,
      blockedReason: 'Proveedor reprogramó la visita.',
      notas: 'Registro de demostración.',
    ),
  ];
}
