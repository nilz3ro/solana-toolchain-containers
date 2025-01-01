# Use Ubuntu 20.04 which has libssl1.1 available
FROM ubuntu:20.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies - this layer rarely changes
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    pkg-config \
    libssl1.1 \
    libssl-dev \
    libudev-dev \
    python3 \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 18 and Yarn - this layer changes infrequently
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn \
    && rm -rf /var/lib/apt/lists/*

# Arguments for version control - change these during build to update versions
ARG RUST_VERSION=1.66.0
ARG SOLANA_VERSION=1.14.18
ARG ANCHOR_VERSION=v0.26.0

# Install Rust - this layer changes when RUST_VERSION changes
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION}
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Solana CLI - this layer changes when SOLANA_VERSION changes
RUN sh -c "$(curl -sSfL https://release.solana.com/v${SOLANA_VERSION}/install)" \
    && export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"
ENV PATH="/root/.local/share/solana/install/active_release/bin:${PATH}"

# Install Anchor CLI - this layer changes when ANCHOR_VERSION changes
RUN cargo install --git https://github.com/coral-xyz/anchor --tag ${ANCHOR_VERSION} anchor-cli --locked --force

# Verify installations
RUN rustc --version && \
    cargo --version && \
    node --version && \
    npm --version && \
    solana --version && \
    anchor --version

# Set working directory
WORKDIR /app

CMD ["/bin/bash"]