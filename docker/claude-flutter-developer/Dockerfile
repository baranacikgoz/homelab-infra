# Base image MUST be the official GitHub Actions Runner
FROM ghcr.io/actions/actions-runner:latest

# Labels for organizational transparency
LABEL org.opencontainers.image.source="https://github.com/baranacikgoz/homelab-infra"
LABEL org.opencontainers.image.description="Headless Claude AI Developer for Flutter/Dart"

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
    unzip \
    xz-utils \
    zip \
    libpcre3 \
    libglu1-mesa \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Node.js (needed for Claude Code)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# 3. Install GitHub CLI (gh) & Docker CLI
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

# 4. Install Flutter SDK
ENV FLUTTER_HOME=/usr/local/flutter
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME
ENV PATH="$FLUTTER_HOME/bin:$PATH"

# Run pre-cache to prepare the ARM64 binaries
RUN git config --global --add safe.directory /usr/local/flutter \
    && flutter doctor \
    && flutter precache

# 5. Install Claude Code (global install)
RUN npm install -g @anthropic-ai/claude-code

# 6. Environment setup
ENV PATH="/usr/local/bin:$PATH"
ENV DOCKER_HOST=tcp://localhost:2375

# Switch back to the required 'runner' user provided by the base image
USER runner
WORKDIR /home/runner

# No CMD is needed. The base image automatically executes the runner startup script.
