import 'package:libretapp/features/eventos/data/eventos_model.dart';

abstract class EventosRepository {
  Future<List<Evento>> fetchEventos();
  Future<Evento> getEvento(String id);
  Future<void> saveEvento(Evento evento);
  Future<void> deleteEvento(String id);
  Future<void> updateEvento(Evento evento);
}

class EventosRepositoryImpl implements EventosRepository {
  final List<Evento> _mockStore = [
    Evento(
      id: 'evt-1',
      titulo: 'Vacunación clostridios',
      descripcion: 'Refuerzo para vaquillas nuevas',
      fecha: DateTime.now().add(const Duration(days: 2)),
      tipo: 'Vacunación',
      animalId: 'uuid-rosario',
      ubicacion: 'potrero-b',
    ),
    Evento(
      id: 'evt-2',
      titulo: 'Pesaje terminación',
      descripcion: 'Control de ganado en feedlot',
      fecha: DateTime.now().add(const Duration(days: 1)),
      tipo: 'Pesaje',
      animalId: 'uuid-trueno',
      ubicacion: 'feedlot-1',
    ),
    Evento(
      id: 'evt-3',
      titulo: 'Ecografía preñez',
      descripcion: 'Confirmar gestación en Pampa',
      fecha: DateTime.now().add(const Duration(days: 4)),
      tipo: 'Reproducción',
      animalId: 'uuid-pampa',
      ubicacion: 'potrero-b',
    ),
    Evento(
      id: 'evt-4',
      titulo: 'Control mastitis',
      descripcion: 'Revisión y tratamiento cerda Luna',
      fecha: DateTime.now().add(const Duration(days: 3)),
      tipo: 'Salud',
      animalId: 'uuid-cerdita',
      ubicacion: 'feedlot-1',
    ),
    Evento(
      id: 'evt-5',
      titulo: 'Revisión cascos',
      descripcion: 'Limpiar y revisar caballos de trabajo',
      fecha: DateTime.now().add(const Duration(days: 6)),
      tipo: 'Mantenimiento',
      animalId: 'uuid-potro',
      ubicacion: 'rancho-trabajo',
    ),
    Evento(
      id: 'evt-6',
      titulo: 'Rotación potrero D',
      descripcion: 'Mover lotes en observación',
      fecha: DateTime.now().add(const Duration(days: -1)),
      tipo: 'Movimiento',
      animalId: 'uuid-gaia',
      ubicacion: 'potrero-d',
    ),
    Evento(
      id: 'evt-7',
      titulo: 'Cambio bebederos',
      descripcion: 'Limpieza y clorado',
      fecha: DateTime.now().add(const Duration(days: 5)),
      tipo: 'Mantenimiento',
      animalId: 'uuid-gallina',
      ubicacion: 'gallinero-central',
    ),
    Evento(
      id: 'evt-8',
      titulo: 'Pesaje cabras pre-parto',
      descripcion: 'Verificar condición de Lira',
      fecha: DateTime.now().add(const Duration(days: 5)),
      tipo: 'Pesaje',
      animalId: 'uuid-lira',
      ubicacion: 'potrero-c',
    ),
  ];

  @override
  Future<List<Evento>> fetchEventos() async {
    // Simula una llamada a base de datos
    await Future.delayed(const Duration(milliseconds: 250));
    _mockStore.sort((a, b) => a.fecha.compareTo(b.fecha));
    return List.unmodifiable(_mockStore);
  }

  @override
  Future<Evento> getEvento(String id) async {
    final eventos = await fetchEventos();
    return eventos.firstWhere((e) => e.id == id);
  }

  @override
  Future<void> saveEvento(Evento evento) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _mockStore.add(evento);
  }

  @override
  Future<void> deleteEvento(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _mockStore.removeWhere((e) => e.id == id);
  }

  @override
  Future<void> updateEvento(Evento evento) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _mockStore.indexWhere((e) => e.id == evento.id);
    if (index != -1) {
      _mockStore[index] = evento;
    }
  }
}
