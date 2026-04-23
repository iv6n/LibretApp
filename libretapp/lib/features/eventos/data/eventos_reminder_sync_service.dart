import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/services/reproduction_scheduler.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/eventos/data/eventos_model.dart';
import 'package:libretapp/features/eventos/data/eventos_repository.dart';

class EventosReminderSyncService {
  EventosReminderSyncService({
    required AnimalRepository animalRepository,
    required EventosRepository eventosRepository,
    ReproductionScheduler? reproductionScheduler,
  }) : _animalRepository = animalRepository,
       _eventosRepository = eventosRepository,
       _reproductionScheduler =
           reproductionScheduler ?? const ReproductionScheduler();

  final AnimalRepository _animalRepository;
  final EventosRepository _eventosRepository;
  final ReproductionScheduler _reproductionScheduler;

  Future<int> sync() async {
    final existing = await _eventosRepository.fetchEventos();
    final manual = existing
        .where((e) => !_isAutoEvent(e.id))
        .toList(growable: true);

    final desiredAuto = await _buildAutoEvents();

    final merged = <Evento>[...manual, ...desiredAuto];

    await _eventosRepository.replaceAll(merged);
    return desiredAuto.length;
  }

  bool _isAutoEvent(String id) => id.startsWith('auto:');

  Future<List<Evento>> _buildAutoEvents() async {
    final animals = await _animalRepository.getAll();
    final desired = <String, Evento>{};

    for (final animal in animals) {
      final healthRecords = await _animalRepository.getHealthRecords(
        animal.uuid,
      );
      for (final record in healthRecords) {
        final date = record.nextDueDate;
        if (date == null) continue;
        if (!_isReminderHealthType(record.type)) continue;

        final typeLabel = _healthTypeLabel(record.type);
        final sourceId =
            record.id ?? record.date.millisecondsSinceEpoch.toString();
        final eventId =
            'auto:health:${animal.uuid}:${record.type.name}:$sourceId:${_dateKey(date)}';
        desired[eventId] = Evento(
          id: eventId,
          titulo: '$typeLabel - ${_animalLabel(animal)}',
          descripcion: 'Recordatorio automático basado en registro sanitario.',
          fecha: _startOfDay(date),
          tipo: typeLabel,
          animalId: animal.uuid,
          ubicacion: animal.currentPaddockId ?? 'Sin ubicación',
        );
      }

      final reproRecords = await _animalRepository.getReproductionRecords(
        animal.uuid,
      );
      for (final record in reproRecords) {
        final sourceId =
            record.id ?? record.serviceDate.millisecondsSinceEpoch.toString();
        final schedule = _reproductionScheduler.estimate(
          serviceDate: record.serviceDate,
        );

        final pregCheckDate =
            record.pregnancyCheckDate ?? schedule.pregnancyCheckDate;
        if (pregCheckDate != null &&
            record.pregnancyResult != PregnancyCheckResult.positive) {
          final date = _startOfDay(pregCheckDate);
          final id =
              'auto:repro:${animal.uuid}:pregcheck:$sourceId:${_dateKey(date)}';
          desired[id] = Evento(
            id: id,
            titulo: 'Chequeo de preñez - ${_animalLabel(animal)}',
            descripcion:
                'Control automático de gestación (35 días post servicio).',
            fecha: date,
            tipo: 'Reproducción',
            animalId: animal.uuid,
            ubicacion: animal.currentPaddockId ?? 'Sin ubicación',
          );
        }

        final dueDate = _startOfDay(
          record.expectedCalvingDate ?? schedule.dueDate,
        );
        if (record.actualCalvingDate == null) {
          final partoId =
              'auto:repro:${animal.uuid}:parto:$sourceId:${_dateKey(dueDate)}';
          desired[partoId] = Evento(
            id: partoId,
            titulo: 'Parto estimado - ${_animalLabel(animal)}',
            descripcion: 'Fecha estimada de parto según último servicio.',
            fecha: dueDate,
            tipo: 'Gestación',
            animalId: animal.uuid,
            ubicacion: animal.currentPaddockId ?? 'Sin ubicación',
          );

          final pre21 = dueDate.subtract(const Duration(days: 21));
          final pre7 = dueDate.subtract(const Duration(days: 7));

          final pre21Id =
              'auto:repro:${animal.uuid}:parto-pre21:$sourceId:${_dateKey(pre21)}';
          desired[pre21Id] = Evento(
            id: pre21Id,
            titulo: 'Parto próximo (21 días) - ${_animalLabel(animal)}',
            descripcion: 'Preparar manejo preparto y monitoreo.',
            fecha: pre21,
            tipo: 'Gestación',
            animalId: animal.uuid,
            ubicacion: animal.currentPaddockId ?? 'Sin ubicación',
          );

          final pre7Id =
              'auto:repro:${animal.uuid}:parto-pre7:$sourceId:${_dateKey(pre7)}';
          desired[pre7Id] = Evento(
            id: pre7Id,
            titulo: 'Parto próximo (7 días) - ${_animalLabel(animal)}',
            descripcion: 'Revisión final preparto.',
            fecha: pre7,
            tipo: 'Gestación',
            animalId: animal.uuid,
            ubicacion: animal.currentPaddockId ?? 'Sin ubicación',
          );
        }
      }
    }

    return desired.values.toList(growable: false)
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
  }

  bool _isReminderHealthType(HealthRecordType type) {
    return type == HealthRecordType.vaccine ||
        type == HealthRecordType.deworming;
  }

  String _healthTypeLabel(HealthRecordType type) {
    switch (type) {
      case HealthRecordType.vaccine:
        return 'Vacunación';
      case HealthRecordType.deworming:
        return 'Desparasitación';
      default:
        return 'Salud';
    }
  }

  String _animalLabel(AnimalEntity animal) {
    if (animal.customName != null && animal.customName!.trim().isNotEmpty) {
      return animal.customName!.trim();
    }
    if (animal.visualId != null && animal.visualId!.trim().isNotEmpty) {
      return animal.visualId!.trim();
    }
    return animal.earTagNumber;
  }

  String _dateKey(DateTime date) {
    final d = _startOfDay(date);
    return '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
  }

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
