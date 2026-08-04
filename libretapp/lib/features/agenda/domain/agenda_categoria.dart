/// features › agenda › domain › agenda_categoria — top-level grouping for agenda tipo values.
library;

enum AgendaCategoria {
  sanidad,
  reproduccion,
  produccion,
  movimientos,
  administracion,
  otros,
}

extension AgendaCategoriaX on AgendaCategoria {
  String get label => switch (this) {
    AgendaCategoria.sanidad => 'Sanidad',
    AgendaCategoria.reproduccion => 'Reproducción',
    AgendaCategoria.produccion => 'Producción',
    AgendaCategoria.movimientos => 'Movimientos',
    AgendaCategoria.administracion => 'Administración',
    AgendaCategoria.otros => 'Otros',
  };
}

AgendaCategoria categoriaForTipo(String tipo) {
  switch (tipo.toLowerCase()) {
    case 'sanidad':
    case 'vacunación':
    case 'desparasitación':
    case 'baño garrapaticida':
    case 'suplemento/vitaminas':
    case 'revisión de casco':
    case 'revisión veterinaria':
    case 'cuidado':
      return AgendaCategoria.sanidad;
    case 'inseminación':
    case 'parto':
    case 'gestación':
    case 'chequeo reproductivo':
      return AgendaCategoria.reproduccion;
    case 'pesaje':
      return AgendaCategoria.produccion;
    case 'movimiento de lote':
      return AgendaCategoria.movimientos;
    case 'mantenimiento':
    case 'administración':
    case 'administrativo':
    case 'alerta':
    case 'recordatorio':
      return AgendaCategoria.administracion;
    default:
      return AgendaCategoria.otros;
  }
}
