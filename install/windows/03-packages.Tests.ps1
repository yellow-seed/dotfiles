BeforeAll {
    # Script paths
    $ScriptPath = Join-Path $PSScriptRoot "03-packages.ps1"
    $PackageJsonPath = Join-Path $PSScriptRoot "packages.json"
}

Describe "03-packages.ps1 Script Tests" {
    Context "Script File Validation" {
        It "Script file should exist" {
            $ScriptPath | Should -Exist
        }

        It "Default packages.json should exist" {
            $PackageJsonPath | Should -Exist
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

        It "Script should check for winget availability" {
            $content = Get-Content $ScriptPath -Raw
            $content | Should -Match 'Test-WingetExists'
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

        It "Find-PackageFile function should be defined" {
            Get-Command Find-PackageFile -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }

        It "Install-Packages function should be defined" {
            Get-Command Install-Packages -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }

        It "Export-Packages function should be defined" {
            Get-Command Export-Packages -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }

        It "Main function should be defined" {
            Get-Command Main -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
    }

    Context "Package File Search Logic" {
        BeforeAll {
            . $ScriptPath
        }

        It "Find-PackageFile should search expected locations" {
            $content = Get-Content $ScriptPath -Raw
            $content | Should -Match '\$env:USERPROFILE\\\.winget\.json'
            $content | Should -Match '\$env:USERPROFILE\\winget\.json'
            $content | Should -Match '\$PSScriptRoot\\packages\.json'
            $content | Should -Match '\$PSScriptRoot\\winget\.json'
        }

        It "Find-PackageFile should find the default packages.json" {
            $result = Find-PackageFile
            $result | Should -Not -BeNullOrEmpty
            $result | Should -Match 'packages\.json$'
        }
    }

    Context "Package JSON Validation" {
        It "packages.json should be valid JSON" {
            { Get-Content $PackageJsonPath | ConvertFrom-Json } | Should -Not -Throw
        }

        It "packages.json should have required schema" {
            $json = Get-Content $PackageJsonPath | ConvertFrom-Json
            $json.'$schema' | Should -Be "https://aka.ms/winget-packages.schema.2.0.json"
        }

        It "packages.json should have Sources array" {
            $json = Get-Content $PackageJsonPath | ConvertFrom-Json
            $json.Sources | Should -Not -BeNullOrEmpty
            # PowerShell converts JSON arrays to PSCustomObject or arrays depending on content
            # Check if it's iterable instead of checking exact type
            @($json.Sources).Count | Should -BeGreaterThan 0
        }

        It "packages.json should have Packages array" {
            $json = Get-Content $PackageJsonPath | ConvertFrom-Json
            $json.Sources[0].Packages | Should -Not -BeNullOrEmpty
            # PowerShell converts JSON arrays to PSCustomObject or arrays depending on content
            # Check if it's iterable instead of checking exact type
            @($json.Sources[0].Packages).Count | Should -BeGreaterThan 0
        }

        It "packages.json should have valid package identifiers" {
            $json = Get-Content $PackageJsonPath | ConvertFrom-Json
            foreach ($package in $json.Sources[0].Packages) {
                $package.PackageIdentifier | Should -Not -BeNullOrEmpty
                $package.PackageIdentifier | Should -Match '^[\w\.-]+\.[\w\.-]+$'
            }
        }
    }

    Context "Command Line Argument Parsing" {
        It "Script should support -Action parameter" {
            $content = Get-Content $ScriptPath -Raw
            $content | Should -Match '"-Action"'
        }

        It "Script should support -File parameter" {
            $content = Get-Content $ScriptPath -Raw
            $content | Should -Match '"-File"'
        }

        It "Script should support --export flag" {
            $content = Get-Content $ScriptPath -Raw
            $content | Should -Match '"--export"'
        }

        It "Script should support --import flag" {
            $content = Get-Content $ScriptPath -Raw
            $content | Should -Match '"--import"'
        }
    }
}
