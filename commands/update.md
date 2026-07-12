---
description: Bring the assistant up to date — triage tasks, refresh memory, surface
  follow-ups. Scopes tasks or memory; --all deep-scans connected sources.
argument-hint: "[tasks|memory] [--all]"
---

Parse `$ARGUMENTS` for scope and flags:

- **Default** (empty or unrecognized scope): full update — tasks + memory gaps + follow-ups. No memory prune.
- **`tasks`**: tasks only — triage stale/overdue items; surface capture proposals from chat/paste.
- **`memory`**: memory only — decode gaps, save confirmed entries, prune stale context.
- **`--all`**: comprehensive connector deep-scan (see below). Accept `--comprehensive` as a deprecated alias for `--all`.
- **`tasks --all`** or **`memory --all`**: scoped run plus connector scan for that leg only.

## Preflight

- **Profile & paths** — Resolve per `rules/paths.md`. If missing, note it and offer `/assistant:setup`; update still works from the working folder.
- **Working folder** — Confirm `TASKS.md`, `memory/`, `CLAUDE.md`, and queue locations. Note if the folder is read-only.
- **Connectors** — Detect `~~email`, `~~calendar`, `~~chat`, `~~drive` when `--all` (or `--comprehensive`) is set. State which are available; skip missing connectors and note the gap.
- **Autonomy tier** — Read the configured tier from the profile (default: Tier 1 — Draft). Present each capture for confirmation — never auto-add. Draft-only: never send, book, or spend.

## Plan

Before executing, state the resolved scope and whether `--all` is active.

| Scope | Skills | Does |
|-------|--------|------|
| **Default** | `task-management`, `follow-up-tracking`, `memory-management` | Triage stale/overdue tasks; surface cold follow-ups; decode entities against memory, save confirmed entries inline |
| **`tasks`** | `task-management` | Triage `TASKS.md`; surface action items from chat/paste — never auto-add |
| **`memory`** | `memory-management` | Decode gaps; save confirmed people/projects/terms; prune stale hot-cache entries with confirmation |
| **`--all` on default** | above + connector scan | Additionally deep-scan connectors for missed todos and new people/projects |
| **`tasks --all`** | `task-management` + connectors | Connector scan for action items not yet in `TASKS.md` |
| **`memory --all`** | `memory-management` + connectors | Connector scan for new people/projects not yet in memory |

## Default

Bring the assistant up to date. Read and follow `skills/task-management/SKILL.md`, `skills/follow-up-tracking/SKILL.md`, and `skills/memory-management/SKILL.md`.

Read `TASKS.md`, `memory/`, and `CLAUDE.md`. Triage stale/overdue tasks (present each — done? reschedule? Someday?). Surface follow-ups gone cold via `follow-up-tracking`. Decode task entities against memory; surface gaps and **save confirmed entries inline** — never auto-add. Do **not** prune memory on the default run.

For task-list-only work, `/assistant:tasks review` or `/assistant:tasks sync` are narrower entry points.

## tasks

Tasks-only update. Read and follow `skills/task-management/SKILL.md`.

Triage stale/overdue items in `TASKS.md`. Surface action items from the current conversation or pasted content; offer to capture each — never auto-add. Does not touch memory or follow-ups.

With **`--all`**: additionally deep-scan connectors for action items not yet in `TASKS.md`.

## memory

Memory-only update. Read and follow `skills/memory-management/SKILL.md`.

Decode entities from tasks, chat, or pasted content against `CLAUDE.md` and `memory/`. Surface gaps; save confirmed people, projects, acronyms, or terms inline. **Prune** stale or contradictory hot-cache entries — demote completed projects and infrequent contacts; propose removals with confirmation before deleting anything. Propose profile updates for VIPs; never write `profile.md` without approval.

Explicit capture also works in chat ("remember that Todd = …") — the memory-management skill auto-fires without a slash command.

With **`--all`**: additionally deep-scan connectors for new people/projects not yet in memory.

## --all

Comprehensive update — add `--all` to the default run or to a scoped run.

Deep-scan available connectors (`~~email`, `~~calendar`, `~~chat`, `~~drive`) for content relevant to the active scope. Present each proposed task or memory entry for the user to confirm — never auto-add. Skip any missing connector and note the gap.

**Default + `--all`:** runs the full update (tasks + memory gaps + follow-ups) plus connector deep-scan for missed todos and new people/projects.

## Verification

- Re-read `TASKS.md`, `memory/`, `CLAUDE.md`, and any follow-up drafts — confirm changes match the plan and scope.
- Confirm nothing was sent, booked, deleted, or auto-added without explicit approval.
- Surface connector errors, partial scans, or autonomy-tier blocks clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: update | update tasks | update memory | update --all (etc.)
- **Status**: success | partial | failed
- **Details**: scope, tasks triaged, follow-ups surfaced, memory saved/pruned, connector mode
```

## Next Steps

- Run `/assistant:tasks review` for interactive task triage only.
- Run `/assistant:email review` for follow-ups only.
- Run `/assistant:update memory` for a memory-only pass (includes prune).
- Run `/assistant:report` for a full weekly pass.
