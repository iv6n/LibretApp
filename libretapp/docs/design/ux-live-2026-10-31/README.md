# Inspección visual en móvil — 31 de octubre de 2026

Capturas del dispositivo CPH2123, resolución 1080 × 2400, tomadas antes de los ajustes de código:

- `01-actual.png`: Inicio, navegación inferior y accesos rápidos.
- `02-directorio.png`: Directorio > Animales, búsqueda, filtros y tarjeta de Mika.
- `03-animal.png`: ficha de Mika y su fotografía.

## Hallazgos

1. La franja detrás de la navegación inferior dejaba traslucir contenido. Se reforzó el degradado hasta llegar a un fondo opaco antes de la barra.
2. En Animales aparecían dos filas de filtros aun cuando solo hay un animal. La segunda fila, Etapas, ahora se puede desplegar cuando hace falta. Las categorías redundantes se omiten cuando todos los animales pertenecen al mismo grupo.
3. La búsqueda de Animales está abierta aun sin consulta. Propuesta: iniciar con un botón compacto de búsqueda y desplegar el campo al tocarlo o al llegar con una búsqueda activa.
4. La barra de secciones ocupa espacio de forma permanente. Propuesta: ocultarla al desplazarse hacia abajo y recuperarla al subir, manteniendo un control visible para cambiar de sección.
5. La fotografía usa un encuadre fijo en tarjeta y perfil. Propuesta: permitir desplazar y ampliar la imagen en el editor, con vista previa cuadrada y vertical antes de guardar el recorte.

Las capturas muestran la versión que estaba instalada en el móvil; no representan los ajustes posteriores del código.
