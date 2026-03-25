# Armature

> The internal skeleton that gives a robot its structure.
> Armature gives Claude Code a safe, isolated frame to operate in.

Run Claude Code with full permissions inside a Docker container, tied to git worktrees. Claude gets full autonomy. Your host stays safe.

## Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop/)
- Git
- A Claude Code authentication token (see [Authentication](#authentication))

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

4. Set up authentication (see below)

## Authentication

Claude Code uses OAuth tokens stored in the macOS Keychain, which can't be mounted into a container. To authenticate inside the container, generate a long-lived token:

```bash
claude setup-token
```

Then add it to your shell profile (e.g. `~/.zshenv`):

```bash
export CLAUDE_CODE_OAUTH_TOKEN=<your-token>
```

Armature will automatically pass this into the container. This works with team/org accounts.

## Usage

### Recommended: use with git worktrees

The recommended way to use armature is with git worktrees. Pass a branch name and armature creates a worktree and launches Claude in it. This keeps Claude's work isolated from your main checkout — you can keep working on `main` while Claude works on a feature branch.

```bash
cd ~/code/my-project

# Create a worktree for a feature branch and launch Claude
armature my-feature

# Launch with a task
armature my-feature "Refactor auth module per docs/auth-rfc.md"

# Launch with a prompt file
armature my-feature --prompt tasks.md

# Launch in the background
armature my-feature "Implement feature X" -d
```

The worktree is created as a sibling directory (e.g. `~/code/my-project-my-feature`). Changes Claude makes appear there in real time.

### Without worktrees

You can also run armature from any git directory without creating a worktree. Just run `armature run` with no arguments — it mounts the current directory:

```bash
cd ~/code/my-project
git checkout feature/login

# Launch Claude against the current directory and branch
armature run
```

This works, but be aware that Claude is working directly in your checkout. If you want to keep working in the same repo while Claude runs, worktrees are the safer option.

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

## What's in the base image

The `armature:v1` image is deliberately lean — based on `node:22-bookworm-slim` with:

- Claude Code
- Git (read-only — commits and pushes are blocked)
- jq, ripgrep
- curl

## Custom images

Extend the base image with tools your project needs:

```dockerfile
FROM armature:v1

USER root
RUN apt-get update && apt-get install -y fzf gh && rm -rf /var/lib/apt/lists/*
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/
USER node
```

Build it:

```bash
docker build -t my-team-armature:v1 .
```

Then tell armature to use it. In order of precedence:

1. **Per-project** — add `.armature.json` to your repo root:
   ```json
   {
     "image": "my-team-armature:v1"
   }
   ```

2. **Global** — set an env var:
   ```bash
   export ARMATURE_IMAGE=my-team-armature:v1
   ```

3. **Default** — `armature:v1`

See `examples/Dockerfile` for a full example with gh, fzf, uv, and asdf.

## How it works

- Each container runs Claude with `--dangerously-skip-permissions` in an isolated environment
- Your project worktree is bind-mounted to `/workspace`
- Git commits and pushes are blocked inside the container — review and push from your host
- Your `~/.claude` config is mounted for auth, settings, MCP servers, and skills
- Symlinked directories in `~/.claude` (hooks, skills, commands) are automatically detected and mounted
- Git worktrees isolate work per-branch — Claude can't affect your main branch

## Hooks

Armature sets `ARMATURE=1` inside the container. If you have hooks that only make sense on the host (e.g. syncing sessions to a local vault, writing to host-only paths), guard them:

```json
{
  "type": "command",
  "command": "[ -n \"$ARMATURE\" ] && exit 0; your-host-only-command"
}
```

This makes the hook silently skip inside the container and run normally on your host.
