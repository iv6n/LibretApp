# Guía de generación de Ubicaciones 2.5D

Cada maestro se generó como una imagen individual usando
`docs/design/icons-25d-v2/modelo-25d-v2.png` como referencia visual, sin copiar
sus objetos. El encuadre pide un solo símbolo frontal, centrado, con dos o tres
piezas grandes, fondo transparente y lectura clara a 20–24 px.

## Tratamiento común

Relieve bajo 2.5D, perspectiva casi ortográfica, bordes redondeados, laterales
derechos e inferiores oscuros, luz superior izquierda, sombras de contacto
locales y superficies mate satinadas. Paleta: verde salvia y verde oscuro,
terracota, ocre, crema y azul apagado. Sin texto, personas, animales, marcos,
placas, paisaje adicional, cuadrícula, sombras largas ni detalles diminutos.

## Conceptos

| Familia | Archivo y símbolo |
| --- | --- |
| Categorías | `location_macro`: casa y límite; `location_livestock`: establo y cerco; `location_handling`: manga y flecha; `location_agricultural`: surcos y brote; `location_natural`: árbol y colina; `location_infrastructure`: edificio y engrane; `location_water`: gota y ondas. |
| Propiedades | `location_ranch`: casa y cerco; `location_farm`: granero y silo; `location_finca`: casa y frutal; `location_hacienda`: arco y portón; `location_plantation`: filas de cultivo; `location_ejido`: parcelas compartidas; `location_property`: casa y límite; `location_homestead`: casa principal, árbol y cerco. |
| Ganadería | `location_pasture`: pasto y cerca; `location_corral`: corral cerrado; `location_feedlot`: comedero; `location_barn`: fachada de granero; `location_stable`: puerta y herradura; `location_pen`: corraleta compacta. |
| Manejo | `location_chute`: manga estrecha y flecha; `location_quarantine_area`: cerca y cruz; `location_loading_area`: rampa; `location_weighing_area`: plataforma y báscula. |
| Agricultura | `location_field`: surcos; `location_plot`: parcela con cuatro límites; `location_milpa`: maíz; `location_orchard`: frutal; `location_greenhouse`: invernadero arqueado; `location_nursery`: charola de brotes; `location_garden`: flores. |
| Naturaleza | `location_monte`: colina y matorral; `location_forest`: tres árboles; `location_lagoon`: agua y juncos; `location_river`: cauce curvo; `location_wetland`: agua y carrizos; `location_protected_area`: árbol y escudo. |
| Infraestructura | `location_warehouse`: bodega y portón; `location_workshop`: llave y engrane; `location_office`: edificio y ventanas; `location_house`: casa simple; `location_road`: camino curvo; `location_water_tank`: tanque elevado y gota; `location_gate`: portón rural. |
| Agua | `location_well`: pozo circular; `location_dam`: muro y agua; `location_spring`: agua entre rocas; `location_pond`: estanque redondo; `location_aguada`: cuenco de tierra y agua; `location_trough`: bebedero; `location_canal`: canal recto; `location_reservoir`: reservorio y borde de contención. |

El exportador elimina fondos simulados, conserva alfa real y ajusta la silueta
dentro de un máximo de 202×202 px sin modificar los maestros del catálogo.
