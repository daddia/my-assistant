---
description: Bring the assistant up to date — triage tasks, refresh memory, surface
  follow-ups. Scopes tasks or memory; --all deep-scans connected sources.
argument-hint: "[tasks|memory] [--all]"
---

Parse `$ARGUMENTS` for scope and flags:

- **Default** (empty or unrecognized scope): full update — tasks + memory gaps + enrichment + follow-ups. No memory prune.
- **`tasks`**: tasks only — triage stale/overdue items; external sync when `~~tasks` connected; surface capture proposals from chat/paste.
- **`memory`**: memory only — decode gaps, enrichment, save confirmed entries, prune stale context.
- **`--all`**: comprehensive connector deep-scan (see below). Accept `--comprehensive` as a deprecated alias for `--all`.
- **`tasks --all`** or **`memory --all`**: scoped run plus connector scan for that leg only.

## Preflight

- **Profile & paths** — Resolve per `rules/paths.md`. If missing, note it and offer `/assistant:setup` or `/assistant:start`; update still works from the working folder.
- **Working folder** — Confirm `TASKS.md`, `memory/`, `AGENTS.md`, and queue locations. Note if the folder is read-only.
- **Connectors** — Detect `~~email`, `~~calendar`, `~~chat`, `~~drive`, `~~tasks` when `--all` or task sync is in scope. State which are available; skip missing connectors and note the gap.
- **Autonomy tier** — Read the configured tier from the profile (default: Tier 1 — Draft). Present each capture for confirmation — never auto-add. Draft-only: never send, book, or spend.

## Plan

Before executing, state the resolved scope and whether `--all` is active.

| Scope | Skills | Does |
|-------|--------|------|
| **Default** | `task-management`, `follow-up-tracking`, `memory-management` | Triage stale/overdue tasks; decode + enrich memory from tasks; surface cold follow-ups; save confirmed entries inline |
| **`tasks`** | `task-management` | Triage `TASKS.md`; external sync diff when `~~tasks` connected; surface action items from chat/paste — never auto-add |
| **`memory`** | `memory-management` | Decode gaps; task enrichment; save confirmed people/projects/terms; prune stale hot-cache entries with confirmation |
| **`--all` on default** | above + connector scan | Additionally deep-scan connectors for missed todos and new people/projects |
| **`tasks --all`** | `task-management` + connectors | Connector scan for action items not yet in `TASKS.md` |
| **`memory --all`** | `memory-management` + connectors | Connector scan for new people/projects not yet in memory |

## Default

Bring the assistant up to date. Read and follow `skills/task-management/SKILL.md`, `skills/follow-up-tracking/SKILL.md`, and `skills/memory-management/SKILL.md`.

1. **Triage** — stale/overdue tasks in To do, In progress, In review, and Blocked (present each — done? cancelled? blocked? reschedule?).
2. **Decode** — per-task entity checklist with ✓ / ? markers (`memory-management`).
3. **Enrich** — propose memory updates from task links, status changes, relationships, deadlines (`memory-management` — confirm each).
4. **Follow-ups** — surface cold threads via `follow-up-tracking`; cross-check **Blocked** in `TASKS.md`.
5. **Gaps** — save confirmed memory entries inline — never auto-add. Do **not** prune memory on the default run.

For task-list-only work, `/assistant:tasks review` or `/assistant:tasks sync` are narrower entry points.

## tasks

Tasks-only update. Read and follow `skills/task-management/SKILL.md`.

Triage stale/overdue items in `TASKS.md`. When `~~tasks` is connected, run the external sync diff table. Surface action items from the current conversation or pasted content; offer to capture each — never auto-add. Does not touch memory enrichment or follow-ups.

With **`--all`**: additionally deep-scan connectors for action items not yet in `TASKS.md` (use report template below).

## memory

Memory-only update. Read and follow `skills/memory-management/SKILL.md`.

Decode entities from tasks, chat, or pasted content against `AGENTS.md` and `memory/` (checklist format). Run task enrichment proposals. Surface gaps; save confirmed people, projects, acronyms, or terms inline. **Prune** stale or contradictory hot-cache entries — demote completed projects and infrequent contacts; propose removals with confirmation before deleting anything. Propose profile updates for VIPs; never write `profile.md` without approval.

Explicit capture also works in chat ("remember that Todd = …") — the memory-management skill auto-fires without a slash command.

With **`--all`**: additionally deep-scan connectors for new people/projects not yet in memory (confidence-tiered proposals).

## --all

Comprehensive update — add `--all` to the default run or to a scoped run.

Deep-scan available connectors (`~~email`, `~~calendar`, `~~chat`, `~~drive`, `~~tasks`) for content relevant to the active scope. Present each proposed task or memory entry for the user to confirm — never auto-add. Skip any missing connector and note the gap.

**Default + `--all`:** runs the full update (tasks + memory gaps + enrichment + follow-ups) plus connector deep-scan.

### Report templates (`--all`)

**Possible missing tasks** — compare activity against `TASKS.md`:

```
## Possible missing tasks

From your activity, these look like todos you haven't captured:

1. From chat (18 Jan):
   "I'll send the updated mockups by Friday"
   → Add to TASKS.md (To do)?

2. From meeting "Phoenix Standup" (17 Jan):
   Recurring meeting but no Phoenix tasks in To do / In progress
   → Anything needed here?

3. From email (16 Jan):
   "I'll review the API spec this week"
   → Add to TASKS.md?
```

**New people / projects / cleanup** — use confidence-tiered tables from `skills/memory-management/SKILL.md`.

## Verification

- Re-read `TASKS.md`, `memory/`, `AGENTS.md`, and any follow-up drafts — confirm changes match the plan and scope.
- Confirm nothing was sent, booked, deleted, or auto-added without explicit approval.
- Surface connector errors, partial scans, or autonomy-tier blocks clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: update | update tasks | update memory | update --all (etc.)
- **Status**: success | partial | failed
- **Details**: scope, tasks triaged/synced, enrichment proposed, follow-ups surfaced, memory saved/pruned, connector mode
```

## Next Steps

- Run `/assistant:tasks review` for interactive task triage only.
- Run `/assistant:email review` for follow-ups only.
- Run `/assistant:update memory` for a memory-only pass (includes prune).
- Run `/assistant:report` for a full weekly pass.
