/// features \u203a directorio \u203a animales \u203a infrastructure \u203a services \u203a batch_migration_service \u2014 migrates legacy animal data in batches.
library;

import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

/// Servicio para migrar datos de batch de string a UUID
/// Crea LoteEntity para cada nombre de lote único si no existen
/// y actualiza animals.batchUuid para apuntar a la entidad correspondiente
class BatchMigrationService {
  BatchMigrationService({
    required AnimalRepository animalRepository,
    required LotesRepository lotesRepository,
  }) : _animalRepository = animalRepository,
       _lotesRepository = lotesRepository;
  static const _logTag = 'BatchMigrationService';

  final AnimalRepository _animalRepository;
  final LotesRepository _lotesRepository;

  /// Ejecutar la migración
  /// Retorna true si se ejecutó migración, false si ya estaba completada
  Future<bool> migrate() async {
    try {
      LoggerService.d('Iniciando migración de lotes...', tag: _logTag);

      // Obtener todos los animales
      final animals = await _animalRepository.getAll();

      // Recolectar nombres de lotes únicos
      final batchNames = <String>{};
      for (final animal in animals) {
        if (animal.batchUuid == null && animal.batchId != null) {
          // Animal aún tiene el formato antiguo
          batchNames.add(animal.batchId!);
        }
      }

      if (batchNames.isEmpty) {
        LoggerService.d('No hay datos antiguos para migrar', tag: _logTag);
        return false;
      }

      LoggerService.d(
        'Encontrados ${batchNames.length} nombres de lotes únicos para migrar',
        tag: _logTag,
      );

      // Obtener lotes existentes
      final existingLotes = await _lotesRepository.getAll();
      final existingLotesByName = <String, String>{}; // nombre -> uuid
      for (final lote in existingLotes) {
        existingLotesByName[lote.nombre] = lote.uuid;
      }

      // Crear LoteEntity para cada nombre si no existe
      final createdLotes = <String, String>{}; // nombre -> uuid
      for (final batchName in batchNames) {
        if (existingLotesByName.containsKey(batchName)) {
          createdLotes[batchName] = existingLotesByName[batchName]!;
          LoggerService.d(
            'Lote "$batchName" ya existe con uuid: ${createdLotes[batchName]}',
            tag: _logTag,
          );
        } else {
          try {
            final newLote = await _lotesRepository.createLote(
              nombre: batchName,
              descripcion: 'Migrado desde asignación de lote anterior',
            );
            createdLotes[batchName] = newLote.uuid;
            LoggerService.i(
              'Lote "$batchName" creado con uuid: ${newLote.uuid}',
              tag: _logTag,
            );
          } catch (e, st) {
            LoggerService.e(
              'Error creando lote $batchName: $e',
              tag: _logTag,
              stackTrace: st,
            );
          }
        }
      }

      // Actualizar animales con las nuevas referencias
      int migratedCount = 0;
      for (final animal in animals) {
        if (animal.batchUuid == null && animal.batchId != null) {
          final batchName = animal.batchId!;
          final loteUuid = createdLotes[batchName];

          if (loteUuid != null) {
            final updatedAnimal = animal.copyWith(batchUuid: loteUuid);
            await _animalRepository.update(updatedAnimal);

            // Agregar el animal a la lista del lote
            await _lotesRepository.addAnimalToLote(
              loteUuid: loteUuid,
              animalUuid: animal.uuid,
            );

            migratedCount++;
            LoggerService.d(
              'Animal ${animal.uuid} migrado a lote $batchName (uuid: $loteUuid)',
              tag: _logTag,
            );
          } else {
            LoggerService.w(
              'No se pudo encontrar/crear lote para animal ${animal.uuid} con nombre "$batchName"',
              tag: _logTag,
            );
          }
        }
      }

      LoggerService.i(
        'Migración completada: $migratedCount animales migrados',
        tag: _logTag,
      );
      return true;
    } catch (e, st) {
      LoggerService.e(
        'Error durante migración de lotes: $e',
        tag: _logTag,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
