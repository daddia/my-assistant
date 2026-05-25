---
name: memory-management
description: Maintain and update the assistant's working memory about people, places,
  projects, and terminology the user mentions. Activate whenever the user introduces
  a new person, mentions a recurring project, uses shorthand that isn't explained,
  or asks "do you remember...?". Adapted from the Anthropic knowledge-work productivity
  plugin.
---

# Memory management

Two-tier memory so the assistant always knows your world — without asking the same question twice.

## Tier 1 — Working memory (`CLAUDE.md`)

Short, always-loaded context. Lives in `CLAUDE.md` in the workspace root. Keep it under 80 lines.

Stores:
- Household members (name, relationship, key detail)
- Recurring projects with their short names
- Key places (home, school, GP, etc.)
- Your most-used shorthand

## Tier 2 — Deep memory (`memory/` directory)

Longer notes that Claude loads when relevant. One file per category.

| File | Contents |
|------|----------|
| `memory/people.md` | Extended profiles — relationships, preferences, important dates |
| `memory/places.md` | Addresses, hours, notes |
| `memory/projects.md` | Active and background projects — goals, status, key people |
| `memory/recurring.md` | Regular commitments (school schedule, bin nights, subscriptions) |
| `memory/references.md` | Things to remember: doctors, emergency contacts, account notes |

## When to update

**Working memory (CLAUDE.md):**
Update immediately when the user introduces a new regular person, project, or place. Keep it brief — name, relationship, one detail.

**Deep memory:**
Update after a task when you learn something that would be useful for the next task. Don't interrupt the current task to update.

## How to update

```
[add to CLAUDE.md] — Jonathan's brother: Mark, lives in Melbourne
[add to memory/people.md] — Mark Daddia, Jonathan's brother. Lives Melbourne. Call for family events.
```

Tell the user after updating: "Saved — I'll remember [x] from now on."

## When to retrieve

Load memory files at session start and whenever a task involves a person, place, or project. Surface relevant memory without being asked.

Example: If the user says "check if Mark is free this weekend", load `memory/people.md` without being asked to look up Mark's details.

## Memory hygiene

- Don't store sensitive credentials, passwords, or financial account details.
- Don't store speculation — only things the user has confirmed.
- Review and prune stale entries when the user runs `/update`.
- If memory contradicts new information, ask before overwriting.
