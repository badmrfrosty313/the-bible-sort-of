param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Category,

    [Parameter(Mandatory=$true, Position=1)]
    [string]$Name,

    [switch]$NoPush
)

$ErrorActionPreference = "Stop"

$repoRoot = (Split-Path -Parent $PSScriptRoot).TrimEnd('\','/')
$dropDir = Join-Path $repoRoot "BibleSortOfDrop"

if (-not (Test-Path $dropDir)) {
    New-Item -ItemType Directory -Path $dropDir | Out-Null
    Write-Host "Created BibleSortOfDrop. Put a PNG in it and run this again."
    exit 0
}

$source = Get-ChildItem -Path $dropDir -File |
    Where-Object { $_.Extension -match '^\.(png|jpg|jpeg|webp)$' } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $source) {
    throw "No PNG/JPG/WEBP found in BibleSortOfDrop."
}

$safeCategory = ($Category.ToLower() -replace '[^a-z0-9_-]', '_')
$safeName = ($Name.ToLower() -replace '[^a-z0-9_-]', '_')
$extension = $source.Extension.ToLower()

switch ($safeCategory) {
    "background" { $destinationDir = Join-Path $repoRoot "art/episodes" }
    "sprite"     { $destinationDir = Join-Path $repoRoot "art/characters" }
    "effect"     { $destinationDir = Join-Path $repoRoot "art/effects" }
    default       { $destinationDir = Join-Path $repoRoot "art/generated/$safeCategory" }
}

$destinationDir = Join-Path $destinationDir $safeName
New-Item -ItemType Directory -Force -Path $destinationDir | Out-Null
$destination = Join-Path $destinationDir ("{0}{1}" -f $safeName, $extension)

Copy-Item $source.FullName $destination -Force

# Windows PowerShell 5.1 does not provide System.IO.Path.GetRelativePath.
# Since every destination lives under the repo root, trim that prefix instead.
$relativeDestination = $destination.Substring($repoRoot.Length).TrimStart('\','/').Replace('\','/')

Write-Host ""
Write-Host "ART DROP" -ForegroundColor Cyan
Write-Host "Source:      $($source.Name)"
Write-Host "Destination: $relativeDestination" -ForegroundColor Green

Push-Location $repoRoot
try {
    git add -- $relativeDestination
    $status = git status --porcelain -- $relativeDestination
    if (-not $status) {
        Write-Host "No asset changes to commit."
        exit 0
    }

    $commitMessage = "Add art asset: $safeName"
    git commit -m $commitMessage

    if (-not $NoPush) {
        git push
        Write-Host "Pushed to GitHub." -ForegroundColor Green
    } else {
        Write-Host "Committed locally. Push skipped (-NoPush)." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Success. ChatGPT can now wire $relativeDestination into Godot." -ForegroundColor Cyan
}
finally {
    Pop-Location
}
