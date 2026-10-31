param(
    [string]$OutputDirectory = 'D:\Omni-Shell',
    [string]$RojoPath = 'rojo'
)

$ErrorActionPreference = 'Stop'
$repoDirectory = Split-Path -Parent $PSScriptRoot
$projectFile = Join-Path $repoDirectory 'default.project.json'

# Use an explicitly supplied CLI, a PATH installation, or the local development CLI.
$rojoCommand = Get-Command -Name $RojoPath -ErrorAction SilentlyContinue
if ($null -eq $rojoCommand -and $RojoPath -eq 'rojo') {
    $localRojo = Join-Path $repoDirectory 'work\tools\rojo\rojo.exe'
    if (Test-Path -LiteralPath $localRojo) {
        $rojoCommand = Get-Command -Name $localRojo
    }
}
if ($null -eq $rojoCommand) {
    throw 'Rojo CLI not found. Install it or supply -RojoPath.'
}

$buildDirectory = Join-Path $repoDirectory 'build'
New-Item -ItemType Directory -Force -Path $buildDirectory | Out-Null
$temporaryBuild = Join-Path $buildDirectory ('OmniShell-' + [Guid]::NewGuid().ToString('N') + '.rbxlx')

try {
    & $rojoCommand.Source build $projectFile -o $temporaryBuild
    if ($LASTEXITCODE -ne 0) { throw 'Rojo build failed. Current release was not replaced.' }
    [xml]$place = Get-Content -LiteralPath $temporaryBuild -Raw -Encoding UTF8
    if ($place.DocumentElement.Name -ne 'roblox') { throw 'Invalid Roblox place XML.' }

    $archiveDirectory = Join-Path $OutputDirectory 'builds'
    New-Item -ItemType Directory -Force -Path $archiveDirectory | Out-Null
    $buildStamp = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ')
    $archiveFile = Join-Path $archiveDirectory ("OmniShell-$buildStamp.rbxlx")
    Copy-Item -LiteralPath $temporaryBuild -Destination $archiveFile

    $currentFile = Join-Path $OutputDirectory 'OmniShell.rbxlx'
    Copy-Item -LiteralPath $temporaryBuild -Destination $currentFile -Force
    Write-Output "Current build: $currentFile"
    Write-Output "Archived build: $archiveFile"
} finally {
    if (Test-Path -LiteralPath $temporaryBuild) {
        Remove-Item -LiteralPath $temporaryBuild
    }
}
