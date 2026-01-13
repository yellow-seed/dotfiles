BeforeAll {
    # Script path
    $ScriptPath = Join-Path $PSScriptRoot "dev-tools.ps1"
}

Describe "dev-tools.ps1 Script Tests" {
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

        It "Test-Administrator function should be defined" {
            Get-Command Test-Administrator -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }

        It "Install-Pester function should be defined" {
            Get-Command Install-Pester -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }

        It "Install-PowerShell7 function should be defined" {
            Get-Command Install-PowerShell7 -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }

        It "Set-GitConfig function should be defined" {
            Get-Command Set-GitConfig -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }

        It "Install-PSScriptAnalyzer function should be defined" {
            Get-Command Install-PSScriptAnalyzer -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }

        It "Main function should be defined" {
            Get-Command Main -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }

        It "Test-Administrator should return boolean" -Skip:($IsLinux -or $IsMacOS) {
            $result = Test-Administrator
            $result | Should -BeOfType [bool]
        }
    }

    Context "Development Tools" {
        It "Pester module reference should be present" {
            $content = Get-Content $ScriptPath -Raw
            $content | Should -Match 'Pester'
        }

        It "PSScriptAnalyzer module reference should be present" {
            $content = Get-Content $ScriptPath -Raw
            $content | Should -Match 'PSScriptAnalyzer'
        }

        It "PowerShell 7 check should be present" {
            $content = Get-Content $ScriptPath -Raw
            $content | Should -Match '\$PSVersionTable\.PSVersion'
        }

        It "Git configuration should be present" {
            $content = Get-Content $ScriptPath -Raw
            $content | Should -Match 'git config'
            $content | Should -Match 'core\.autocrlf'
        }
    }
}
