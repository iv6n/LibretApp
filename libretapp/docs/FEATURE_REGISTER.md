# Registro breve de funciones nuevas

| Función | Ubicación | Estado | Pruebas | Dependencia externa |
|---|---|---|---|---|
| Contexto de finca, roles y migración idempotente | `core/tenancy` | implementada | prueba idempotente; falta prueba de dos fincas | Supabase RLS listo en migración |
| Isar móvil + registro Drift web | `core/persistence` | verificada localmente | análisis y build Web | runtime WASM incluido en `web/` |
| Cola, cursor y conflictos de sincronización | `core/sync` | verificada localmente | contrato 8/8; falta prueba multi-dispositivo | gateway Supabase requiere despliegue |
| Identificación tipada e importación previa | `directorio/animales` | verificada localmente | contrato de ceros/duplicados | verificación oficial no habilitada |
| Kardex y consumo de tratamientos/alimento | `ubicaciones/almacen` | verificada localmente | contrato de disponibilidad/idempotencia | hardware no requerido |
| Alimentación y engorda | `directorio/lotes` | verificada localmente | GDP/ICA/fecha objetivo en contrato | hardware opcional |
| Protocolos IATF y material genético | `directorio/animales/reproduccion` | implementada localmente | agenda integrada pendiente | MVZ y datos reales |
| GPS/pastoreo y reportes México | `ubicaciones/pastoreo`, `reportes/mexico` | implementada localmente | GPS/PDF/Excel pendientes | SENASICA/API oficial pendiente |
| Contabilidad, fiscal y pagos | `finanzas` | adaptador sandbox | contratos pendientes | Facturapi/Stripe sandbox |
| Nómina, canal y maquila | `agenda/personal`, `registro/comercial`, `finanzas/maquila` | implementada localmente | flujos UI pendientes | proveedores/certificados |
| Asistente, proyecciones, suscripción y cacería | `inicio`, `perfil`, `ubicaciones` | adaptador/control local | evaluación pendiente | OpenAI/Stripe server-side |
