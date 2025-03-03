# Use Ubuntu 20.04 which has libssl1.1 available
FROM ubuntu:20.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Create non-root user
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g $GROUP_ID developer && \
    useradd -u $USER_ID -g $GROUP_ID -s /bin/bash -m developer && \
    apt-get update && apt-get install -y sudo && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer && \
    rm -rf /var/lib/apt/lists/*

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

# Switch to non-root user for all subsequent operations
USER developer
WORKDIR /home/developer

# Install Node.js 18 and Yarn - this layer changes infrequently
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo bash - \
    && sudo apt-get install -y nodejs \
    && sudo npm install -g yarn \
    && sudo npm install -g pnpm@9.6.0 \
    && sudo npm install -g @metaplex-foundation/amman \
    && sudo rm -rf /var/lib/apt/lists/*

# Arguments for version control - placing them right before use
ARG RUST_VERSION
ARG SOLANA_VERSION
ARG ANCHOR_VERSION

# Install Rust - this layer changes when RUST_VERSION changes
RUN echo "Installing Rust ${RUST_VERSION}" && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION}
ENV PATH="/home/developer/.cargo/bin:${PATH}"

# Install Solana CLI - this layer changes when SOLANA_VERSION changes
RUN echo "Installing Solana ${SOLANA_VERSION}" && \
    sh -c "$(curl -sSfL https://release.solana.com/v${SOLANA_VERSION}/install)" \
    && export PATH="/home/developer/.local/share/solana/install/active_release/bin:$PATH"
ENV PATH="/home/developer/.local/share/solana/install/active_release/bin:${PATH}"

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
RUN solana config set --url http://127.0.0.1:8899

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
