Get-ChildItem "C:\Users\Master\Desktop\Code\LibretApp\libretapp\lib" -Recurse -Filter "*.dart" |
  Where-Object { $_.Name -notmatch "\.g\.dart$" -and $_.Name -notmatch "app_localizations" } |
  ForEach-Object {
    $first = Get-Content $_.FullName -TotalCount 1
    if ($first -notmatch "^///") {
      $_.FullName.Replace("C:\Users\Master\Desktop\Code\LibretApp\libretapp\lib\","")
    }
  } | Sort-Object | Out-File "C:\Users\Master\Desktop\Code\LibretApp\undocumented.txt" -Encoding utf8
Write-Host "Done. $(Get-Content 'C:\Users\Master\Desktop\Code\LibretApp\undocumented.txt' | Measure-Object -Line | Select-Object -ExpandProperty Lines) files still need doc comments."
