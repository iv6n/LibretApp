# Iconos 2.5D de LibretApp

La familia 2.5D usa siluetas redondeadas, volumen bajo, sombras de contacto
locales y reflejos integrados. Los maestros generados están en
`assets/icons_25d_source/`; las copias WEBP de 256×256 que consume la aplicación
están en `assets/images/`.

La familia cubre 117 iconos: 64 de Cultivos, Salud, Inventario y Finanzas,
Registro, Estados y Tareas, más 53 de Ubicaciones. Los animales actuales no se
modificaron.

## Convenciones

- Un maestro PNG y un WEBP por concepto, con nombre `familia_concepto`.
- Composición centrada, silueta contenida en 202×202 px y esquinas transparentes.
- Relieve corto por pieza, sombra de contacto local y reflejos contenidos en la
  silueta; sin texto incrustado ni marcas de agua.
- El WEBP final se rasteriza a 256×256 con alfa real.

Para regenerar las copias de producción desde los maestros:

```text
python tool/export_generated_25d_icons.py --scope all
```

Para exportar solo Ubicaciones se usa `--scope locations`; así se mantienen
intactos los 64 iconos ya aprobados.

Los SVG de `assets/icons_2d/` pertenecen a la propuesta vectorial anterior y no
son la fuente de los WEBP actuales.

Los iconos genéricos de Registro y Agenda (`record_*` y los estados
`status_verified`, `status_reprogrammed`, `status_draft`, `status_blocked`)
completan los casos que antes dependían exclusivamente de Material Icons.
