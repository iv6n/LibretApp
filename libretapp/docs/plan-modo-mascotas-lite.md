# Propuesta: modo Mascotas de LibretApp

Estado: propuesta de producto anterior a la implementación. La primera entrega
Android de Completa/Lite está descrita en [experiencia-completa-lite.md](experiencia-completa-lite.md).

## Decisión de producto

Ofrecer **una sola aplicación con dos experiencias de uso**, `Completa` y
`Mascotas`. El usuario elige en **Perfil → Ajustes → Experiencia de uso** y puede
cambiar cuando quiera. La elección modifica navegación, formularios y paneles;
no duplica la base de datos ni convierte registros. El nombre visible recomendado
es «Modo Mascotas»; «Lite» puede quedar como nombre interno.

Al registrar el primer perro o gato, si el espacio no tiene ganado, mostrar una
invitación discreta para probar el modo. No activarlo automáticamente y no
imponer un límite artificial de animales. Para un espacio mixto, el modo muestra
las mascotas en sus vistas simples; los registros ganaderos siguen disponibles
al volver a la experiencia completa. El modo vacío también debe permitir dar de
alta la primera mascota.

## Inventario real de reutilización

| Pieza actual | Reutilización | Ajuste necesario |
| --- | --- | --- |
| `AnimalEntity`, fotos y registro rápido | Identidad, nombre, raza, edad, sexo, microchip/placa, foto y notas | Formulario corto centrado en el nombre; ocultar producción, lote y genealogía |
| Salud y calendario de cuidados | Historial de vacunas, desparasitación, tratamientos, chequeos y próxima fecha | Presentación para mascotas; no aplicar por defecto reglas ganaderas o recomendaciones clínicas |
| Agenda | Citas, tareas, estados, enlace a animal, calendario, repetición semanal/mensual | Tipos de mascota, formulario breve, avisos locales y modelo de dosis múltiples |
| Inicio configurable | Próximas fechas, pendientes y acciones rápidas | Distribución inicial propia del modo; ocultar indicadores de rancho |
| `CultivationEntity` | Planta individual, grupo/huerto, riegos, tareas y cosecha | Acceso sencillo, terminología doméstica y activación opcional |
| Respaldo local y exportación | Conservación de fichas e historiales | Incluir cualquier entidad nueva y probar restauración |

Otros usos convenientes, por prioridad:

| Prioridad | Función | Propuesta |
| --- | --- | --- |
| Alta | Fotos, notas y peso | Mostrar álbum e historial de peso en la ficha sin exigir datos de producción. |
| Alta | Historial sanitario | Vista cronológica y ficha de vacunas/consultas con próxima fecha vinculada a Agenda. |
| Media | Gastos por mascota | Reutilizar registros de costos para consultas, alimento y medicamentos con resumen sencillo; dejar las finanzas del rancho fuera de la navegación simple. |
| Media | Listas de cuidados | Usar checklist de Agenda para preparación de visita, baño o viaje, sin generar reglas veterinarias automáticas. |
| Posterior | Documentos y contacto veterinario | Adjuntos y datos de la clínica requieren una experiencia propia y revisión de respaldo; no bloquear el primer lanzamiento por esto. |

Brechas verificadas: existe `Species.canine`, pero **no `Species.feline`**;
los tipos actuales de agenda se centran en operaciones ganaderas; `remindAt`
está en el modelo, pero no hay un servicio de notificaciones locales; la
repetición actual es semanal o mensual y genera la siguiente tarea al completar
la anterior. No sirve por sí sola para dosis diarias con horas y duración.

## Experiencia propuesta

1. **Inicio:** saludo, próximas citas y dosis, vencidos, tarjetas de cada
   mascota y botones «Añadir mascota» y «Programar». Si se activaron plantas,
   añadir «Mis plantas» y el próximo riego.
2. **Mascotas:** lista compacta con foto, nombre, especie y próximo pendiente.
   En la ficha: resumen, historial de salud y agenda de esa mascota. Acciones
   principales: registrar atención, programar cita, crear tratamiento y añadir
   nota/foto. Campos técnicos quedan en «Más detalles».
3. **Agenda:** vistas lista/calendario, «Hoy», «Próximos» y «Atrasados»;
   filtros por mascota y, si corresponde, plantas. Al terminar una tarea, pedir
   confirmación explícita y guardar fecha real; ofrecer posponer u omitir una
   dosis con motivo opcional.
4. **Ajustes:** selector `Completa / Mascotas` y opción independiente
   `Mostrar plantas y huerto`. Mantener respaldos, apariencia y ayuda visibles
   en ambos modos. Los accesos de rancho aparecen solo en Completa.

