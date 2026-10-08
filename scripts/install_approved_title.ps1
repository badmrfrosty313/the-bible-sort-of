# Use after downloading the approved full-resolution image from ChatGPT.
param([switch]$Publish)
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

if ($Publish) {
    $currentBranch = (& git -C $repo branch --show-current).Trim()
    if ($currentBranch -ne "visual-direction-reboot") {
        throw "Cannot publish while on '$currentBranch'. Switch to visual-direction-reboot first."
    }
    & git -C $repo add -- "art/title/approved_title_original.png"
    if ($LASTEXITCODE -ne 0) { throw "Git staging failed." }
    & git -C $repo commit -m "Add the full-resolution approved Bible Sort Of title artwork" -- "art/title/approved_title_original.png"
    if ($LASTEXITCODE -ne 0) { throw "Git commit failed. The PNG is still copied locally." }
    & git -C $repo push origin visual-direction-reboot
    if ($LASTEXITCODE -ne 0) { throw "GitHub push failed. The committed PNG is safe locally." }
    Write-Host "Full-resolution title artwork published to GitHub!" -ForegroundColor Green
}
