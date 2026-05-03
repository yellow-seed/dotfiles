# Linux-based test environment for macOS install scripts (BATS testing, coverage, and linting)
FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    kcov \
    wget \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Nix for nix-darwin flake checks in the macOS test image
ENV USER=root
ENV PATH=/root/.nix-profile/bin:/nix/var/nix/profiles/default/bin:${PATH}
RUN groupadd -r nixbld && \
    for n in $(seq 1 10); do \
    useradd -c "Nix build user ${n}" -d /var/empty -g nixbld -G nixbld -M -N -r -s /usr/sbin/nologin "nixbld${n}"; \
    done && \
    mkdir -m 0755 /nix && \
    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

# Install BATS (Bash Automated Testing System)
RUN git clone --depth 1 https://github.com/bats-core/bats-core.git /tmp/bats-core && \
    cd /tmp/bats-core && \
    ./install.sh /usr/local && \
    rm -rf /tmp/bats-core

# Install bats-support and bats-assert
RUN git clone --depth 1 https://github.com/bats-core/bats-support.git /usr/local/lib/bats-support && \
    git clone --depth 1 https://github.com/bats-core/bats-assert.git /usr/local/lib/bats-assert

# Install ShellCheck
RUN wget -qO- "https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz" | \
    tar -xJv && \
    mv "shellcheck-stable/shellcheck" /usr/local/bin/ && \
    rm -rf shellcheck-stable

# Install shfmt
RUN wget -qO /usr/local/bin/shfmt "https://github.com/mvdan/sh/releases/download/v3.8.0/shfmt_v3.8.0_linux_amd64" && \
    chmod +x /usr/local/bin/shfmt

# Install actionlint
RUN wget -qO- "https://github.com/rhysd/actionlint/releases/download/v1.6.27/actionlint_1.6.27_linux_amd64.tar.gz" | \
    tar -xzv -C /usr/local/bin actionlint && \
    chmod +x /usr/local/bin/actionlint

# Copy lint-shell script
COPY lint-shell /usr/local/bin/lint-shell
RUN chmod +x /usr/local/bin/lint-shell

# Set working directory
WORKDIR /workspace

# Default command
CMD ["bash"]
