# Example: extend the base armature image with additional tools
FROM armature:v1

USER root

# Add system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    fzf \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Add gh CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | tee /usr/share/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Add uv (Python package manager)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Add asdf (version manager)
RUN git clone https://github.com/asdf-vm/asdf.git /opt/asdf --branch v0.14.1 \
    && echo '. /opt/asdf/asdf.sh' >> /etc/bash.bashrc \
    && echo '. /opt/asdf/asdf.sh' >> /etc/profile.d/asdf.sh

USER node
