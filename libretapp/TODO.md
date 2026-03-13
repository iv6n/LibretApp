# TODO - Plan de Limpieza y Reacomodo de Datos/Modelos

## Objetivo
Unificar estructura de datos y modelos para reducir duplicidad, mejorar mantenibilidad y evitar regresiones funcionales.

## Criterios de exito
- Una sola fuente de verdad por modelo/enum.
- Capas claras: dominio, aplicacion, infraestructura, UI.
- Imports consistentes por modulo.
- Sin errores de analisis en archivos tocados.
- Pruebas relevantes pasando.

## Estado actual
- [x] Remover duplicados de enums en animales (sex/life_stage en entities).
- [x] Convertir animales.dart en barrel de compatibilidad hacia animals.dart.
- [x] Continuar consolidacion de barrels e imports en features.

## Fase 1 - Consolidacion de modelos y enums
- [x] Revisar duplicados restantes por feature: animales, lotes, ubicaciones, eventos.
- [x] Eliminar definiciones redundantes sin uso.
- [x] Mantener solo modelos canonicos por dominio.
- [x] Verificar referencias tras cada eliminacion.

## Fase 2 - Orden de capas y contratos
- [x] Verificar que entidades de dominio no dependan de UI.
- [x] Confirmar contratos de repositorio por feature (metodos, nombres y tipos).
- [x] Alinear DTOs/mappers con entidades de dominio.
- [x] Reducir uso de dynamic y map generico en BLoCs.

## Fase 3 - Imports y barrels
- [x] Estandarizar imports para usar barrels oficiales por modulo.
- [x] Evitar doble punto de entrada (archivo canonico + compatibilidad temporal).
- [x] Marcar barrels legacy para retiro controlado.

## Fase 4 - Persistencia y migracion
- [x] Validar impacto de cambios sobre Isar y mappers.
- [x] Revisar datos seed y compatibilidad de campos.
- [x] Definir cambios de esquema pendientes y su plan de migracion.

## Fase 5 - Validacion y calidad
- [x] Ejecutar diagnosticos en archivos tocados.
- [x] Ejecutar pruebas unitarias relevantes por feature.
- [x] Corregir advertencias que afecten estabilidad/consistencia.

## Entregables
- [x] Codigo consolidado sin duplicidad critica.
- [x] Lista de cambios por feature con rationale.
- [x] Plan de retiro de compatibilidad legacy.
- [x] Resumen final de arquitectura de modelos.

## Cambios implementados en esta iteracion
- Lotes: `lotes.dart` queda como barrel canonico y se retiro el wrapper legacy `lotes_barrel.dart`.
- Directorio: se elimina export redundante de `animal_bloc.dart` y de `animales_tab_bloc.dart` para evitar doble entrada via barrels.
- Directorio: se reemplaza export legacy `animales/animales.dart` por export canonico `animales/animals.dart`.
- Validacion: sin errores de analisis y pruebas del proyecto en verde (9 pasando).

## Plan de retiro de compatibilidad legacy
- Wrappers legacy retirados: `animales.dart` y `lotes_barrel.dart` eliminados tras migrar consumidores al barrel canónico.
- Punto de entrada oficial: `animals.dart` y `lotes.dart`.

## Validaciones adicionales (continuacion)
- Dominio (entities): sin imports directos de UI en `domain/entities` por feature.
- Contratos de repositorio: contratos abstractos con implementaciones activas en animales, lotes, ubicaciones, eventos y perfil.
- DTOs/mappers: mapeos `toEntity` / `toIsar` / `fromEntity` consistentes con entidades actuales.
- BLoCs: búsqueda combinada de directorio sin `dynamic` en helpers de matching/mapeo.
- Búsqueda combinada: `CombinedSearchResult` simplificado (sin `Map<String, Object?> data`) para evitar payload genérico no utilizado.
- Búsqueda combinada robustecida: query normalizada (`trim/lowercase`), coincidencia por `id` además de `name`, y deduplicación por `type:id`.
- Capa dominio animales: `animal_palette.dart` movido de `domain` a `widgets` para eliminar dependencia Flutter dentro de dominio.
- Compatibilidad legacy: sin referencias activas a `animales.dart` o `lotes_barrel.dart` en workspace.

## Plan de migracion de esquema (Isar)
- Versionar cambios de estructura de ubicaciones (kind/jerarquia/atributos dinamicos/salt/shade) en una migracion controlada.
- En apertura de BD, detectar colecciones previas y aplicar defaults seguros para campos nuevos.
- Ejecutar backfill idempotente para seeds y relaciones padre-hijo (sin duplicar registros).
- Verificar integridad post-migracion: conteo de registros, claves unicas por uuid y mapeo reversible entidad<->isar.
- Retirar compatibilidad temporal de campos legacy solo despues de una ventana de validacion en builds internas.

## Resumen final de arquitectura de modelos
- Dominio: entidades y enums canonicos por feature (sin duplicidad critica).
- Aplicacion: BLoCs tipados por entidad (menos `dynamic`, menos Map generico).
- Infraestructura: repositorios/DTOs/mappers Isar alineados con dominio.
- UI: consumo via barrels canonicos por modulo y wrappers legacy acotados para retiro gradual.

## Nota de ejecucion
Trabajar en cambios pequenos y verificables: editar, validar diagnosticos, luego avanzar a la siguiente tarea.