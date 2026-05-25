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
mkdir -p ~/assistant/workspaces/personal-assistant/memory
touch ~/assistant/workspaces/personal-assistant/MEMORY.md
touch ~/assistant/workspaces/personal-assistant/TASKS.md
```

## Step 4 — Install plugin skills

Copy skills from both plugins into the workspace:

```bash
ASSISTANT=~/assistant/skills/assistant/skills
PRODUCTIVITY=~/assistant/skills/productivity/skills
DEST=~/assistant/workspaces/personal-assistant/.claude/skills

mkdir -p "$DEST"
cp -R "$ASSISTANT"/* "$DEST"/
cp -R "$PRODUCTIVITY"/* "$DEST"/
```

## Step 5 — Tell the user what's ready

Report:
- Where the workspace is
- How to open it in Cowork: Settings → folder → select the workspace path
- What to do next: run `/setup` to configure my-assistant
- Available plugins: **assistant** (install, setup, memory) and **productivity** (start, update)

**Do not** attempt to open Cowork, modify system settings, or write to any path outside the workspace.
