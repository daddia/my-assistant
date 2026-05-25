# Personal Assistant (repo root)

This repo manages **multiple Cowork workspaces**. The root `CLAUDE.md` applies when Claude Code is run from the repo root — not when Cowork is pointed at a workspace folder.

## For Cowork

Point Cowork at a workspace subdirectory:

- **Demo:** `workspaces/example/`
- **Personal (local):** `workspaces/personal-assistant/`

Each workspace has its own `CLAUDE.md` and `context/` files.

## For Claude Code at repo root

- Product spec: `docs/product/spec.md`
- Research: `docs/product/research.md`
- Shared skills: `shared/skills/`
- Do not commit personal data from `workspaces/personal-assistant/`

## Setup

```bash
./scripts/install.sh
```

See [README.md](README.md).
