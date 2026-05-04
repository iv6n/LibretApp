/// core › router › app_routes — named route constants for GoRouter.
library;

/// Holds all named route paths used by GoRouter throughout the application.
class AppRoutes {
  static const directorio = '/directorio';
  static const inicio = '/';
  static const animales = '/animales';
  static const animalNuevo = '/directorio/animales/nuevo';
  static const animalDetalle = '/directorio/animales/:uuid';
  static const animalEditar = '/directorio/animales/:uuid/editar';
  static const loteNuevo = '/directorio/lotes/nuevo';
  static const loteDetalle = '/directorio/lotes/:uuid';
  static const loteEditar = '/directorio/lotes/:uuid/editar';
  static const eventos = '/eventos';
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

  static const nameDirectorio = 'directorio';
  static const nameInicio = 'inicio';
  static const nameAnimales = 'animales';
  static const nameAnimalNuevo = 'animal_nuevo';
  static const nameAnimalDetalle = 'animal_detalle';
  static const nameAnimalEditar = 'animal_editar';
  static const nameLoteNuevo = 'lote_nuevo';
  static const nameLoteDetalle = 'lote_detalle';
  static const nameLoteEditar = 'lote_editar';
  static const nameEventos = 'eventos';
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

  static String animalNuevoPath() => '/directorio/animales/nuevo';
  static String animalDetallePath(String uuid) => '/directorio/animales/$uuid';
  static String animalEditarPath(String uuid) =>
      '/directorio/animales/$uuid/editar';
  static String loteNuevoPath() => '/directorio/lotes/nuevo';
  static String loteDetallePath(String uuid) => '/directorio/lotes/$uuid';
  static String loteEditarPath(String uuid) => '/directorio/lotes/$uuid/editar';
  static String ubicacionNuevaPath() => '/ubicaciones/nueva';
  static String ubicacionDetallePath(String uuid) => '/ubicaciones/$uuid';
  static String ubicacionEditarPath(String uuid) => '/ubicaciones/$uuid/editar';
}
