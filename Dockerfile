FROM node:22-bookworm-slim

ARG CLAUDE_CODE_VERSION=latest

USER root

# Install system packages (minimal — extend via your own Dockerfile)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    ripgrep \
    jq \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Block git commit/push inside the container — changes should be committed from the host
RUN mkdir -p /etc/armature/git-hooks \
    && printf '#!/bin/sh\necho "armature: git commits are disabled — commit from your host" >&2\nexit 1\n' \
       > /etc/armature/git-hooks/pre-commit \
    && printf '#!/bin/sh\necho "armature: git push is disabled — push from your host" >&2\nexit 1\n' \
       > /etc/armature/git-hooks/pre-push \
    && chmod +x /etc/armature/git-hooks/* \
    && git config --system core.hooksPath /etc/armature/git-hooks

# Set up workspace and claude dirs for the node user (UID 1000)
RUN mkdir -p /workspace /home/node/.claude \
    && chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace
USER node
