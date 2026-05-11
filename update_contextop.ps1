$path = "c:\Users\Master\Desktop\Code\LibretApp\Contextop.md"
$c = [System.IO.File]::ReadAllText($path)

# Fix infrastructure + bloc + application + view + widgets block
$old1 = "animal_remote_data_source.dart   # Remote sync data source (AnimalApiMock)"
$idx1 = $c.IndexOf($old1)
Write-Host "idx1=$idx1"

# Find "└── isar/" after animal_remote_data_source
$idx_isar = $c.IndexOf("└── isar/                            # Isar persistence models", $idx1)
$idx_after_widgets = $c.IndexOf("`n│   │   │   ├── lotes/", $idx_isar)
Write-Host "idx_isar=$idx_isar idx_after_widgets=$idx_after_widgets"

$blockToReplace = $c.Substring($idx1, $idx_after_widgets - $idx1)
Write-Host "Block to replace:"
Write-Host $blockToReplace
Write-Host "---"
