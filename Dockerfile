FROM docker/sandbox-templates:claude-code

USER root

# Install system packages and gh CLI in a single apt layer
RUN apt-get update \
    && apt-get install -y fzf ripgrep \
    && mkdir -p -m 755 /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Install uv to a shared location
ENV UV_INSTALL_DIR=/usr/local/bin
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install asdf to a shared location accessible by agent user
RUN git clone https://github.com/asdf-vm/asdf.git /opt/asdf --branch v0.14.1 \
    && echo '. /opt/asdf/asdf.sh' >> /etc/bash.bashrc \
    && echo '. /opt/asdf/asdf.sh' >> /etc/profile.d/asdf.sh

USER agent
