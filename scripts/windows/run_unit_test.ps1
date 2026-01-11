#!/usr/bin/env pwsh
# Windows unit test runner using Pester
# Runs all Pester tests in the tests directory

$ErrorActionPreference = "Stop"

# Get the root directory of the repository
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Write-Host "Running Pester tests for Windows scripts..."
Write-Host "Repository root: $RepoRoot"
Write-Host ""

# Check if Pester is installed
$pesterModule = Get-Module -ListAvailable -Name Pester | Where-Object { $_.Version -ge [Version]"5.0.0" }
if (-not $pesterModule) {
    Write-Host "Pester 5.x or later is not installed. Installing..."
    Install-Module -Name Pester -MinimumVersion 5.0.0 -Force -Scope CurrentUser -SkipPublisherCheck
}

# Import Pester module
Import-Module Pester -MinimumVersion 5.0.0

# Set working directory to repository root
Push-Location $RepoRoot

try {
    # Pester configuration
    $configuration = [PesterConfiguration]@{
        Run    = @{
            Path = "tests/install/windows"
            Exit = $true
        }
        Output = @{
            Verbosity = "Detailed"
        }
        Should = @{
            ErrorAction = "Stop"
        }
    }

    # Run tests
    $result = Invoke-Pester -Configuration $configuration

    # Display summary
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Test Summary" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Total Tests: $($result.TotalCount)" -ForegroundColor White
    Write-Host "Passed: $($result.PassedCount)" -ForegroundColor Green
    Write-Host "Failed: $($result.FailedCount)" -ForegroundColor $(if ($result.FailedCount -gt 0) { "Red" } else { "White" })
    Write-Host "Skipped: $($result.SkippedCount)" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan

    # Exit with appropriate code
    if ($result.FailedCount -gt 0) {
        exit 1
    }
}
finally {
    Pop-Location
}
