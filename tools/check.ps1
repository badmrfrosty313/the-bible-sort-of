param([string]$Godot = "godot", [switch]$Clean)
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")
if ($Clean) { Remove-Item -Recurse -Force .godot -ErrorAction SilentlyContinue }
function Invoke-Check([string[]]$Arguments) {
    $output = & $Godot @Arguments 2>&1
    $code = $LASTEXITCODE
    $output | Write-Output
    if ($code -ne 0 -or ($output -match 'SCRIPT ERROR|Parse Error|ERROR:|FAIL:')) {
        throw "Godot validation failed"
    }
}
Invoke-Check @('--headless', '--editor', '--path', '.', '--quit')
Invoke-Check @('--headless', '--path', '.', '--script', 'ci/test_resources.gd')
Invoke-Check @('--headless', '--path', '.', '--script', 'ci/test_content.gd')
$previousAppData = $env:APPDATA
$testData = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $testData | Out-Null
try {
    $env:APPDATA = $testData
    Invoke-Check @('--headless', '--path', '.', '--script', 'ci/test_saves.gd')
    Invoke-Check @('--headless', '--path', '.', '--script', 'ci/test_foundation.gd')
    Invoke-Check @('--headless', '--path', '.', '--script', 'ci/test_foundation.gd', '--', '--resume')
    Invoke-Check @('--headless', '--path', '.', '--script', 'ci/test_foundation.gd', '--', '--quit')
} finally {
    $env:APPDATA = $previousAppData
    Remove-Item -Recurse -Force $testData
}
Write-Output 'Imported art and integration verified. Run F5 to inspect the presentation.'
