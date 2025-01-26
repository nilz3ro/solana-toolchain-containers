# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04 AS base

# Set environment variables for versions
ARG RUST_VERSION=1.75.0
ARG SOLANA_VERSION=1.17.17
ARG ANCHOR_VERSION=v0.29.0

# Set non-interactive frontend for apt (to avoid prompts during installation)
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    build-essential \
    libssl-dev \
    pkg-config \
    git \
    cmake \
    vim \
    tmux \
    && rm -rf /var/lib/apt/lists/*

# Install Rust and Cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION}
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Node.js 18 (using NodeSource binary distribution)
RUN curl -fsSL https://nodejs.org/dist/v18.20.2/node-v18.20.2-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1 && \
    npm install -g yarn

# Install Solana
RUN if [ "$SOLANA_VERSION" \< "2.0.0" ]; then \
    sh -c "$(curl -sSfL https://release.solana.com/v${SOLANA_VERSION}/install)"; \
    else \
    sh -c "$(curl -sSfL https://release.anza.xyz/v${SOLANA_VERSION}/install)"; \
    fi

# Add Solana binaries to PATH
ENV PATH="/root/.local/share/solana/install/active_release/bin:${PATH}"

# Install Anchor
RUN echo "Installing Anchor ${ANCHOR_VERSION}" && \
    cargo install --git https://github.com/coral-xyz/anchor --tag ${ANCHOR_VERSION} anchor-cli --locked --force

# Set the working directory
WORKDIR /workspace

# Default command
CMD ["bash"]
