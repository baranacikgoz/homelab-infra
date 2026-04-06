# STAGE 1: Extract .NET 10.0 SDK from the official Microsoft image
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS dotnet-sdk

# STAGE 2: Base image MUST be the official GitHub Actions Runner
FROM ghcr.io/actions/actions-runner:latest

# Labels for organizational transparency
LABEL org.opencontainers.image.source="https://github.com/baranacikgoz/homelab-infra"
LABEL org.opencontainers.image.description="Headless Claude AI Developer for .NET 10"

# Switch to root to install deep system dependencies
USER root

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install foundational dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    gnupg \
    wget \
    make \
    build-essential \
    software-properties-common \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. Inject .NET 10.0 SDK from Stage 1
COPY --from=dotnet-sdk /usr/share/dotnet /usr/share/dotnet
# Create a symlink to make dotnet globally available
RUN ln -s /usr/share/dotnet/dotnet /usr/local/bin/dotnet

# 3. Install Node.js (needed for Claude Code)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# 4. Install GitHub CLI (gh) & Docker CLI
RUN mkdir -p -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    gh \
    docker-ce-cli \
    docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# 5. Install Claude Code (global install)
RUN npm install -g @anthropic-ai/claude-code

# 6. Environment setup
ENV PATH="/usr/local/bin:$PATH"
ENV DOCKER_HOST=unix:///var/run/dind/docker.sock

# Switch back to the required 'runner' user provided by the base image
USER runner
WORKDIR /home/runner

# No CMD is needed. The base image automatically executes the runner startup script.
