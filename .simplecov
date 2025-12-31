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
    add_filter '/tests/'
    add_filter '/home/'
    add_filter '/.github/'
    add_filter 'setup.sh'
    
    # Group files by directory
    add_group 'Install Scripts', 'install/'
    add_group 'Utility Scripts', 'scripts/'
  end
end
