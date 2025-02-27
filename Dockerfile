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
    jq \
    tmux \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 18 and Yarn - this layer changes infrequently
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn \
    && npm install -g pnpm \
    && npm install -g @metaplex-foundation/amman \
    && rm -rf /var/lib/apt/lists/*

# Arguments for version control - placing them right before use
ARG RUST_VERSION
ARG SOLANA_VERSION
ARG ANCHOR_VERSION

# Install Rust - this layer changes when RUST_VERSION changes
RUN echo "Installing Rust ${RUST_VERSION}" && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION}
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Solana CLI - this layer changes when SOLANA_VERSION changes
RUN echo "Installing Solana ${SOLANA_VERSION}" && \
    sh -c "$(curl -sSfL https://release.solana.com/v${SOLANA_VERSION}/install)" \
    && export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"
ENV PATH="/root/.local/share/solana/install/active_release/bin:${PATH}"

# Install Anchor CLI - this layer changes when ANCHOR_VERSION changes
RUN echo "Installing Anchor ${ANCHOR_VERSION}" && \
    cargo install --git https://github.com/coral-xyz/anchor --tag ${ANCHOR_VERSION} anchor-cli --locked --force

# Create and build a test project to verify toolchain functionality
WORKDIR /tmp/verify
RUN anchor init test_project

WORKDIR /tmp/verify/test_project
RUN cargo check
RUN anchor build 
RUN echo "Test build completed successfully"
RUN rm -rf /tmp/verify/test_project

# Verify installations
RUN rustc --version && \
    cargo --version && \
    node --version && \
    npm --version && \
    solana --version && \
    anchor --version

# Set final working directory
WORKDIR /app

CMD ["/bin/bash"]