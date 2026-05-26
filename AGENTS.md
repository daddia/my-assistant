# AI Assistant ADK

**Agent Development Kit** for building provider-agnostic AI assistants. This repo manages **multiple agent workspaces** (e.g. personal, work). This root `CLAUDE.md` applies when Claude Code is run from the repo root — not when Cowork is pointed at a workspace folder.

## For Cowork

Point Cowork at a workspace subdirectory:

- **Template:** `workspaces/my-assistant/`
- **Personal (local):** `workspaces/personal-assistant/`

Each workspace has its own `CLAUDE.md` and `context/` files.

## For Claude Code at repo root

- User guide: `docs/guide/`
- Skills: `skills/assistant/`, `skills/productivity/`
- Rules: `rules/`
- Do not commit personal data from `workspaces/personal-assistant/`

## Install (agentic)

When a user asks to install or set up my-assistant, read and follow `skills/assistant/skills/install/SKILL.md`.

## Setup (agentic)

When a user runs `/setup` or asks to configure their workspace, read and follow `skills/assistant/skills/setup/SKILL.md`.
