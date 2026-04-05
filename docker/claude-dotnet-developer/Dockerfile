# Base image: .NET 10 SDK (ARM64 compatible)
FROM mcr.microsoft.com/dotnet/sdk:10.0

# Labels for organizational transparency
LABEL org.opencontainers.image.source="https://github.com/baranacikgoz/homelab-infra"
LABEL org.opencontainers.image.description="Headless Claude AI Developer for .NET"

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install foundational dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    gnupg \
    software-properties-common \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Node.js (needed for Claude Code)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# 3. Install GitHub CLI (gh) & Docker CLI
RUN mkdir -p -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | tee /etc/apt/keyrings/docker.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    gh \
    docker-ce-cli \
    docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# 4. Install Claude Code (global install)
RUN npm install -g @anthropic-ai/claude-code

# 5. Setup Security: ai-runner non-root user
# We use UID 1001 for non-root compliance
RUN useradd -m -u 1001 -s /bin/bash ai-runner
USER ai-runner
WORKDIR /home/ai-runner/work

# 6. Environment setup
# Ensure npm global bins are in path
ENV PATH="/usr/local/bin:$PATH"
# Point Docker CLI to the sidecar daemon
ENV DOCKER_HOST=tcp://localhost:2375

# Default command: show versions to verify installation
CMD ["claude", "--version"]
