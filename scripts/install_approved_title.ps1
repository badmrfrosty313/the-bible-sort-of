# Use after downloading the approved full-resolution image from ChatGPT.
# Finds the newest original PNG in Downloads and installs it into the project.
$ErrorActionPreference = "Stop"
$downloads = Join-Path $HOME "Downloads"
$matches = Get-ChildItem -LiteralPath $downloads -File -Filter "the_bible_sort_of_island_menu*.png" |
    Sort-Object LastWriteTime -Descending
if (-not $matches) {
    throw "Download 'the_bible_sort_of_island_menu.png' first, then rerun this script."
}
$source = $matches[0].FullName
Add-Type -AssemblyName System.Drawing
$image = [System.Drawing.Image]::FromFile($source)
try {
    if ($image.Width -lt 1200 -or $image.Height -lt 900) {
        throw "The downloaded file is too small ($($image.Width)x$($image.Height)). Use the original 1448x1086 image."
    }
} finally {
    $image.Dispose()
}
$repo = Split-Path -Parent $PSScriptRoot
$target = Join-Path $repo "art\title\approved_title_original.png"
Copy-Item -LiteralPath $source -Destination $target -Force
Write-Host "Full-resolution approved art installed: $target" -ForegroundColor Green
Write-Host "Godot will load it automatically. Restart the game with F5."
