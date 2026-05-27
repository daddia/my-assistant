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

## Step 4 — Install plugins

The workspace is pre-configured to use the `my-assistant` marketplace. Open the workspace in Cowork, then install both plugins:

```
/plugin install assistant@my-assistant
/plugin install productivity@my-assistant
```

Cowork will fetch the plugins directly from `daddia/my-assistant` on GitHub — no local file copying required. Skills stay canonical in the repo and update automatically when the plugins are refreshed.

If Cowork hasn't registered the marketplace yet, add it first:

```
/plugin marketplace add daddia/my-assistant
```

## Step 5 — Tell the user what's ready

Report:
- Where the workspace is
- How to open it in Cowork: Settings → folder → select the workspace path
- What to do next: install plugins (Step 4), then run `/setup` to configure my-assistant
- Available plugins: **assistant** (`/setup`, memory) and **productivity** (`/start`, `/update`)

**Do not** attempt to open Cowork, modify system settings, or write to any path outside the workspace.
