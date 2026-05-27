---
name: install
description: Set up my-assistant on this machine. Activate when the user says "install",
  "set up my assistant", "clone this repo", or pastes the install prompt from the README.
---

# Install

Sets up my-assistant on a new machine — no shell scripts required.

## When to activate

User provides the install prompt from the README, or asks to install / set up my-assistant.

## Step 1 — Clone the repo

```bash
git clone https://github.com/daddia/my-assistant ~/my-assistant
```

If `~/my-assistant` already exists, ask the user where to clone instead.

## Step 2 — Create the workspace

The template workspace is at `workspaces/my-assistant/`. Copy it to a workspace with the user's chosen name (default: `personal-assistant`):

```bash
cp -R ~/my-assistant/workspaces/my-assistant ~/my-assistant/workspaces/personal-assistant
```

## Step 3 — Create runtime directories

```bash
mkdir -p ~/my-assistant/workspaces/personal-assistant/output/daily
mkdir -p ~/my-assistant/workspaces/personal-assistant/output/weekly
mkdir -p ~/my-assistant/workspaces/personal-assistant/output/drafts
mkdir -p ~/my-assistant/workspaces/personal-assistant/inbox
mkdir -p ~/my-assistant/workspaces/personal-assistant/projects
mkdir -p ~/my-assistant/workspaces/personal-assistant/memory
touch ~/my-assistant/workspaces/personal-assistant/MEMORY.md
touch ~/my-assistant/workspaces/personal-assistant/TASKS.md
```

## Step 4 — Enable plugins

This repo ships two Claude Code plugins via the **adk** marketplace (`.claude-plugin/marketplace.json`):

- **assistant** — memory (`/assistant:memory`)
- **productivity** — start, update, task and memory management (`/productivity:start`, `/productivity:update`, …)

When you open this repo in Claude Code, trust the folder and accept the marketplace prompt to enable both plugins. Defaults are in `.claude/settings.json`.

Repo-level skills `/install` and `/setup` live in `.claude/skills/` at the repo root. Claude Code discovers them from workspace subdirectories automatically (parent walk to repo root).

**Do not** copy skills into `workspaces/<name>/.claude/skills/`. Workspace folders hold context and runtime files only.

## Step 5 — Tell the user what's ready

Report:
- Where the workspace is
- How to open it in Cowork: Settings → folder → select the workspace path
- What to do next: run `/setup` (Claude Code at repo root) to configure context files
- Available plugins: **assistant** (memory) and **productivity** (start, update)
- Repo skills: `/install`, `/setup` at repo root `.claude/skills/`

**Do not** attempt to open Cowork, modify system settings, or write to any path outside the workspace.
