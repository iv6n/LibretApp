/// core › router › app_routes — named route constants for GoRouter.
library;

/// Holds all named route paths used by GoRouter throughout the application.
class AppRoutes {
  static const directorio = '/directorio';
  static const inicio = '/';
  static const animales = '/directorio?tab=animales';
  static const animalNuevo = '/directorio/animales/nuevo';
  static const animalNuevoRapido = '/directorio/animales/nuevo-rapido';
  static const animalDetalle = '/directorio/animales/:uuid';
  static const animalRegistroPeso = '/directorio/animales/:uuid/registros/peso';
  static const animalRegistroReproduccion =
      '/directorio/animales/:uuid/registros/reproduccion';
  static const animalRegistroSalud =
      '/directorio/animales/:uuid/registros/salud';
  static const animalRegistroProduccion =
      '/directorio/animales/:uuid/registros/produccion';
  static const animalRegistroMovimiento =
      '/directorio/animales/:uuid/registros/movimiento';
  static const animalRegistroComercial =
      '/directorio/animales/:uuid/registros/comercial';
  static const animalRegistroCosto =
      '/directorio/animales/:uuid/registros/costo';
  static const animalEditar = '/directorio/animales/:uuid/editar';
  static const animalCompletar = '/directorio/animales/:uuid/completar';
  static const loteNuevo = '/directorio/lotes/nuevo';
  static const loteDetalle = '/directorio/lotes/:uuid';
  static const loteEditar = '/directorio/lotes/:uuid/editar';
  static const agenda = '/agenda';
  static const agendaNuevo = '/agenda/nuevo';
  static const agendaTask = '/agenda/task/:id';
  static const reportes = '/reportes';
  static const ubicaciones = '/directorio?tab=ubicaciones';
  static const ubicacionesLegacy = '/ubicaciones';
  static const ubicacionNueva = '/directorio/ubicaciones/nueva';
  static const ubicacionDetalle = '/directorio/ubicaciones/:uuid';
  static const ubicacionEditar = '/directorio/ubicaciones/:uuid/editar';
  static const perfil = '/perfil';
  static const registro = '/registro';
  static const registroSanitario = '/registro/sanitario';
  static const registroPeso = '/registro/peso';
  static const registroProduccion = '/registro/produccion';
  static const registroOrdena = '/registro/ordena';
  static const registroReproduccion = '/registro/reproduccion';
  static const registroComercial = '/registro/comercial';
  static const registroMovimiento = '/registro/movimiento';
  static const registroCosto = '/registro/costo';
  static const registroIngreso = '/registro/ingreso';
  static const registroGastoGeneral = '/registro/gasto-general';
  static const registroTratarLote = '/registro/tratar-lote';
  static const finanzas = '/finanzas';
  static const exportar = '/exportar';
  static const perfilReporte = '/perfil/reporte/:tipo';
  static const perfilBibliotecaItem = '/perfil/biblioteca/:id';

