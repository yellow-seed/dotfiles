BeforeAll {
    # Script path
    $ScriptPath = Join-Path $PSScriptRoot "01-winget.ps1"
}

Describe "01-winget.ps1 Script Tests" {
    Context "Script File Validation" {
        It "Script file should exist" {
            $ScriptPath | Should -Exist
        }

        It "Script should be a PowerShell file" {
            $ScriptPath | Should -Match "\.ps1$"
        }

        It "Script should contain ErrorActionPreference" {
            $content = Get-Content $ScriptPath -Raw
            $content | Should -Match '\$ErrorActionPreference\s*=\s*"Stop"'
        }

        It "Script should contain debug mode support" {
            $content = Get-Content $ScriptPath -Raw
            $content | Should -Match '\$env:DOTFILES_DEBUG'
        }
    }

    Context "Function Tests" {
        BeforeAll {
            # Source the script to load functions
            . $ScriptPath
        }

        It "Test-WingetExists function should be defined" {
            Get-Command Test-WingetExists -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }

        It "Install-Winget function should be defined" {
            Get-Command Install-Winget -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }

        It "Test-WingetExists should return boolean" {
            $result = Test-WingetExists
            $result | Should -BeOfType [bool]
        }
    }

    Context "Windows Version Check" {
        BeforeAll {
            . $ScriptPath
        }

        It "Should support Windows 10 or later" -Skip:($IsLinux -or $IsMacOS) {
            $osVersion = [System.Environment]::OSVersion.Version
            $osVersion.Major | Should -BeGreaterOrEqual 10
        }
    }
}
