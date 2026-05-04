/// features \u203a directorio \u203a lotes \u203a infrastructure \u203a lotes_repository \u2014 abstract LotesRepository port.
library;

import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';

/// Interfaz del repositorio para gestionar Lotes
abstract class LotesRepository {
  /// Observar todos los lotes disponibles
  Stream<List<LoteEntity>> watchAll();

  /// Obtener todos los lotes
  Future<List<LoteEntity>> getAll();

  /// Obtener un lote por UUID
  Future<LoteEntity?> getByUuid(String uuid);

  /// Crear un nuevo lote
  Future<LoteEntity> createLote({
    required String nombre,
    String? descripcion,
    String? notas,
  });

  /// Actualizar un lote existente
  Future<void> updateLote(LoteEntity lote);

  /// Eliminar un lote
  Future<void> deleteLote(String uuid);

  /// Agregar un animal a un lote
  Future<void> addAnimalToLote({
    required String loteUuid,
    required String animalUuid,
  });

  /// Agregar múltiples animales a un lote
  Future<void> addAnimalsToLote({
    required String loteUuid,
    required List<String> animalUuids,
  });

  /// Remover un animal de un lote
  Future<void> removeAnimalFromLote({
    required String loteUuid,
    required String animalUuid,
  });

  /// Remover múltiples animales de un lote
  Future<void> removeAnimalsFromLote({
    required String loteUuid,
    required List<String> animalUuids,
  });

  /// Obtener el UUID del lote que contiene un animal específico
  /// Retorna null si el animal no está en ningún lote
  Future<String?> getLoteThatContainsAnimal(String animalUuid);

  /// Obtener todos los lotes activos
  Future<List<LoteEntity>> getActiveLotes();

  /// Obtener todos los lotes inactivos
  Future<List<LoteEntity>> getInactiveLotes();
}
