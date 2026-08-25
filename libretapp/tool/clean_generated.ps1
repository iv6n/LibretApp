[CmdletBinding(SupportsShouldProcess = $true)]
param()

$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$projectRoot = $projectRoot.TrimEnd([IO.Path]::DirectorySeparatorChar)

# These directories contain only Flutter/Gradle/Windows generated output.
# Keep this allow-list intentionally narrow: do not remove source, assets,
# local databases, credentials, or user-created files.
$generatedPaths = @(
    'build',
    '.dart_tool',
    'android\.gradle',
    'windows\flutter\ephemeral'
)

foreach ($relativePath in $generatedPaths) {
    $target = [IO.Path]::GetFullPath((Join-Path $projectRoot $relativePath))
    $isInsideProject = $target.StartsWith($projectRoot + [IO.Path]::DirectorySeparatorChar,
        [StringComparison]::OrdinalIgnoreCase)

    if (-not $isInsideProject) {
        throw "Refusing to operate outside the Flutter project: $target"
    }

    if (-not (Test-Path -LiteralPath $target)) {
        Write-Host "Omitido (no existe): $relativePath"
        continue
    }

    $files = @(Get-ChildItem -LiteralPath $target -Recurse -Force -File -ErrorAction SilentlyContinue)
    $bytes = ($files | Measure-Object -Property Length -Sum).Sum
    $sizeMb = [Math]::Round(($bytes / 1MB), 1)

    if ($PSCmdlet.ShouldProcess($target, "Eliminar artefactos generados ($sizeMb MB)")) {
        Remove-Item -LiteralPath $target -Recurse -Force
        Write-Host "Eliminado: $relativePath ($sizeMb MB)"
    }
}
