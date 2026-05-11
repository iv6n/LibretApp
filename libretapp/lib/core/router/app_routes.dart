/// core › router › app_routes — named route constants for GoRouter.
library;

/// Holds all named route paths used by GoRouter throughout the application.
class AppRoutes {
  static const directorio = '/directorio';
  static const inicio = '/';
  static const animales = '/animales';
  static const animalNuevo = '/directorio/animales/nuevo';
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
  static const loteNuevo = '/directorio/lotes/nuevo';
  static const loteDetalle = '/directorio/lotes/:uuid';
  static const loteEditar = '/directorio/lotes/:uuid/editar';
  static const agenda = '/agenda';
  static const agendaNuevo = '/agenda/nuevo';
  static const agendaTask = '/agenda/task/:id';
  static const ubicaciones = '/ubicaciones';
  static const ubicacionNueva = '/ubicaciones/nueva';
  static const ubicacionDetalle = '/ubicaciones/:uuid';
  static const ubicacionEditar = '/ubicaciones/:uuid/editar';
  static const perfil = '/perfil';
  static const registro = '/registro';
  static const registroSanitario = '/registro/sanitario';
  static const registroPeso = '/registro/peso';
  static const registroProduccion = '/registro/produccion';
  static const registroReproduccion = '/registro/reproduccion';
  static const registroComercial = '/registro/comercial';
  static const registroMovimiento = '/registro/movimiento';
  static const registroCosto = '/registro/costo';
  static const registroIngreso = '/registro/ingreso';
  static const registroGastoGeneral = '/registro/gasto-general';
  static const finanzas = '/finanzas';
  static const exportar = '/exportar';

  static const nameDirectorio = 'directorio';
  static const nameInicio = 'inicio';
  static const nameAnimales = 'animales';
  static const nameAnimalNuevo = 'animal_nuevo';
  static const nameAnimalDetalle = 'animal_detalle';
  static const nameAnimalRegistroPeso = 'animal_registro_peso';
  static const nameAnimalRegistroReproduccion = 'animal_registro_reproduccion';
  static const nameAnimalRegistroSalud = 'animal_registro_salud';
  static const nameAnimalRegistroProduccion = 'animal_registro_produccion';
  static const nameAnimalRegistroMovimiento = 'animal_registro_movimiento';
  static const nameAnimalRegistroComercial = 'animal_registro_comercial';
  static const nameAnimalRegistroCosto = 'animal_registro_costo';
  static const nameAnimalEditar = 'animal_editar';
  static const nameLoteNuevo = 'lote_nuevo';
  static const nameLoteDetalle = 'lote_detalle';
  static const nameLoteEditar = 'lote_editar';
  static const nameAgenda = 'agenda_page';
  static const nameAgendaNuevo = 'agenda_nuevo';
  static const nameAgendaTask = 'agenda_task';
  static const nameUbicaciones = 'ubicaciones';
  static const nameUbicacionNueva = 'ubicacion_nueva';
  static const nameUbicacionDetalle = 'ubicacion_detalle';
  static const nameUbicacionEditar = 'ubicacion_editar';
  static const namePerfil = 'perfil';
  static const nameRegistro = 'registro';
  static const nameRegistroSanitario = 'registro_sanitario';
  static const nameRegistroPeso = 'registro_peso';
  static const nameRegistroProduccion = 'registro_produccion';
  static const nameRegistroReproduccion = 'registro_reproduccion';
  static const nameRegistroComercial = 'registro_comercial';
  static const nameRegistroMovimiento = 'registro_movimiento';
  static const nameRegistroCosto = 'registro_costo';
  static const nameRegistroIngreso = 'registro_ingreso';
  static const nameRegistroGastoGeneral = 'registro_gasto_general';
  static const nameFinanzas = 'finanzas';
  static const nameExportar = 'exportar';

  static String animalNuevoPath() => '/directorio/animales/nuevo';
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
  static String loteNuevoPath() => '/directorio/lotes/nuevo';
  static String loteDetallePath(String uuid) => '/directorio/lotes/$uuid';
  static String loteEditarPath(String uuid) => '/directorio/lotes/$uuid/editar';
  static String ubicacionNuevaPath() => '/ubicaciones/nueva';
  static String ubicacionDetallePath(String uuid) => '/ubicaciones/$uuid';
  static String ubicacionEditarPath(String uuid) => '/ubicaciones/$uuid/editar';
  static String agendaNuevoPath() => '/agenda/nuevo';
}
