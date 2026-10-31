param([string]$OutputDirectory = 'D:\Omni-Shell')

$ErrorActionPreference = 'Stop'
$repoDirectory = Split-Path -Parent $PSScriptRoot
$assetSource = Join-Path $repoDirectory 'assets\xp'
$releaseAssets = Join-Path $OutputDirectory 'assets\xp'
New-Item -ItemType Directory -Force -Path $releaseAssets | Out-Null
Copy-Item -Path (Join-Path $assetSource '*') -Destination $releaseAssets -Recurse -Force

# Use the owner's installed fonts locally; font binaries are not uploaded to GitHub.
$fontOutput = Join-Path $releaseAssets 'fonts'
New-Item -ItemType Directory -Force -Path $fontOutput | Out-Null
foreach ($fontFile in @('tahoma.ttf', 'tahomabd.ttf', 'trebuc.ttf', 'trebucbd.ttf', 'lucon.ttf')) {
    $fontSource = Join-Path $env:WINDIR ('Fonts\' + $fontFile)
    if (Test-Path -LiteralPath $fontSource) {
        Copy-Item -LiteralPath $fontSource -Destination $fontOutput -Force
    } else {
        throw "Required local font missing: $fontFile"
    }
}

$versionsRoot = Join-Path $env:LOCALAPPDATA 'Roblox\Versions'
$studioVersions = @(Get-ChildItem -LiteralPath $versionsRoot -Directory | Where-Object {
    Test-Path -LiteralPath (Join-Path $_.FullName 'RobloxStudioBeta.exe')
})
foreach ($studioVersion in $studioVersions) {
    $localAssetRoot = Join-Path $studioVersion.FullName 'content\omnishell\xp'
    New-Item -ItemType Directory -Force -Path $localAssetRoot | Out-Null
    Copy-Item -Path (Join-Path $releaseAssets '*') -Destination $localAssetRoot -Recurse -Force
    Write-Output "XP local assets: $localAssetRoot"
}
if ($studioVersions.Count -eq 0) {
    Write-Warning 'No local Roblox Studio installation found. Assets are saved beside the release; run this script on the Studio computer.'
}
