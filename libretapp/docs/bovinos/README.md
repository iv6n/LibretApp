# Candidato bovinos 0.1.2+5

Identidad Android: `app.libret`. Variante: `offline`. Respaldo: esquema 10. Se conservan las pestañas Resumen, Cuidados, Registros, Genealogía e Historial y los cambios locales anteriores.

## Comportamiento entregado

- Registros y el perfil abren el mismo formulario de reproducción. Permite servicio, diagnóstico, corrección y parto sin servicio conocido; este último conserva la fecha de servicio vacía. Un ciclo conocido se actualiza por su identidad persistida.
- El parto se guarda antes de ofrecer crear o vincular una cría. Cancelar conserva el parto. El vínculo posterior valida especie, padres, nacimiento exacto, otros partos y ciclos de genealogía; guarda padres, fecha exacta y relación en una transacción.
- El destete tiene fecha, peso opcional, método, responsable y notas. Su pesaje tiene UUID estable. Crear, corregir y eliminar destete y pesaje ocurren juntos en Isar. También se sincroniza la corrección o eliminación del pesaje asociado desde el historial de pesos.
- Sanidad permite lote del medicamento, retiro y próxima aplicación desde ambos accesos. Enfermedad, muerte y chequeo admiten producto vacío; los eventos con medicamento requieren producto.
- El peso muestra fecha y método. La ganancia diaria usa báscula y días distintos; una estimación o dos lecturas del mismo día no aportan un intervalo válido. Un peso de registro sin fecha sigue identificado como estimado.
- Los perfiles incluyen nacimiento y precisión, padres conocidos, destete, último peso y ganancia; vacas muestran estado, último parto, fecha esperada estimada y crías; toros muestran servicios, hembras distintas y descendencia vinculada.
- Los indicadores se reconstruyen al guardar, corregir, eliminar y deshacer. Cambiar el toro recalcula el anterior y el nuevo. El ciclo más reciente gobierna el estado y la agenda. Eliminar el último pesaje elimina su proyección; si existía un peso de registro inicial, se conserva como estimación.
- Los animales vendidos o fallecidos conservan correcciones históricas. Los guardados fallidos conservan los campos y no confirman éxito. La condición corporal nueva comienza sin selección; la escala sigue siendo 1–5.
- Excel incorpora Destetes, clase de reproducción y precisión del nacimiento. Los respaldos conservan UUID, genealogía y medios; versiones previas importan precisión desconocida y ciclos de servicio.

## Evidencia

Los resultados finales y hashes se registran en `evidencia.json`. Los archivos ejecutables y capturas están en `artifacts/bovinos/` y `build/`, excluidos de Git. La evidencia del piloto anterior permanece en `docs/piloto/`; sus resultados de 0.1.1+4 no se atribuyen a este candidato.

Resultado: 1037 pruebas de la suite completa aprobadas. Después del último ajuste del resumen del perfil se aprobaron otras 66 pruebas de perfiles, ciclo bovino y destete, además de la prueba explícita de configuración offline. El análisis final tiene cero errores, cero advertencias y 188 avisos informativos.

En el emulador Android 36 de 16 KB, sin red predeterminada, se verificaron la actualización desde 0.1.1+4, el parto sin servicio, el destete con peso y la restauración en una instalación vacía. La segunda exportación conserva las identidades de todas las colecciones, los padres y fechas de nacimiento, los registros reproductivos, el destete, los pesajes y los bytes de la fotografía. Se utilizaron únicamente 40 animales DEMO; el ciclo manual completo desde ambos accesos sigue pendiente en un teléfono físico.

Archivos de entrega: `artifacts/bovinos/libretapp-offline-0.1.2+5.apk` para instalación y `artifacts/bovinos/libretapp-offline-0.1.2+5.aab` para Play Console. Ambos están firmados con la configuración existente; pasaron la verificación de firma, manifiesto y compatibilidad de 16 KB. Los hashes están en `artifacts/bovinos/SHA256SUMS.txt` y en [evidencia.json](evidencia.json).

Pruebas específicas: `bovine_lifecycle_test.dart`, `weaning_form_flow_test.dart`, `reproduction_cycle_flow_test.dart`, `registro_reproduccion_flow_test.dart`, respaldo/restauración, exportaciones y formularios a 320 dp con texto doble y teclado. Las pruebas de ciclo usan Isar real; las de fallos de escritura de interfaz usan repositorios controlados. La suite completa también cubre las otras especies.

```powershell
flutter analyze --no-fatal-infos
flutter test --reporter expanded
flutter test test/core/platform/offline_pilot_test.dart --dart-define=LIBRETAPP_OFFLINE_PILOT=true
flutter build appbundle --release --flavor offline
flutter build apk --release --flavor offline
```

## Aceptación de publicación

La matriz [publicacion.csv](publicacion.csv) distingue pruebas automatizadas, recorridos Android y requisitos externos. El candidato no acredita automáticamente aceptación final: requieren cierre el recorrido manual completo en teléfono, TalkBack, permisos rechazados y los datos de titular, soporte y privacidad. No se inventaron esos datos ni se subió el candidato a Play Console.

Para cuentas personales creadas después del 13 de noviembre de 2023, Google exige una prueba cerrada con al menos 12 personas inscritas continuamente durante 14 días antes de solicitar acceso a producción. La aplicabilidad depende de la cuenta real. [Requisitos oficiales de pruebas de Google Play](https://support.google.com/googleplay/android-developer/answer/14151465).

Referencia funcional: [registros de cría de Oklahoma State University](https://extension.okstate.edu/fact-sheets/print-publications/cr/cow-calf-production-record-software-cr-3279-a.pdf). La app conserva los datos del productor; las fechas esperadas y pesos estimados se identifican como estimaciones.
