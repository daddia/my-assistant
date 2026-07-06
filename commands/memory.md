---
description: Add people, projects, and terms to memory — or prune stale entries
  from the hot cache.
argument-hint: "[add|prune]"
---

Parse `$ARGUMENTS` for the verb. Default to **add** when empty or unrecognized.

## add (default)

Capture durable context. Read and follow `skills/memory-management/SKILL.md`.

Save people, projects, acronyms, nicknames, or terms the user introduces. Use remaining arguments or ask what to remember if none provided. Update `CLAUDE.md` (hot cache) and `memory/` as appropriate; propose profile updates for VIPs. Tell the user what was saved — never store credentials.

## prune

Prune stale or contradictory memory entries. Read and follow `skills/memory-management/SKILL.md`.

Review `CLAUDE.md` for entries that are outdated, contradictory, or no longer active. Demote completed projects and infrequent contacts to `memory/` only; propose removals with user confirmation before deleting anything. For a full weekly prune, `/assistant:review` also covers memory.
