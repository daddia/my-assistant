---
description: Add people, projects, and terms to memory — or prune stale entries
  from the hot cache.
argument-hint: "[add|prune]"
---

Parse `$ARGUMENTS` for the verb. Default to **add** when empty or unrecognized.

## Preflight

- **Profile** — Read `~/.claude/plugins/config/my-assistant/profile.md` (or `profile.md` in the open workspace). If missing, note it and offer `/assistant:setup`; memory still works in the working folder.
- **Working folder** — Confirm where `CLAUDE.md`, `memory/`, and any `review-queue/index.yaml` items will be written. Note if the folder is read-only.
- **Connectors** — Not required; note if `~~notes` or `~~drive` could enrich context.
- **Autonomy tier** — Read the configured tier from the profile (default: Tier 1 — Draft). Propose profile updates for VIPs; never write `profile.md` without approval.

## Plan

- **add** — Run `skills/memory-management/SKILL.md`. Save people, projects, acronyms, or terms to `CLAUDE.md` and `memory/`; propose profile updates for VIPs.
- **prune** — Run `skills/memory-management/SKILL.md`. Review stale or contradictory entries; propose demotions and removals with user confirmation before deleting anything.

## add (default)

Capture durable context. Read and follow `skills/memory-management/SKILL.md`.

Save people, projects, acronyms, nicknames, or terms the user introduces. Use remaining arguments or ask what to remember if none provided. Update `CLAUDE.md` (hot cache) and `memory/` as appropriate; propose profile updates for VIPs. Tell the user what was saved — never store credentials.

## prune

Prune stale or contradictory memory entries. Read and follow `skills/memory-management/SKILL.md`.

Review `CLAUDE.md` for entries that are outdated, contradictory, or no longer active. Demote completed projects and infrequent contacts to `memory/` only; propose removals with user confirmation before deleting anything. For a full weekly prune, `/assistant:review` also covers memory.

## Verification

- Re-read `CLAUDE.md` and `memory/` changes — confirm they match the plan.
- Confirm nothing was deleted without explicit approval.
- Surface read-only folder errors or conflicting entries clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: memory add | memory prune
- **Status**: success | partial | failed
- **Details**: entries added/pruned/demoted, profile-diff proposals
```

## Next Steps

- Run `/assistant:review` for a full weekly memory prune.
- Run `/assistant:update` to sync memory gaps from recent activity.
- Approve any `profile-diff` queue items for VIP updates.
