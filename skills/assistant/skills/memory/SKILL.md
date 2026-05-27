---
name: memory
description: Maintain my-assistant's working memory about people, places, projects,
  and terminology. Activate when the user introduces someone new, mentions a recurring
  project, uses unexplained shorthand, or asks "do you remember...?".
user-invocable: false
---

# Memory

Two-tier memory so my-assistant always knows your world — without asking the same question twice.

## Tier 1 — Working memory (`CLAUDE.md`)

Short, always-loaded context. Keep under 80 lines.

Stores:
- Household members (name, relationship, key detail)
- Recurring projects with their short names
- Key places (home, school, GP, etc.)
- Your most-used shorthand

## Tier 2 — Deep memory (`memory/` directory)

| File | Contents |
|------|----------|
| `memory/people.md` | Extended profiles — relationships, preferences, important dates |
| `memory/places.md` | Addresses, hours, notes |
| `memory/projects.md` | Active and background projects — goals, status, key people |
| `memory/recurring.md` | Regular commitments (school schedule, bin nights, subscriptions) |
| `memory/references.md` | Doctors, emergency contacts, account notes (no credentials) |

## When to update

**Working memory:** Update immediately when the user introduces a new regular person, project, or place.

**Deep memory:** Update after a task when you learn something useful for next time. Don't interrupt the current task.

Tell the user after updating: "Saved — I'll remember [x] from now on."

## When to retrieve

Load memory files at session start and whenever a task involves a person, place, or project. Surface relevant memory without being asked.

## Memory hygiene

- Don't store passwords, credentials, or financial account numbers.
- Don't store speculation — only confirmed facts.
- Review and prune stale entries when the user runs `/productivity:update`.
- If memory contradicts new information, ask before overwriting.
