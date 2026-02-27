class AppRoutes {
  static const directorio = '/directorio';
  static const inicio = '/';
  static const animales = '/animales';
  static const animalDetalle = '/directorio/animales/:uuid';
  static const eventos = '/eventos';
  static const ubicaciones = '/ubicaciones';
  static const perfil = '/perfil';

  static const nameDirectorio = 'directorio';
  static const nameInicio = 'inicio';
  static const nameAnimales = 'animales';
  static const nameAnimalDetalle = 'animal_detalle';
  static const nameEventos = 'eventos';
  static const nameUbicaciones = 'ubicaciones';
  static const namePerfil = 'perfil';

  static String animalDetallePath(String uuid) => '/directorio/animales/$uuid';
}
