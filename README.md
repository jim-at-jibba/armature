# Armature

> The internal skeleton that gives a robot its structure.
> Armature gives Claude Code a safe, isolated frame to operate in.

Run Claude Code with full permissions inside a Docker container, tied to git worktrees. Claude gets full autonomy. Your host stays safe.

## Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop/)
- Git

## Setup

1. Clone this repo:
   ```bash
   git clone https://github.com/jim-at-jibba/armature.git && cd armature
   ```

2. Build the image:
   ```bash
   docker build -t armature:v1 .
   ```

3. Add `armature` to your PATH:
   ```bash
   ln -s "$(pwd)/armature" /usr/local/bin/armature
   ```

## Usage

### Launch a container

From any git repository:

```bash
# Create a worktree and launch Claude interactively
armature my-feature

# Launch with a task for Claude
armature my-feature "Refactor auth module per docs/auth-rfc.md"

# Launch with a prompt file
armature my-feature --prompt tasks.md

# Launch in the background
armature my-feature "Implement feature X" -d
```

### Attach to a running container

```bash
# From inside the worktree directory
cd ../my-project-my-feature
armature attach

# Or by branch name from anywhere
armature attach my-feature
```

### Manage containers

```bash
armature ls              # list running containers
armature stop my-feature # stop a container
armature rm my-feature   # stop and remove
```

### Watch Claude work in real time

Since the worktree is bind-mounted, you can run Metro (or any dev server) on your host while Claude works:

```bash
# Terminal 1: Claude works in the container
armature my-feature "Implement the new login screen"

# Terminal 2: Watch changes live
cd ../my-project-my-feature
npx react-native start
```

## What's in the image

The `armature:v1` image is based on `node:22-bookworm-slim` with:

- Claude Code
- asdf (version manager)
- gh (GitHub CLI)
- jq, ripgrep, fzf
- uv (Python package manager)
- Git

## How it works

- Each container runs Claude with `--dangerously-skip-permissions` in an isolated environment
- Your project worktree is bind-mounted to `/workspace`
- Your `~/.claude` config is mounted for auth, settings, MCP servers, and skills
- Git worktrees isolate work per-branch — Claude can't affect your main branch
- No remote git access from the container — review and push from your host
