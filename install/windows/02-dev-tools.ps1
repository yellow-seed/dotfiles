#!/usr/bin/env pwsh
# Development tools installation script for Windows
# Installs tools required for dotfiles development and testing

$ErrorActionPreference = "Stop"

# Debug mode
if ($env:DOTFILES_DEBUG) {
    Set-PSDebug -Trace 2
}

# Check if running as administrator
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Install Pester for PowerShell testing
function Install-Pester {
    Write-Host "Checking Pester installation..."

    $pesterModule = Get-Module -ListAvailable -Name Pester | Where-Object { $_.Version -ge [Version]"5.0.0" }

    if ($pesterModule) {
        Write-Host "Pester 5.x is already installed."
        Get-Module -ListAvailable -Name Pester | Select-Object Name, Version | Format-Table
        return
    }

    Write-Host "Installing Pester 5.x..."

    try {
        # Install Pester for current user (no admin required)
        Install-Module -Name Pester -MinimumVersion 5.0.0 -Force -Scope CurrentUser -SkipPublisherCheck
        Write-Host "Pester installed successfully" -ForegroundColor Green

        # Display installed version
        Get-Module -ListAvailable -Name Pester | Select-Object Name, Version | Format-Table
    }
    catch {
        Write-Error "Failed to install Pester: $_"
        exit 1
    }
}

# Install PowerShell 7+ (if not already installed)
function Install-PowerShell7 {
    Write-Host "Checking PowerShell version..."

    if ($PSVersionTable.PSVersion.Major -ge 7) {
        Write-Host "PowerShell $($PSVersionTable.PSVersion) is already installed."
        return
    }

    Write-Host "PowerShell 7+ is recommended for development."
    Write-Host "Current version: $($PSVersionTable.PSVersion)"
    Write-Host ""
    Write-Host "To install PowerShell 7+, run:"
    Write-Host "  winget install Microsoft.PowerShell"
    Write-Host ""
    Write-Host "Or download from: https://github.com/PowerShell/PowerShell/releases"
}

# Configure Git for Windows line endings
# SuppressMessageAttribute for PSScriptAnalyzer
function Set-GitConfig {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification='Function only modifies git global config, user consent implied by running script')]
    param()

    Write-Host "Configuring Git for Windows..."

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "Git is not installed. Skipping Git configuration." -ForegroundColor Yellow
        return
    }

    try {
        # Set core.autocrlf to false (chezmoi manages line endings)
        git config --global core.autocrlf false
        Write-Host "Git configured: core.autocrlf = false" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to configure Git: $_"
    }
}

# Install PSScriptAnalyzer for PowerShell linting
function Install-PSScriptAnalyzer {
    Write-Host "Checking PSScriptAnalyzer installation..."

    if (Get-Module -ListAvailable -Name PSScriptAnalyzer) {
        Write-Host "PSScriptAnalyzer is already installed."
        Get-Module -ListAvailable -Name PSScriptAnalyzer | Select-Object Name, Version | Format-Table
        return
    }

    Write-Host "Installing PSScriptAnalyzer..."

    try {
        Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser -SkipPublisherCheck
        Write-Host "PSScriptAnalyzer installed successfully" -ForegroundColor Green

        Get-Module -ListAvailable -Name PSScriptAnalyzer | Select-Object Name, Version | Format-Table
    }
    catch {
        Write-Error "Failed to install PSScriptAnalyzer: $_"
        exit 1
    }
}

# Main function
function Main {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Windows Development Tools Setup" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    # Check if running as admin (optional but recommended)
    if (-not (Test-Administrator)) {
        Write-Host "Note: Not running as Administrator. Some operations may require elevation." -ForegroundColor Yellow
        Write-Host ""
    }

    # Install development tools
    Install-PowerShell7
    Write-Host ""

    Install-Pester
    Write-Host ""

    Install-PSScriptAnalyzer
    Write-Host ""

    Set-GitConfig
    Write-Host ""

    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Setup completed!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "1. Run tests: .\install\windows\run_unit_test.ps1"
    Write-Host "2. Install packages: .\install\windows\03-packages.ps1"
    Write-Host ""
}

# Execute main if script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Main
}
