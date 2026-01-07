#!/usr/bin/env pwsh
# Winget installation script for Windows
# Ensures winget is installed and available

$ErrorActionPreference = "Stop"

# Debug mode
if ($env:DOTFILES_DEBUG) {
    Set-PSDebug -Trace 2
}

# Check if winget is installed
function Test-WingetExists {
    try {
        $null = Get-Command winget -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Install winget (App Installer from Microsoft Store)
function Install-Winget {
    if (Test-WingetExists) {
        Write-Host "Winget is already installed."
        winget --version
        return
    }

    Write-Host "Winget is not installed. Installing..."

    # Check Windows version
    $osVersion = [System.Environment]::OSVersion.Version
    if ($osVersion.Major -lt 10) {
        Write-Error "Winget requires Windows 10 or later"
        exit 1
    }

    Write-Host "Please install 'App Installer' from Microsoft Store to get winget."
    Write-Host "URL: https://www.microsoft.com/p/app-installer/9nblggh4nns1"
    Write-Host ""
    Write-Host "Or install via PowerShell (requires admin):"
    Write-Host "Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe"

    exit 1
}

# Main function
function Main {
    Install-Winget
}

# Execute main if script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Main
}
