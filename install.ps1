# install.ps1 — Link shared skills into workspace(s) and create runtime directories.
# Run from the repo root: .\install.ps1
# Or target a specific workspace: .\install.ps1 workspaces\my-assistant

param(
    [string[]]$Workspaces = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = $PSScriptRoot
$ConfigDest = Join-Path $env:USERPROFILE ".claude-assistant\config"

function Link-Skills {
    param([string]$Ws)

    $skillsDir = Join-Path $Ws ".claude\skills"
    New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null

    $sharedSkills = Join-Path $Root "shared\skills"
    if (-not (Test-Path $sharedSkills)) { return }

    foreach ($category in Get-ChildItem -Directory $sharedSkills) {
        foreach ($skillDir in Get-ChildItem -Directory $category.FullName) {
            $name   = $skillDir.Name
            $target = Join-Path $skillsDir $name

            if (-not (Test-Path $target)) {
                # Junction links work without admin rights on Windows
                New-Item -ItemType Junction -Path $target -Target $skillDir.FullName | Out-Null
                Write-Host "  linked $name -> $Ws\.claude\skills\"
            }
        }
    }
}

function Create-RuntimeDirs {
    param([string]$Ws)

    @(
        "inbox",
        "output\daily",
        "output\weekly",
        "output\drafts",
        "projects"
    ) | ForEach-Object {
        New-Item -ItemType Directory -Force -Path (Join-Path $Ws $_) | Out-Null
    }

    $memory = Join-Path $Ws "MEMORY.md"
    if (-not (Test-Path $memory)) {
        New-Item -ItemType File -Path $memory | Out-Null
    }
}

function Install-ConfigTemplates {
    New-Item -ItemType Directory -Force -Path $ConfigDest | Out-Null

    $configDir = Join-Path $Root "config"
    if (-not (Test-Path $configDir)) { return }

    foreach ($f in Get-ChildItem -File $configDir -Filter "*.example.*") {
        $destName = $f.Name -replace "\.example", ""
        $dest     = Join-Path $ConfigDest $destName

        if (-not (Test-Path $dest)) {
            Copy-Item $f.FullName -Destination $dest
            Write-Host "  copied $($f.Name) -> $dest"
        } else {
            Write-Host "  skip $destName (already exists)"
        }
    }
}

# Resolve workspaces to install
if ($Workspaces.Count -gt 0) {
    $targets = $Workspaces | ForEach-Object { Resolve-Path $_ -ErrorAction Stop }
} else {
    $wsRoot  = Join-Path $Root "workspaces"
    $targets = if (Test-Path $wsRoot) {
        Get-ChildItem -Directory $wsRoot | Select-Object -ExpandProperty FullName
    } else { @() }
}

Write-Host "-> Installing policy config templates to $ConfigDest\"
Install-ConfigTemplates

foreach ($ws in $targets) {
    if (-not (Test-Path $ws -PathType Container)) {
        Write-Host "skip $ws (not a directory)"
        continue
    }
    Write-Host "-> Workspace: $ws"
    Link-Skills $ws
    Create-RuntimeDirs $ws
}

Write-Host "Done. Point Cowork at workspaces\<name>\"
