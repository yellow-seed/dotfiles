#!/usr/bin/env pwsh
# Package installation script for Windows using winget
# Installs packages from winget.json or packages.json

$ErrorActionPreference = "Stop"

# Debug mode
if ($env:DOTFILES_DEBUG) {
    Set-PSDebug -Trace 2
}

# Check if winget is available
function Test-WingetExists {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification='Exists is not a plural noun, it is a verb form')]
    param()

    try {
        $null = Get-Command winget -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Find package definition file
function Find-PackageFile {
    # Search order: winget.json in home directory, then packages.json in script directory
    $locations = @(
        "$env:USERPROFILE\.winget.json",
        "$env:USERPROFILE\winget.json",
        "$PSScriptRoot\packages.json",
        "$PSScriptRoot\winget.json"
    )

    foreach ($location in $locations) {
        if (Test-Path $location) {
            Write-Host "Found package file: $location"
            return $location
        }
    }

    return $null
}

# Install packages from JSON file
function Install-Packages {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification='Packages refers to multiple items being installed, plural is intentional')]
    param (
        [string]$PackageFile
    )

    if (-not (Test-Path $PackageFile)) {
        Write-Error "Package file not found: $PackageFile"
        exit 1
    }

    Write-Host "Installing packages from: $PackageFile"
    Write-Host ""

    # Import packages using winget
    try {
        winget import -i $PackageFile --accept-package-agreements --accept-source-agreements --ignore-versions
        Write-Host ""
        Write-Host "Package installation completed successfully"
    }
    catch {
        Write-Error "Failed to install packages: $_"
        exit 1
    }
}

# Export current packages to JSON file
function Export-Packages {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification='Packages refers to multiple items being exported, plural is intentional')]
    param (
        [string]$OutputFile = "$env:USERPROFILE\.winget.json"
    )

    Write-Host "Exporting installed packages to: $OutputFile"

    try {
        winget export -o $OutputFile --include-versions
        Write-Host "Package list exported successfully"
    }
    catch {
        Write-Error "Failed to export packages: $_"
        exit 1
    }
}

# Main function
function Main {
    param (
        [string]$Action = "install",
        [string]$File = ""
    )

    # Check if winget is installed
    if (-not (Test-WingetExists)) {
        Write-Error "Winget is not installed. Please run winget.ps1 first."
        exit 1
    }

    if ($Action -eq "export") {
        if ($File) {
            Export-Packages -OutputFile $File
        }
        else {
            Export-Packages
        }
    }
    else {
        # Install mode
        if ($File) {
            $packageFile = $File
        }
        else {
            $packageFile = Find-PackageFile
        }

        if (-not $packageFile) {
            Write-Error "No package file found. Please create a winget.json or packages.json file."
            Write-Host ""
            Write-Host "To export current packages, run:"
            Write-Host "  .\packages.ps1 -Action export"
            exit 1
        }

        Install-Packages -PackageFile $packageFile
    }
}

# Execute main if script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    # Parse command line arguments
    $action = "install"
    $file = ""

    for ($i = 0; $i -lt $args.Count; $i++) {
        switch ($args[$i]) {
            "-Action" { $action = $args[$i + 1]; $i++ }
            "-File" { $file = $args[$i + 1]; $i++ }
            "--export" { $action = "export" }
            "--import" { $action = "install" }
            default {
                if ($args[$i] -notmatch "^-") {
                    $file = $args[$i]
                }
            }
        }
    }

    Main -Action $action -File $file
}
