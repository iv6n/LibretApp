#requires -Version 7.0
<#
.SYNOPSIS
Valida la configuración de Android y consulta los ajustes públicos de Auth.
No envía SMS, no crea usuarios ni modifica el proyecto remoto.
#>
[CmdletBinding()]
param(
    [string]$ConfigPath = (Join-Path $PSScriptRoot '../onboarding.dart-define.local.json'),
    [switch]$Offline
)

$ErrorActionPreference = 'Stop'
try {
    if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
        throw 'Falta onboarding.dart-define.local.json. Copia el ejemplo y completa la URL y la clave pública.'
    }
    try {
        $config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json -AsHashtable
    } catch {
        throw 'El archivo de configuración no contiene un objeto JSON válido.'
    }
    if ($config -isnot [System.Collections.IDictionary]) {
        throw 'La configuración debe ser un objeto JSON.'
    }
    # Este archivo se incorpora al APK: solo se permiten parámetros del cliente.
    $allowed = @(
        'LIBRETAPP_PUBLIC_RELEASE', 'LIBRETAPP_ENABLE_PHONE_AUTH',
        'LIBRETAPP_ENABLE_CLOUD_DATA', 'SUPABASE_URL', 'SUPABASE_ANON_KEY',
        'LIBRET_SUPPORT_EMAIL', 'LIBRET_PRIVACY_URL'
    )
    if (@($config.Keys | Where-Object { $_ -cnotin $allowed }).Count -gt 0) {
        throw 'El archivo contiene campos no permitidos. No agregues credenciales de Twilio, service_role ni tokens de administración.'
    }
    if ([string]$config.LIBRETAPP_PUBLIC_RELEASE -cne 'true' -or
        [string]$config.LIBRETAPP_ENABLE_PHONE_AUTH -cne 'true') {
        throw 'LIBRETAPP_PUBLIC_RELEASE y LIBRETAPP_ENABLE_PHONE_AUTH deben ser true.'
    }
    if ($config.Contains('LIBRETAPP_ENABLE_CLOUD_DATA') -and
        [string]$config.LIBRETAPP_ENABLE_CLOUD_DATA -cne 'false') {
        throw 'La configuración pública debe mantener LIBRETAPP_ENABLE_CLOUD_DATA en false.'
    }

    $projectUrl = [string]$config.SUPABASE_URL
    $publicKey = [string]$config.SUPABASE_ANON_KEY
    $uri = $null
    if (-not [Uri]::TryCreate($projectUrl, [UriKind]::Absolute, [ref]$uri) -or
        $uri.Scheme -ne 'https' -or $uri.Host -notmatch '^[a-z0-9-]+\.supabase\.co$' -or
        -not $uri.IsDefaultPort -or $uri.UserInfo -or $uri.Query -or $uri.Fragment -or
        $uri.AbsolutePath -ne '/') {
        throw 'SUPABASE_URL debe ser la URL HTTPS del proyecto alojado: https://PROJECT_REF.supabase.co.'
    }
    if ($publicKey -notmatch '^sb_publishable_[A-Za-z0-9_-]+$') {
        try {
            $parts = $publicKey.Split('.')
            if ($parts.Count -ne 3) { throw 'Formato inválido' }
            $payload = $parts[1].Replace('-', '+').Replace('_', '/')
            $payload = $payload.PadRight($payload.Length + (4 - $payload.Length % 4) % 4, '=')
            $claims = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload)) | ConvertFrom-Json
            if ($claims.role -cne 'anon') { throw 'No es anon' }
        } catch {
            throw 'SUPABASE_ANON_KEY debe ser la clave Publishable (sb_publishable_...) o la clave anon heredada. Nunca uses service_role, sb_secret_... ni un token personal.'
        }
    }
    Write-Host 'OK: configuración del cliente válida; autenticación habilitada y datos en nube desactivados.'
    foreach ($field in @('LIBRET_SUPPORT_EMAIL', 'LIBRET_PRIVACY_URL')) {
        if ([string]::IsNullOrWhiteSpace([string]$config[$field]) -or [string]$config[$field] -match '\[|\]') {
            Write-Warning "$field sigue pendiente antes de publicar."
        }
    }
    if ($Offline) {
        Write-Host 'Validación local terminada. No se consultó Supabase.'
        exit 0
    }
    try {
        $settings = Invoke-RestMethod -Method Get -Uri ($uri.GetLeftPart([UriPartial]::Authority) + '/auth/v1/settings') `
            -Headers @{ apikey = $publicKey } -TimeoutSec 20 -MaximumRedirection 0
    } catch {
        # No imprimir la respuesta ni la excepción: podrían contener datos de la solicitud.
        throw 'No se pudieron consultar los ajustes de Auth. Revisa conexión, estado del proyecto, URL y clave pública.'
    }
    if ($settings.external.phone -ne $true) {
        throw 'El proyecto responde, pero el proveedor Phone está deshabilitado. Actívalo y configura SMS en Supabase.'
    }
    if ($settings.disable_signup -ne $false) {
        throw 'No se confirmó el permiso para crear usuarios nuevos. Revisa Allow new users to sign up.'
    }
    if ($settings.phone_autoconfirm -ne $false) {
        throw 'No se confirmó la verificación obligatoria del teléfono. Desactiva la confirmación automática y exige el código SMS.'
    }
    Write-Host 'OK: Supabase responde, permite altas por teléfono y exige verificación.'
    Write-Host 'Pendiente: probar recepción y verificación de un SMS real en Android. Este diagnóstico no comprueba entrega ni credenciales del proveedor.'
    exit 0
} catch {
    Write-Host ('ERROR: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
