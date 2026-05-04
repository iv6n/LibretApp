$base = 'C:\Users\Master\Desktop\Code\LibretApp\libretapp'
$files = Get-ChildItem $base -Recurse -Filter '*.dart' | Where-Object { $_.Name -notmatch '\.g\.dart$' -and $_.FullName -notmatch '\\build\\' }

foreach ($file in $files) {
    $lines = [System.IO.File]::ReadAllLines($file.FullName, [System.Text.Encoding]::UTF8)
    foreach ($line in $lines) {
        if ($line -match '^library;|^part |^import |^export |^//|^\s*$') { continue }
        # First non-trivial line - check if it's indented like class body
        if ($line -match '^\s+\S') {
            $rel = $file.FullName.Replace($base + '\', '')
            Write-Output $rel
        }
        break
    }
}
