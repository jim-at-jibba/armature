# Armature

> The internal skeleton that gives a robot its structure.
> Armature gives Claude Code a safe, isolated frame to operate in.

Run Claude Code with full permissions inside a [Docker Sandbox](https://docs.docker.com/ai/sandboxes/), tied to git worktrees. Claude gets full autonomy. Your host stays safe.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) with Sandbox support
- Git

## Setup

1. Clone this repo:
   ```bash
   git clone <repo-url> && cd armature
   ```

2. Build the template image:
   ```bash
   docker build -t armature:v1 .
   ```

3. Add `armature` to your PATH:
   ```bash
   ln -s "$(pwd)/armature" /usr/local/bin/armature
   ```

## Usage

### Launch a sandbox

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

### Attach to a running sandbox

```bash
# From inside the worktree directory
cd ../my-project-my-feature
armature attach

# Or by branch name from anywhere
armature attach my-feature
```

### Manage sandboxes

```bash
armature ls              # list running sandboxes
armature stop my-feature # stop a sandbox
armature rm my-feature   # stop and remove
```

### Watch Claude work in real time

Since the worktree syncs bidirectionally, you can run Metro (or any dev server) on your host while Claude works:

```bash
# Terminal 1: Claude works in the sandbox
armature my-feature "Implement the new login screen"

# Terminal 2: Watch changes live
cd ../my-project-my-feature
npx react-native start
```

## What's in the template

The `armature:v1` image extends `docker/sandbox-templates:claude-code` with:

- asdf (version manager)
- gh (GitHub CLI)
- jq, ripgrep, fzf
- uv (Python package manager)

The base image includes: Claude Code, Git, Node.js, Python, Go, Docker CLI, build-essential.

## How it works

- Each sandbox runs in a Docker Sandbox microVM — isolated filesystem, Docker daemon, and network
- Claude runs with `--dangerously-skip-permissions` inside the sandbox
- Your `~/.claude` config is mounted read-only (auth, settings, MCP servers, skills)
- Git worktrees isolate work per-branch — Claude can't affect your main branch
- No remote git access from the sandbox — review and push from your host
