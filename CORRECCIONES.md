# Correcciones a la Auditoría LibretApp — Julio 2026

> Este documento cruza cada hallazgo del reporte original (`auditoria-libretapp-actualizada.html` en esta misma carpeta, o el artifact original) contra el estado **real y verificado** del código en la rama `main-5enhm8` a día de hoy. Cada afirmación de "arreglado" fue confirmada con grep/lectura del archivo, no con memoria de lo que se hizo — y en el camino aparecieron 3 correcciones al propio audit (no eran del todo precisas).
>
> Archivos hermanos en esta carpeta: `auditoria-estado.json` (para que yo lo use como memoria de trabajo en próximas sesiones) y `auditoria-libretapp-actualizada.html` (la misma pieza visual del audit original, con el estado de cada item marcado).
>
> **Estos 3 archivos son locales — no están en git, no se van a commitear ni pushear.**

## Resumen

| Bloque | Total | Resuelto | Pendiente | Mantenido a propósito |
|---|---|---|---|---|
| Hallazgos críticos | 16 (el audit decía 17, error propio — ver abajo) | 10 | 6 | — |
| Archivos a eliminar | 28 filas | 17 | 6 | 5 (Care*, land_tenure, domain.dart, MilkingSession/Entry json — 2 de estos porque el audit se equivocó) |
| Archivos a modificar | 16 | 10 | 6 | — |

