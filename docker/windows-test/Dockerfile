# Windows PowerShell test environment using PowerShell Core on Linux
FROM mcr.microsoft.com/powershell:lts-ubuntu-22.04

# Install required tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Pester and PSScriptAnalyzer
RUN pwsh -Command "Install-Module -Name Pester -MinimumVersion 5.0.0 -Force -Scope AllUsers -SkipPublisherCheck"
RUN pwsh -Command "Install-Module -Name PSScriptAnalyzer -Force -Scope AllUsers -SkipPublisherCheck"

# Set working directory
WORKDIR /workspace

# Default command
CMD ["pwsh"]
