# Prompt set de producción

Herramienta: generación de imágenes integrada (`image_gen`). Cada maestro se
generó en una llamada independiente usando
`docs/design/icons-25d-v2/modelo-25d-v2.png` como referencia visual.

## Instrucción compartida

```text
Create exactly ONE production UI icon for LibretApp. The input image is the
approved style reference only; do not copy its board, labels, background, or
multi-icon composition. Match its premium crafted shallow bas-relief 2.5D
pictogram style: front-facing nearly orthographic, slim darker right and bottom
sidewalls, rounded beveled edges, inset and raised layers, subtle local
occlusion shadows where pieces meet, thin controlled edge highlights, tactile
matte satin surfaces. Use a centered square composition, strong broad
silhouette, 2 or 3 main pieces, generous genuinely transparent padding and
corners, readable at 20–24 px. Use soft upper-left lighting and only sage,
terracotta, ochre, cream and muted blue. No canvas, tile, frame, text, letters,
numbers, people, scenery, watermark or extra objects. Avoid flat vector, long
shadow, photorealistic 3D, clay toy, isometric diorama and tiny decoration.
```

## Conceptos añadidos a la instrucción compartida

| Archivo | Concepto |
| --- | --- |
| `crop_failed` | Brote marchito, suelo crema y X terracota. |
| `crop_field` | Tres surcos verdes y un brote ocre. |
| `crop_flowering` | Tallo verde con tres flores terracota y ocre. |
| `crop_fruiting` | Planta verde con tres frutos ocres. |
| `crop_germinating` | Brote de dos hojas sobre suelo crema. |
| `crop_harvested` | Saco crema, borde ocre y granos. |
| `crop_ready_to_harvest` | Surcos verdes y espiga madura ocre. |
| `crop_vegetative` | Planta verde sana con cuatro hojas. |
| `health_birth` | Corazón maternal crema, figura ocre y corazón terracota. |
| `health_body_condition` | Medidor corporal verde con dial crema y aguja ocre. |
| `health_diagnosis` | Portapapeles crema y lupa terracota. |
| `health_milk_production` | Lechera azul con gota crema. |
| `health_reproduction` | Corazón terracota con corazón crema. |
| `health_treatment` | Frasco ocre, cruz crema e indicador terracota. |
| `health_vaccine` | Frasco ocre y jeringa azul. |
| `health_weight` | Báscula verde con dial crema y aguja terracota. |
| `inventory_expense` | Recibo crema y flecha terracota descendente. |
| `inventory_feed` | Saco crema con hoja de grano ocre. |
| `inventory_income` | Moneda ocre y flecha verde ascendente. |
| `inventory_low_stock` | Caja crema y flecha terracota descendente. |
| `inventory_medicine` | Frasco ocre con cruz crema. |
| `inventory_profitability` | Tres barras y flecha terracota ascendente. |
| `inventory_sale` | Tienda crema con toldo terracota. |
| `inventory_tool` | Llave verde y engrane ocre. |
| `record_administration` | Carpeta crema y ocre con engrane verde. |
| `record_alert` | Triángulo terracota con exclamación crema. |
| `record_animal` | Cabeza bovina verde simplificada. |
| `record_care` | Escudo verde con corazón crema. |
| `record_cost` | Recibo crema y moneda ocre con signo menos. |
| `record_crop_health` | Brote verde y distintivo médico terracota. |
| `record_irrigation` | Llave de agua azul con tres gotas. |
| `record_location` | Pin terracota con centro crema. |
| `record_lot` | Tres marcadores de grupo superpuestos. |
| `record_movement` | Flechas verde y terracota opuestas. |
| `record_production` | Tres barras y flecha terracota ascendente. |
| `record_reminder` | Campana ocre con asa verde. |
| `record_reproduction` | Corazón terracota con corazón crema. |
| `record_rfid` | Etiqueta ocre con ondas verdes. |
| `record_sale` | Tienda crema con toldo terracota. |
| `record_service` | Llave verde y engrane ocre. |
| `record_task` | Portapapeles crema con verificaciones terracota. |
| `status_blocked` | Disco crema con pausa terracota. |
| `status_canceled` | Disco terracota con X crema. |
| `status_completed` | Disco verde con verificación crema. |
| `status_critical` | Triángulo terracota con exclamación crema. |
| `status_draft` | Documento crema y lápiz terracota. |
| `status_in_progress` | Anillo crema con arco verde y punto ocre. |
| `status_offline` | Nube azul con diagonal terracota. |
| `status_overdue` | Calendario crema con exclamación terracota. |
| `status_pending` | Reloj crema y verde con centro ocre. |
| `status_quarantine` | Cerca verde y distintivo médico terracota. |
| `status_reprogrammed` | Calendario crema con flecha circular verde. |
| `status_synced` | Dos flechas circulares verdes. |
| `status_verified` | Medalla verde con verificación crema. |
| `task_annual_vaccination` | Frasco, jeringa y pestaña de calendario. |
| `task_deworming` | Cápsula crema y ocre con gusano terracota. |
| `task_fertilization` | Brote verde y tres gránulos ocres. |
| `task_fumigation` | Aspersor ocre con boquilla azul. |
| `task_harvest` | Hoz terracota y espiga ocre. |
| `task_hoof_check` | Pezuña verde con verificación crema. |
| `task_milking` | Lechera azul con gota crema. |
| `task_reproductive_check` | Corazón terracota con verificación crema. |
| `task_tick_bath` | Gota azul, parásito terracota y verificación crema. |
| `task_vitamins` | Dos cápsulas crema, ocre y terracota. |

Las pequeñas variaciones de redacción entre familias especificaron el contexto
de Salud, Registro, Estado o Tarea, pero conservaron esta misma dirección visual.
