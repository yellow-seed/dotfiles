# SimpleCov configuration for bashcov
# This file is used only in CI/CD for coverage reporting

if ENV['CI']
  require 'simplecov_json_formatter'
  
  SimpleCov.start do
    # Use JSON formatter for Codecov
    formatter SimpleCov::Formatter::JSONFormatter
    
    # Set root directory
    root ENV['GITHUB_WORKSPACE'] || Dir.pwd
    
    # Coverage directory
    coverage_dir 'coverage'
    
    # Command name for better identification in reports
    command_name "bashcov-#{ENV['RUNNER_OS'] || 'local'}"
    
    # Add filters to exclude files we don't want to measure
    add_filter '/tests/'          # Test files
    add_filter '/home/'           # Chezmoi configuration files (not executable scripts)
    add_filter '/.github/'        # GitHub Actions workflows
    add_filter '/setup.sh'        # Entry point script (minimal logic)
    
    # Exclude BATS internal scripts to avoid tracking errors
    add_filter '/opt/homebrew/Cellar/bats-core/'  # macOS Homebrew
    add_filter '/usr/local/Cellar/bats-core/'    # macOS Homebrew (旧パス)
    add_filter '/usr/lib/bats'                   # Ubuntu
    add_filter '/usr/bin/bats'                   # Ubuntu
    
    # Group files by directory
    add_group 'Install Scripts', 'install/'
    add_group 'Utility Scripts', 'scripts/'
  end
end