La navegación simple puede usar Inicio, Mascotas, Agenda y Perfil, con Plantas
como quinto destino cuando el usuario lo active. Mantener las rutas existentes
en el router y adaptar los destinos visibles, etiquetas y botón central según
el modo; al cambiar, llevar al usuario a Inicio para evitar una pantalla oculta.

## Datos y reglas

- Añadir `Species.feline` como valor estable, con etiqueta, icono, política de
  registro y categoría apta para compañía. Revisar los `switch`, filtros,
  serialización, importación/exportación, respaldos y migraciones. La especie
  Isar se guarda por nombre, pero hay que probar la lectura de datos previos.
- Guardar la experiencia seleccionada por **espacio de trabajo** mediante una
  clave nueva de `SharedPrefsService` y hacerla observable para reconstruir
  Inicio, navegación y Ajustes inmediatamente. Al ser preferencia de interfaz,
  no se incluye en el respaldo de datos; se vuelve a elegir al restaurar en
  otro dispositivo. Documentar esto en la interfaz.
- Reutilizar `AgendaEntry` para citas y pendientes individuales, enlazándolos
  por UUID de mascota o cultivo. Tipos sugeridos: cita veterinaria, vacuna,
  desparasitación, medicamento, higiene, cuidado general y recordatorio libre.
  Las fechas médicas las introduce el usuario; la app no calcula dosis ni
  calendarios clínicos.
- Para un medicamento con varias tomas, crear un **plan de tratamiento**
  separado (mascota, nombre, indicación escrita por el usuario, horarios,
  inicio, fin y estado). Cada toma tiene identidad y estado propios; la agenda
  las muestra como ocurrencias. Confirmar una toma crea el registro real;
  programarla no cuenta como medicamento administrado. Editar o cancelar el
  plan actualiza los avisos futuros sin borrar el historial.
- Añadir notificaciones **locales** para citas, tomas y tareas elegidas. Pedir
  permiso al activar avisos; si se deniega, mantener las fechas visibles en
  Inicio y Agenda. Reprogramar al editar, completar, restaurar o cambiar de
  espacio. Evitar duplicados y respetar la hora local del dispositivo.
- El módulo de plantas se activa aparte del modo Mascotas. `CultivationScale`
  ya contempla planta individual y grupo/huerto sin ubicación obligatoria;
  reutilizar riego y tareas antes de añadir nuevos modelos.

## Entrega por fases

| Fase | Resultado comprobable |
| --- | --- |
| 1. Fundamentos | Felino funciona en registro, fichas, filtros y respaldos. Ajustes cambia entre modos sin perder datos y recuerda la elección por espacio. |
| 2. Mascotas y agenda simple | Flujo corto para alta, ficha y citas/tareas; Inicio y navegación propios. Los pendientes se crean, editan, completan y filtran por mascota sin mostrar módulos ganaderos. |
| 3. Medicamentos y avisos | Plan con tomas diarias o varios horarios, confirmación por toma, omisión/posposición y notificaciones locales; pruebas de edición, reinicio y permiso denegado. |
| 4. Plantas opcionales | Acceso «Mis plantas», alta de planta/huerto, próximo riego y tareas en Agenda. No exige registrar terreno o ubicación. |

## Criterios de aceptación

- Un usuario nuevo registra un gato o perro por nombre en pocos pasos y puede
  programar una cita desde su ficha.
- Una cita o toma pendiente aparece en Inicio y Agenda; al completarla no
  sigue pendiente. Una toma programada nunca figura como administrada antes de
  confirmarla.
- Cambiar `Mascotas → Completa → Mascotas` conserva fichas, fechas, historiales
  y filtros; los datos de ganado no se eliminan ni se transforman.
- Un espacio mixto ve solo perros/gatos en la lista simple y conserva sus otros
  animales en Completa. El modo elegido no cambia otro espacio de trabajo.
- Sin permiso de notificaciones o sin conexión, agenda y registros siguen
  utilizables; tras reiniciar se conservan tareas y avisos pendientes.
- Activar plantas permite seguir una planta individual y un huerto sin crear
  ubicación; desactivarlas solo oculta sus accesos, no sus datos.
- Pruebas de actualización y restauración cubren `Species.feline`, los planes
  de tratamiento y los registros antiguos.

## Alcance inicial

Prioridad: mascotas, fechas y recordatorios confiables. Peso, fotos, notas,
respaldo y plantas tienen modelos reutilizables. Finanzas domésticas, documentos
veterinarios, compartir con familiares, inventario y otras especies de compañía
pueden evaluarse después de observar el uso del primer lanzamiento.