  static const nameDirectorio = 'directorio';
  static const nameInicio = 'inicio';
  static const nameAnimalNuevo = 'animal_nuevo';
  static const nameAnimalNuevoRapido = 'animal_nuevo_rapido';
  static const nameAnimalDetalle = 'animal_detalle';
  static const nameAnimalRegistroPeso = 'animal_registro_peso';
  static const nameAnimalRegistroReproduccion = 'animal_registro_reproduccion';
  static const nameAnimalRegistroSalud = 'animal_registro_salud';
  static const nameAnimalRegistroProduccion = 'animal_registro_produccion';
  static const nameAnimalRegistroMovimiento = 'animal_registro_movimiento';
  static const nameAnimalRegistroComercial = 'animal_registro_comercial';
  static const nameAnimalRegistroCosto = 'animal_registro_costo';
  static const nameAnimalEditar = 'animal_editar';
  static const nameAnimalCompletar = 'animal_completar';
  static const nameLoteNuevo = 'lote_nuevo';
  static const nameLoteDetalle = 'lote_detalle';
  static const nameLoteEditar = 'lote_editar';
  static const nameAgenda = 'agenda_page';
  static const nameAgendaNuevo = 'agenda_nuevo';
  static const nameAgendaTask = 'agenda_task';
  static const nameReportes = 'reportes';
  static const nameUbicaciones = 'ubicaciones';
  static const nameUbicacionNueva = 'ubicacion_nueva';
  static const nameUbicacionDetalle = 'ubicacion_detalle';
  static const nameUbicacionEditar = 'ubicacion_editar';
  static const namePerfil = 'perfil';
  static const nameRegistro = 'registro';
  static const nameRegistroSanitario = 'registro_sanitario';
  static const nameRegistroPeso = 'registro_peso';
  static const nameRegistroProduccion = 'registro_produccion';
  static const nameRegistroOrdena = 'registro_ordena';
  static const nameRegistroReproduccion = 'registro_reproduccion';
  static const nameRegistroComercial = 'registro_comercial';
  static const nameRegistroMovimiento = 'registro_movimiento';
  static const nameRegistroCosto = 'registro_costo';
  static const nameRegistroIngreso = 'registro_ingreso';
  static const nameRegistroGastoGeneral = 'registro_gasto_general';
  static const nameRegistroTratarLote = 'registro_tratar_lote';
  static const nameFinanzas = 'finanzas';
  static const nameExportar = 'exportar';
  static const namePerfilReporte = 'perfil_reporte';
  static const namePerfilBibliotecaItem = 'perfil_biblioteca_item';

  static String animalNuevoPath() => '/directorio/animales/nuevo';
  static String animalNuevoRapidoPath() => '/directorio/animales/nuevo-rapido';
  static String animalDetallePath(String uuid) => '/directorio/animales/$uuid';
  static String animalRegistroPesoPath(String uuid) =>
      '/directorio/animales/$uuid/registros/peso';
  static String animalRegistroReproduccionPath(String uuid) =>
      '/directorio/animales/$uuid/registros/reproduccion';
  static String animalRegistroSaludPath(String uuid) =>
      '/directorio/animales/$uuid/registros/salud';
  static String animalRegistroProduccionPath(String uuid) =>
      '/directorio/animales/$uuid/registros/produccion';
  static String animalRegistroMovimientoPath(String uuid) =>
      '/directorio/animales/$uuid/registros/movimiento';
  static String animalRegistroComercialPath(String uuid) =>
      '/directorio/animales/$uuid/registros/comercial';
  static String animalRegistroCostoPath(String uuid) =>
      '/directorio/animales/$uuid/registros/costo';
  static String animalEditarPath(String uuid) =>
      '/directorio/animales/$uuid/editar';
  static String animalCompletarPath(String uuid) =>
      '/directorio/animales/$uuid/completar';
  static String loteNuevoPath() => '/directorio/lotes/nuevo';
  static String loteDetallePath(String uuid) => '/directorio/lotes/$uuid';
  static String loteEditarPath(String uuid) => '/directorio/lotes/$uuid/editar';
  /// Builds a deep link into the animals tab of the directory, optionally
  /// pre-applying one of the list filters. There is no standalone `/animales`
  /// route: the list lives inside the directory shell branch.
  static String animalesPath({
    bool attention = false,
    bool pendingEarTag = false,
  }) {
    final buffer = StringBuffer('/directorio?tab=animales');
    if (attention) buffer.write('&attention=true');
    if (pendingEarTag) buffer.write('&pendingEarTag=true');
    return buffer.toString();
  }

  static String directorioUbicacionesPath() => '/directorio?tab=ubicaciones';
  static String ubicacionNuevaPath() => '/directorio/ubicaciones/nueva';
  static String ubicacionDetallePath(String uuid) =>
      '/directorio/ubicaciones/$uuid';
  static String ubicacionEditarPath(String uuid) =>
      '/directorio/ubicaciones/$uuid/editar';
  static String agendaNuevoPath() => '/agenda/nuevo';
  static String registroTratarLotePath() => '/registro/tratar-lote';
  static String perfilReportePath(String tipo) => '/perfil/reporte/$tipo';
  static String perfilBibliotecaItemPath(String id) => '/perfil/biblioteca/$id';
}