Fases ya ejecutadas y pusheadas a `main-5enhm8` (PR #1): Fase 0 (CI), Fase 1.1–1.4 (pérdida de datos + bug copy-paste), Fase 2 (5 bugs de estado/crash), Fase 3 (2 cálculos incorrectos), Fase 5 (código muerto confirmado). **Fase 4 (seguridad) nunca se ejecutó** — sigue pendiente en su totalidad.

---

## 1. Errores encontrados en el audit original

1. **Conteo de hallazgos críticos.** El stat-grid dice "17" pero el documento solo contiene 16 `<div class="crit-item">`. Desajuste interno del propio reporte, no algo que haya cambiado.

2. **`registro_reproduccion_page.dart` no tenía el bug de date picker.** El audit lo agrupó junto a `registro_sanitario_page.dart` y `bulk_health_registro_page.dart` como "mismo bug copy-paste, mismo campo `_nextDate`". Pero `registro_reproduccion_page.dart` usa campos llamados `_serviceDate`/`_expectedCalvingDate`, y **ambos** ya tenían la guardia `if (picked != null)` antes de que tocáramos nada. Solo los otros dos archivos necesitaban el fix — y son los únicos que el commit de Fase 1.4 tocó.

3. **`MilkingSession`/`MilkingEntry.toJson`/`fromJson` NO están muertos.** El audit los marcó "Verificar — sin llamadas fuera de su propia clase". Es falso: `core/services/backup_service.dart` los usa activamente para el export/import de backups (líneas ~91-94 para `toJson()`, ~206-213 para `fromJson()`). Esto se detectó *antes* de borrar nada, durante la verificación de Fase 5 — por eso siguen en el código. Si hubiera confiado en la tabla del audit a ciegas, se habría roto el sistema de backup/restore de sesiones de ordeño.

---

## 2. Hallazgos críticos — qué sigue pendiente

De los 16 hallazgos críticos reales, **6 siguen exactamente como los describió el audit**:

- **Clave maestra hardcodeada** (`default_key_provider_service.dart`) — sigue con el placeholder `'dev-token-master-key-change-me'` como default de `--dart-define`.
- **`AuthService.signIn()` stub** (`auth_service.dart`) — sigue autenticando a cualquiera con credenciales no vacías.
- **Agenda "recurrente" que nunca se repite** — `recurrenceRule` se guarda pero nada la expande.
- **Update optimista de agenda sin rollback** — `agenda_task_detail_page.dart` puede mostrar "completado" aunque el guardado real falle.
- **`UpsertUbicacion` huérfano** — la validación de jerarquía existe pero el formulario real la esquiva llamando al repositorio directo. Es una decisión de arquitectura, no un fix de una línea.
- Estos dos primeros (seguridad) eran justamente la **Fase 4** que quedó planeada pero nunca se ejecutó en esta sesión.

Los otros 10 (pérdida de datos de cultivos, backup de animales, ciclo en árbol de ubicaciones, `copyWith` roto, hang de renombrar lote, error oculto al cambiar ubicación, lotes ficticios sembrados, rentabilidad mal calculada, borrador de ordeño viejo, CI inexistente) **están arreglados y verificados**.

El bug de date picker (crítico #12) quedó **arreglado en 2 de los 2 archivos que realmente lo tenían** (ver corrección #2 arriba — el tercero nunca lo tuvo).

---

## 3. Archivos a eliminar — lo que quedó pendiente

Casi todo lo marcado **"Seguro"** se borró en Fase 5. Quedó pendiente:

- **`detail_helpers.dart` → `uniqueBatches()`, `fmtDate()`** — el audit las marcó "Seguro" para eliminar pero Fase 5 solo borró archivos completos, no funciones sueltas dentro de un archivo que sí se usa. Siguen ahí.
- **3 scripts `.ps1` en la raíz** (`find_broken_part_of.ps1`, `find_missing_class.ps1`, `scan_undocumented.ps1`) — marcados "Verificar", no se tocaron.
- **`REFACTORING_SUMMARY.md` vs `REFACTORING_COMPLETE.md`** — ambos siguen presentes, sin consolidar.
- **`batch_migration_service.dart`** — el audit decía "verificar" porque sospechaba que su condición nunca es verdadera. **Confirmé que el bug es real**: `AnimalEntity.batchId` está declarado como `final String? batchId = null;` (nunca asignable desde el constructor), así que `animal.batchId != null` nunca puede ser `true`. El servicio sigue haciendo un fetch del hato completo en cada arranque de la app sin que sirva para nada. No lo borré porque requiere decidir si el servicio se elimina entero o si la migración real (que aparentemente nunca se completó) se debe implementar de verdad — te lo dejo para decidir.

Y dos casos que el audit marcó "Seguro"/"Verificar" para borrar pero que **se mantuvieron a propósito**, sin relación con errores del audit:

- `domain/domain.dart` — el barrel que re-exporta las entidades, incluyendo `Care*`. Se dejó junto con `Care*` por tu instrucción explícita ("es una feature planeada, no tocar"). Cero riesgo de dejarlo: nadie lo importa, no genera warnings.
- Subsistema `Care*` completo y `land_tenure.dart`/`tenure_type.dart` — mismo motivo, instrucción tuya explícita.

---

## 4. Archivos a modificar — lo que quedó pendiente

De los 16, **10 están arreglados** (Fases 1-3). Los 6 pendientes:

1. `default_key_provider_service.dart` — fuente de clave desde Keystore/Keychain + guardia de release (Fase 4).
2. `auth_service.dart` — reemplazar el stub por integración real o bloquear en release (Fase 4).
3. `prefs_secure_store_service.dart` — el nombre dice "secure" pero no cifra; renombrar o migrar a `flutter_secure_storage`.
4. `agenda_form_sheet.dart` — ocultar el dropdown de recurrencia o implementarla de verdad.
5. `exportar_page.dart` — quitar el `tristate: true` del checkbox "Seleccionar todo" (nunca llega a `null`), o calcular el tercer estado real.
6. El bug de date picker — técnicamente "resuelto" en los 2 archivos que sí lo tenían (ver sección 2).

---

## 5. Qué no se tocó del plan de refactor ni del plan de tests

El plan de refactor (21 items) y el plan de tests nuevos (28 archivos propuestos) del audit original **casi no se ejecutaron** — eso corresponde a las Fases 6 y 7 que quedaron para después. El detalle completo de qué sigue pendiente ahí está en `auditoria-estado.json` bajo `refactor_plan_pendiente` y `tests_pendientes_alto_roi`, para no repetir la tabla completa acá.

---

## 6. Próximos pasos sugeridos

En orden de impacto:

1. **Fase 4 (seguridad)** — es la única categoría "crítico/seguridad" que sigue 100% sin tocar. La clave maestra hardcodeada y el auth stub son los dos hallazgos más serios del audit completo.
2. **Limpieza suelta de Fase 5** — `detail_helpers.dart` (2 funciones), scripts `.ps1`, docs de refactor duplicadas, `batch_migration_service.dart` (decidir arreglar o borrar). Todo bajo esfuerzo, cero riesgo.
3. **`exportar_page.dart` tristate** y **`registro_reproduccion_page.dart`** — nada que hacer en el segundo (falsa alarma), el primero es un fix de una línea.
4. Recurrencia de agenda y update optimista sin rollback — mayor esfuerzo, conviene planearlos como su propia mini-fase.
5. Fases 6-7 del plan original (tests de alto ROI + refactors arquitectónicos) siguen enteras.

Decime cuál seguimos y lo armo como una fase nueva, igual que las anteriores.
