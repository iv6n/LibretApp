$base = "C:\Users\Master\Desktop\Code\LibretApp\libretapp\lib"
$results = @()
Get-ChildItem $base -Recurse -Filter "*.dart" | ForEach-Object {
  $lines = [System.IO.File]::ReadAllLines($_.FullName, [System.Text.Encoding]::UTF8)
  $hasLib = $lines | Where-Object { $_ -match '^library;' }
  $hasPart = $lines | Where-Object { $_ -match '^part of ' }
  if ($hasLib -and $hasPart) {
    $results += $_.FullName.Replace("$base\", "")
  }
}
$results | Sort-Object | Out-File "C:\Users\Master\Desktop\Code\LibretApp\broken_part_of.txt" -Encoding utf8
Write-Host "$($results.Count) broken part-of files found."
