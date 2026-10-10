param([string]$GodotPath, [switch]$Editor)
$ErrorActionPreference = 'Stop'
if (-not $GodotPath) {
    $candidate = Get-Command godot -ErrorAction SilentlyContinue
    if ($candidate) { $GodotPath = $candidate.Source }
    else { $GodotPath = 'C:\Users\win10\Desktop\skill\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe' }
}
if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    throw 'Godot bulunamadı. ./launch.ps1 -GodotPath C:\Godot\Godot.exe kullanın.'
}
$projectPath = Join-Path $PSScriptRoot 'godot'
if ($Editor) { & $GodotPath --path $projectPath --editor }
else {
    & $GodotPath --headless --path $projectPath --editor --import --quit
    if ($LASTEXITCODE -ne 0) { throw 'Godot içe aktarımı başarısız; önce konsol hatalarını kontrol edin.' }
    & $GodotPath --path $projectPath
}
