FROM node:22-bookworm-slim

ARG CLAUDE_CODE_VERSION=latest

USER root

# Install system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    fzf \
    ripgrep \
    jq \
    procps \
    sudo \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Install gh CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | tee /usr/share/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Install asdf
RUN git clone https://github.com/asdf-vm/asdf.git /opt/asdf --branch v0.14.1 \
    && echo '. /opt/asdf/asdf.sh' >> /etc/bash.bashrc \
    && echo '. /opt/asdf/asdf.sh' >> /etc/profile.d/asdf.sh

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Use existing node user (UID 1000), set up workspace and claude dirs
RUN mkdir -p /workspace /home/node/.claude \
    && chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace
USER node
