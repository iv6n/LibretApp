param(
    [string]$Device = '4TDEHA8P8HZTK7BE',
    [string]$Flutter = 'C:\src\flutter\bin\flutter.bat',
    [int]$BuildNumber = 41
)

$ErrorActionPreference = 'Stop'
$project = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$apk = Join-Path $project 'build\app\outputs\flutter-apk\app-offline-debug.apk'

if (-not (Test-Path -LiteralPath $Flutter)) {
    throw "Flutter no existe en $Flutter"
}

Push-Location $project
try {
    $deviceState = (& adb -s $Device get-state 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $deviceState -ne 'device') {
        throw "El móvil $Device no está disponible en ADB: $deviceState"
    }

    & $Flutter --no-version-check test --no-pub test/features/inicio/inicio_responsive_layout_test.dart
    if ($LASTEXITCODE -ne 0) { throw 'Las pruebas de Inicio fallaron. No se instalará el APK.' }

    $started = Get-Date
    & $Flutter --no-version-check build apk --debug --flavor offline --no-pub `
        --build-number=$BuildNumber --dart-define=LIBRETAPP_OFFLINE_PILOT=true
    if ($LASTEXITCODE -ne 0) { throw 'Falló la compilación. No se instalará un APK anterior.' }

    $built = Get-Item -LiteralPath $apk -ErrorAction Stop
    if ($built.LastWriteTime -lt $started) {
        throw 'El APK disponible es anterior a esta compilación. No se instalará.'
    }

    Write-Host "APK nuevo: $apk"
    Write-Host "SHA-256: $((Get-FileHash -LiteralPath $apk -Algorithm SHA256).Hash)"
    & adb -s $Device install -r $apk
    if ($LASTEXITCODE -ne 0) { throw 'ADB no pudo instalar la actualización.' }

    $installed = (& adb -s $Device shell dumpsys package app.libret | Select-String 'versionCode=' | Select-Object -First 1).ToString()
    if ($installed -notmatch "versionCode=$BuildNumber\b") {
        throw "La versión instalada no es $BuildNumber`: $installed"
    }
    Write-Host "Actualización instalada en $Device; datos de la app conservados. $installed"
}
finally {
    Pop-Location
}
