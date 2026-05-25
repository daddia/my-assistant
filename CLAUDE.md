# daddia-assistant

Manages **multiple Cowork workspaces**. This root `CLAUDE.md` applies when Claude Code is run from the repo root — not when Cowork is pointed at a workspace folder.

## For Cowork

Point Cowork at a workspace subdirectory:

- **Template:** `workspaces/my-assistant/`
- **Personal (local):** `workspaces/personal-assistant/`

Each workspace has its own `CLAUDE.md` and `context/` files.

## For Claude Code at repo root

- Product spec: `docs/product/spec.md`
- Research: `docs/product/research.md`
- Skills: `skills/` (all shared skills live here)
- Rules: `rules/` (shared behaviour rules)
- Do not commit personal data from `workspaces/personal-assistant/`

## Install (agentic)

When a user asks to install or set up a workspace, read and follow `skills/install/SKILL.md`.

## Setup (agentic)

When a user runs `/setup` or asks to configure their workspace, read and follow `skills/setup/SKILL.md`.
