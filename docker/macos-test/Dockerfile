# Linux-based test environment for macOS install scripts (BATS testing, coverage, and linting)
ARG KCOV_VERSION=43
ARG KCOV_SHA256=4cbba86af11f72de0c7514e09d59c7927ed25df7cebdad087f6d3623213b95bf

FROM ubuntu:22.04 AS kcov-builder

ARG KCOV_VERSION
ARG KCOV_SHA256

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies for kcov
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    build-essential \
    cmake \
    libcurl4-openssl-dev \
    libdw-dev \
    libiberty-dev \
    binutils-dev \
    && rm -rf /var/lib/apt/lists/*

# Install kcov for coverage measurement (direct build)
RUN curl -sL "https://github.com/SimonKagstrom/kcov/archive/refs/tags/v${KCOV_VERSION}.tar.gz" -o /tmp/kcov.tar.gz && \
    echo "${KCOV_SHA256}  /tmp/kcov.tar.gz" | sha256sum -c - && \
    tar -xzf /tmp/kcov.tar.gz -C /tmp && \
    cmake -S "/tmp/kcov-${KCOV_VERSION}" -B "/tmp/kcov-${KCOV_VERSION}/build" -DCMAKE_BUILD_TYPE=Release && \
    cmake --build "/tmp/kcov-${KCOV_VERSION}/build" --target install && \
    rm -rf "/tmp/kcov-${KCOV_VERSION}" /tmp/kcov.tar.gz

FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    libcurl4 \
    libdw1 \
    libiberty1 \
    binutils \
    wget \
    && rm -rf /var/lib/apt/lists/*

# kcov v43 - latest stable release
COPY --from=kcov-builder /usr/local/bin/kcov /usr/local/bin/kcov
COPY --from=kcov-builder /usr/local/share/kcov /usr/local/share/kcov

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
