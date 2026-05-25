---
name: install
description: Set up a daddia-assistant workspace on this machine. Activate when the
  user says "install", "set up my assistant", "clone this repo", or pastes the install
  prompt from the README.
---

# Install

Sets up the workspace on a new machine — no shell scripts required.

## When to activate

User provides the install prompt from the README, or asks to install / set up the assistant.

## Step 1 — Clone the repo

```bash
git clone https://github.com/daddia/assistant ~/assistant
```

If `~/assistant` already exists, ask the user where to clone instead.

## Step 2 — Create the workspace

The template workspace is at `workspaces/my-assistant/`. Copy it to a workspace with the user's chosen name (default: `personal-assistant`):

```bash
cp -R ~/assistant/workspaces/my-assistant ~/assistant/workspaces/personal-assistant
```

## Step 3 — Create runtime directories

```bash
mkdir -p ~/assistant/workspaces/personal-assistant/output/daily
mkdir -p ~/assistant/workspaces/personal-assistant/output/weekly
mkdir -p ~/assistant/workspaces/personal-assistant/output/drafts
mkdir -p ~/assistant/workspaces/personal-assistant/inbox
mkdir -p ~/assistant/workspaces/personal-assistant/projects
touch ~/assistant/workspaces/personal-assistant/MEMORY.md
```

## Step 4 — Link shared skills (optional, for power users)

The workspace already contains embedded copies of all skills in `.claude/skills/`. If the user wants to share skills across multiple workspaces instead, symlink from `skills/` at the repo root:

```bash
for skill in ~/assistant/skills/*/; do
  name=$(basename "$skill")
  ln -sf "$skill" ~/assistant/workspaces/personal-assistant/.claude/skills/"$name"
done
```

Skip this step if the user has a single workspace.

## Step 5 — Tell the user what's ready

Report:
- Where the workspace is
- How to open it in Cowork: Settings → folder → select the workspace path
- What to do next: run `/setup` to configure the assistant

**Do not** attempt to open Cowork, modify system settings, or write to any path outside the workspace.
