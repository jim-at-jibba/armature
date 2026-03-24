FROM docker/sandbox-templates:claude-code

USER root

# Install system packages
RUN apt-get update && apt-get install -y \
    jq \
    fzf \
    && rm -rf /var/lib/apt/lists/*

# Install ripgrep
RUN curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep_14.1.1-1_amd64.deb \
    && dpkg -i ripgrep_14.1.1-1_amd64.deb \
    && rm ripgrep_14.1.1-1_amd64.deb

# Install gh CLI
RUN (type -p wget >/dev/null || apt-get install wget -y) \
    && mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install gh -y \
    && rm -rf /var/lib/apt/lists/*

# Install uv to a shared location
ENV UV_INSTALL_DIR=/usr/local/bin
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install asdf to a shared location accessible by agent user
RUN git clone https://github.com/asdf-vm/asdf.git /opt/asdf --branch v0.14.1 \
    && echo '. /opt/asdf/asdf.sh' >> /etc/bash.bashrc \
    && echo '. /opt/asdf/asdf.sh' >> /etc/profile.d/asdf.sh

USER agent
