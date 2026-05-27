---
name: memory-management
description: Two-tier memory for decoding shorthand, nicknames, and personal context.
  CLAUDE.md for working memory, memory/ for deep storage. Used by /start and /update.
user-invocable: false
---

# Memory management

Supports the productivity plugin's task and sync workflows. Works alongside the assistant plugin's `memory` skill.

## Architecture

```
CLAUDE.md          ← Working memory (~80 lines)
memory/
  people.md        ← Household, friends, contacts
  places.md        ← Addresses, hours, notes
  projects.md      ← Active projects and goals
  recurring.md     ← Regular commitments
  references.md    ← Doctors, emergency contacts (no credentials)
```

## Lookup flow

```
User: "remind me to pick up Sarah from netball"

1. Check CLAUDE.md → Sarah? ✓ daughter
2. Check memory/people.md → netball? ✓ Tuesdays 4pm
3. If not found → ask user, then save
```

## Adding memory

When the user confirms new information:
1. Add to `CLAUDE.md` if frequently used
2. Add detail to the appropriate `memory/` file
3. Tell the user: "Saved — I'll remember that."

## What not to store

- Passwords, PINs, or credentials
- Full financial account numbers
- Speculation or unconfirmed information

## Used by

- `/productivity:start` — bootstrap memory on first run
- `/productivity:update` — fill gaps found during task triage
- `/update --comprehensive` — suggest new memories from activity scan

See also: assistant plugin `memory` skill for day-to-day memory updates.
