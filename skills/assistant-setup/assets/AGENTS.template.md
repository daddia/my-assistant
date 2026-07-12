# My Assistant working folder

This is [full name]'s personal data directory for the My Assistant plugin. This is not a software project.

## Layout
- `config/*` — configuration files
- `config/profile.md` — identity, voice, autonomy (read first)
- `policies/*.policy.md` — email and calendar rules (read alongside profile)
- `scheduled/*.yaml` — job heartbeat state (generated; don't hand-edit)
- `TASKS.md`, `memory/`, `drafts/` — tasks, deep memory, output

## Agent rules
- Read profile + policies directly; this file does not override them.
- Never send, book, buy, or delete without explicit sign-off.
- Prefer `/assistant:setup` for profile/policy changes.

## Memory
(hot-cache tables go here when populated)
