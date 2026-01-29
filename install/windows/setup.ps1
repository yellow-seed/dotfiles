#!/usr/bin/env pwsh
#Requires -Version 5.1
# Windows setup orchestrator
# Runs step scripts in sequence

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Debug mode
if ($env:DOTFILES_DEBUG) {
    Set-PSDebug -Trace 2
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Invoke-Step {
    param(
        [string]$Name,
        [string]$ScriptPath
    )

    Write-Host $Name

    if (-not (Test-Path $ScriptPath)) {
        Write-Error "Script not found: $ScriptPath"
        exit 1
    }

    & $ScriptPath
}

function Main {
    Write-Host "Initializing Windows environment..."

    Invoke-Step "Step 1: Setting up Winget..." (Join-Path $ScriptDir "01-winget.ps1")
    Invoke-Step "Step 2: Installing development tools..." (Join-Path $ScriptDir "02-dev-tools.ps1")
    Invoke-Step "Step 3: Installing packages..." (Join-Path $ScriptDir "03-packages.ps1")

    Write-Host "Windows setup completed."
}

if ($MyInvocation.InvocationName -ne '.') {
    Main
}
