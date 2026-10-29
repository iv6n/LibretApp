# Identidad visual de LibretApp

La marca **Libreta de campo** usa una libreta frontal con una `L` recortada en su tapa. El símbolo conserva la idea de una libreta de trabajo y el nombre de la app, sin limitar la identidad a una sola especie ni a un solo módulo.

La paleta comparte los tokens de interfaz: verde bosque `#2F5D50`, verde profundo `#18362D`, crema `#F6F1E8` y separador de cuero `#7B4B2A`. El logo horizontal tiene su lettering en trazados, así que se reproduce igual sin instalar una tipografía. La referencia vigente está en `design/branding/approved-logo-reference.png`: lettering grueso y redondeado, tapa con L y separador café separado de la libreta. Sus contornos están trazados en `assets/branding/artwork.json`; el generador produce los maestros SVG, variantes y capas Android desde esa única geometría. La lámina anterior de cuero se conserva en `design/branding/identity-board.png` como referencia histórica.

## Regenerar

Se necesita Node.js 20.9 o posterior, npm y Sharp 0.35.5. Desde PowerShell, en la carpeta `libretapp`:

```powershell
Push-Location tool/branding
npm install
npm run generate
npm run check
Pop-Location
```

Las versiones de Node y Sharp están fijadas en `tool/branding/package.json`. El generador lee los contornos vectoriales de `artwork.json`, sincroniza los SVG y las capas nativas de Android y crea los PNG/ICO/ICNS. Puede ejecutarse de nuevo y reemplaza solamente los archivos administrados por la identidad de LibretApp. `npm run check` también comprueba que los SVG y las capas Android coincidan con esos contornos. No se necesita la imagen de referencia para regenerar, ni una tipografía adicional.

## Recursos

| Recurso | Ubicación |
| --- | --- |
| Maestros SVG y símbolo monocromo | `assets/branding/` |
| Contornos compartidos de símbolo y lettering | `assets/branding/artwork.json` |
| Vistas del logo claro y oscuro a 1280×336 | `design/branding/exports/logo-light.png`, `logo-dark.png` |
| Símbolo y logo por tema para Flutter | `assets/branding/symbol-*.svg`, `assets/branding/logo-*.svg` |
| Iconos normal, oscuro y seguro para máscaras | `assets/branding/app-icon*.svg` |
| Capa monocroma y fuentes del arranque Android | `assets/branding/android/` |
| App icon y Touch icon de iOS/iPadOS | `ios/Runner/Assets.xcassets/AppIcon.appiconset/` |
| Splash del iPhone/iPad | `ios/Runner/Assets.xcassets/LaunchImage.imageset/` |
| Launcher y ficha de Google Play | `android/app/src/main/res/mipmap-*`, `design/branding/exports/android/` |
| Icono del Explorador, acceso y tarea Windows | `windows/runner/resources/app_icon.ico` |
| Favicon, accesos PWA y arranque web | `web/favicon.*`, `web/icons/`, `web/apple-touch-icon.png` |
| Icono nativo para futura app macOS | `design/branding/exports/macos/LibretApp.icns`, `LibretApp-1024.png`, PNG por capas y fuentes SVG bajo `assets/branding/macOS/` |
| Iconos Hicolor normales, oscuros y monocromos para futura app Linux | `design/branding/exports/linux/hicolor/` y SVG bajo `design/branding/exports/linux/` |

El favicon omite el separador de cuero para mantenerse legible a 16 px. Los iconos `maskable` mantienen todo el símbolo dentro del círculo seguro central. iOS recibe PNG opacos sin redondeado precocido: iOS aplica su máscara de sistema. Windows contiene 16, 24, 32, 48 y 256 px en un único ICO; la variante PWA normal y maskable mantiene fondos separados. El ICNS y los recursos Linux son exportaciones listas para empaquetar cuando se creen esos proyectos; no cambian los targets Flutter actuales. La lámina aprobada se conserva junto con sus acentos de cuero como referencia visual del concepto.
