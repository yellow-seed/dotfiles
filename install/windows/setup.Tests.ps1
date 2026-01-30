BeforeAll {
    # Script path
    $ScriptPath = Join-Path $PSScriptRoot "setup.ps1"
}

Describe "setup.ps1 Script Tests" {
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

        It "Script should enable StrictMode" {
            $content = Get-Content $ScriptPath -Raw
            $content | Should -Match 'Set-StrictMode\s+-Version\s+Latest'
        }

        It "Script should contain debug mode support" {
            $content = Get-Content $ScriptPath -Raw
            $content | Should -Match '\$env:DOTFILES_DEBUG'
        }
    }

    Context "Function Tests" {
        BeforeAll {
            . $ScriptPath
        }

        It "Invoke-Step function should be defined" {
            Get-Command Invoke-Step -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }

        It "Main function should be defined" {
            Get-Command Main -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
    }

    Context "Step Script References" {
        It "Script should reference step scripts" {
            $content = Get-Content $ScriptPath -Raw
            $content | Should -Match '01-winget\.ps1'
            $content | Should -Match '02-dev-tools\.ps1'
            $content | Should -Match '03-packages\.ps1'
        }
    }
}
