# Candidato offline para prueba interna

Estado: pendiente de aceptación. No se ha publicado en Play. El OPPO se
actualizó en sitio con un APK debug del código 20 al 21, sin borrar datos.

La revisión de código del 4 de noviembre terminó con 1,540 pruebas aprobadas,
una omitida y `flutter analyze` sin errores ni advertencias. El AAB descrito
abajo se reconstruyó con esas correcciones.

## Datos confirmados para el piloto offline

No hace falta inventar una sociedad para una cuenta personal: Google distingue
el **nombre público del desarrollador** del **nombre legal** que usa para
verificar la identidad. El titular confirmó su cuenta personal, el nombre
público **Iv6n** y el correo de desarrollador y soporte mostrado en Console.
No copiar nombre legal ni dirección a los metadatos de compilación.
[Requisitos de contacto de Play](https://support.google.com/googleplay/android-developer/answer/10840893).

La [política offline](https://libretapp-mexico.delcarmenmariscos.chatgpt.site/privacidad/offline/)
se publicó el 4 de noviembre de 2026 en el sitio público de LibretApp. Se
comprobó que abre sin iniciar sesión. La política de la variante conectada
permanece separada. Google exige el enlace tanto en Console como dentro de la
app; el borrador histórico [privacidad.html](privacidad.html) no es la página
vigente. [Política de datos de usuario](https://support.google.com/googleplay/android-developer/answer/10144311).

Guardar los tres valores reales en el JSON privado de compilación fuera del
repositorio. La herramienta rechaza ejemplos y direcciones de prueba. No pegar
nombre legal, dirección ni credenciales en el código o en este documento.

## AAB firmado para revisión

Se generó el AAB offline `0.1.4+21` con la clave de subida local y los datos
públicos confirmados. Está fuera del repositorio, en
`%TEMP%/libret-offline-store-current/LibretApp-0.1.4+21-offline-store.aab`.
SHA-256: `b82719414d7bd8a00abf92da2613cee8de290b4fc80904b86052a4eaadecf7ce`.
La huella SHA-256 del certificado de subida local es
`7f1c12465e5b9985db26166476dcab48f12d35cafeca11660e467268250fdfa4`.
`jarsigner` validó la firma; la inspección del AAB aprobó paquete, código,
API 28/36, permisos, copia Android desactivada y alineación ELF de 16 KB.
El enlace de privacidad y el correo confirmados están integrados en el AAB.
El informe junto al archivo mantiene `readyForStore: false`: faltan la huella
de subida registrada en Console, puertas físicas y revisión final. No se subió
a Play. El APK debug de la misma revisión se instaló en el OPPO sin desinstalar;
Directorio conservó un animal tras forzar cierre y reabrir sin conexión. Su
certificado debug no es el certificado de instalación de Play.

La constancia posterior a la compilación verificó el hash exacto y rechazó la
aceptación por puertas pendientes: migraciones en teléfono, API 28, Android
actual, páginas de 16 KB, TalkBack, permisos rechazados, rendimiento con 1,000
animales y actualización desde la firma de Play. El OPPO es API 31. Se probó
reapertura sin conexión; Wi-Fi, datos móviles y espera de pantalla volvieron a
sus valores previos. No se restauró la copia personal.

1. Consultar en Play Console la pista activa, el mayor `versionCode` de
   `app.libret`, el certificado de firma de instalación de Play y el certificado
   de subida. Comparar la firma de instalación con la del APK del OPPO. Una
   firma distinta exige exportar y verificar un `.libretbackup`, ensayar su
   restauración fuera del teléfono y revisar la transición antes de desinstalar.
2. Guardar `LIBRET_RESPONSIBLE_NAME`, `LIBRET_SUPPORT_EMAIL` y
   `LIBRET_PRIVACY_URL` con los valores confirmados en un JSON fuera del
   proyecto. Un AAB de revisión puede generarse antes de cerrar las pruebas
   físicas.
3. Generar el AAB firmado con `--mode store --flavor offline --last-play-code N`
   y los archivos `--metadata` y `--out` fuera del proyecto. La
   compilación usa un código mayor que 20 y N. Revisar `candidate.json`,
   `bundle-inspection.json`, `signature-verification.log` y el hash del AAB.
   `candidate.json` permanece en `readyForStore: false`.
4. Registrar cada puerta de `GATES` de `tool/build_android_candidate.py` en
   evidencia JSON, ligada al hash del código que imprime `--validate-only`.
   Una prueba pendiente queda en `false`. Tras revisar el archivo exacto,
   ejecutar `tool/accept_android_candidate.py`
   con `--candidate`, `--metadata`, `--evidence`, `--last-play-code` y
   `--accepted-sha256` del AAB generado. La constancia comprueba de nuevo hash,
   código, evidencia, metadatos, firma y alineación nativa. Su `readyForStore`
   corresponde solo a ese AAB. Subirlo a prueba interna requiere una revisión
   separada con el titular.

El recorrido en teléfono debe terminar con datos, fotos, copia y reapertura sin
conexión verificados. Las pruebas con cuatro usuarios de rancho y uno de uso
mixto o mascotas siguen abiertas hasta que haya participantes.
