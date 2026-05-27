# AI Assistant ADK

**Agent Development Kit** for building provider-agnostic AI assistants. This repo manages **multiple agent workspaces** (e.g. personal, work). This root `CLAUDE.md` applies when Claude Code is run from the repo root — not when Cowork is pointed at a workspace folder.

## For Cowork

Point Cowork at a workspace subdirectory:

- **Template:** `workspaces/my-assistant/`
- **Personal (local):** `workspaces/personal-assistant/`

Each workspace has its own `CLAUDE.md`, `context/` files, and `.claude/settings.json` (plugins enabled via **adk** marketplace at repo root).

## For Claude Code at repo root

- User guide: `docs/guide/`
- Repo skills: `.claude/skills/` (`/install`, `/setup`)
- Plugins: `skills/assistant/`, `skills/productivity/` (enabled via `.claude/settings.json`)
- Rules: `rules/`
- Do not commit personal data from `workspaces/personal-assistant/`

## Install (agentic)

When a user asks to install or set up my-assistant, read and follow `.claude/skills/install/SKILL.md`.

## Setup (agentic)

When a user runs `/setup` or asks to configure their workspace, read and follow `.claude/skills/setup/SKILL.md`.

## Productivity plugin (agentic)

When the user runs `/productivity:start`, `/productivity:update`, asks to triage tasks, manage `TASKS.md`, or sync memory in a workspace, read and follow the matching skill:

| Trigger | Skill file |
|---------|------------|
| `/productivity:start`, bootstrap tasks/memory | `skills/productivity/skills/start/SKILL.md` |
| `/productivity:update`, triage, comprehensive scan | `skills/productivity/skills/update/SKILL.md` |
| Task list operations | `skills/productivity/skills/task-management/SKILL.md` |
| Memory gaps during sync | `skills/productivity/skills/memory-management/SKILL.md` |

Run from the user's workspace folder (`workspaces/personal-assistant/` or similar). Connector categories: `skills/productivity/CONNECTORS.md`.

## Assistant plugin (agentic)

When the user asks about memory, `MEMORY.md`, or `memory/`, read and follow `skills/assistant/skills/memory/SKILL.md`.
