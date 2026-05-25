## 2026-05-25 — Zero-code restructure

- Removed `shared/` directory — contents redistributed:
  - `shared/skills/` → flat `skills/` at repo root
  - `shared/rules/` → `rules/` at repo root
  - `shared/templates/` → merged into workspace `templates/`
- Removed all shell scripts (`install.sh`, `install.ps1`, `get.sh`, `get.ps1`) — install is now 100% agentic
- Added `skills/install/SKILL.md` — agentic install skill (replaces install.sh)
- Added `skills/setup/SKILL.md` — guided setup with sub-commands:
  - `/setup:about` → `context/about-me.md`
  - `/setup:voice` → `context/voice-and-style.md`
  - `/setup:anti-style` → `context/anti-ai-writing-style.md`
  - `/setup:working-rules` → `context/working-rules.md`
- Added `skills/memory-management/SKILL.md` — two-tier memory system (adapted from Anthropic productivity plugin)
- Added `skills/task-management/SKILL.md` — markdown task tracking (adapted from Anthropic productivity plugin)
- Renamed `workspaces/example/` → `workspaces/my-assistant/` — self-contained template workspace
- Renamed workspace context files to canonical names:
  - `context/style.md` → `context/voice-and-style.md`
  - `context/rules.md` → `context/working-rules.md`
  - added `context/anti-ai-writing-style.md`
- All 9 skills now embedded in `workspaces/my-assistant/.claude/skills/`

## 2026-05-24

- Initial public spec and multi-workspace layout
- Shared skills: `/done`, `/standup`, `/weekly-review`, `/todo-add`, `/todo-review`
