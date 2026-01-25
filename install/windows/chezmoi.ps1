Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$debug = $env:DOTFILES_DEBUG
if ($debug) {
  Set-PSDebug -Trace 1
}

$githubUsername = if ($env:GITHUB_USERNAME) { $env:GITHUB_USERNAME } else { "yellow-seed" }
$dryRun = if ($env:DRY_RUN) { $env:DRY_RUN } else { "false" }

Write-Output "Initializing Windows environment..."

if ($dryRun -eq "true") {
  Write-Output "[DRY RUN] Would install chezmoi for $githubUsername"
  exit 0
}

Write-Output "Installing chezmoi and applying dotfiles..."
$installer = (Invoke-RestMethod -Uri "https://get.chezmoi.io/ps1")
Invoke-Expression "&{$installer} -- init --apply $githubUsername"

Write-Output "Windows setup completed."
