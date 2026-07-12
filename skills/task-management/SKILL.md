---
name: task-management
description: Track tasks and commitments in TASKS.md. Activate when the user mentions
  a task or todo, says "/assistant:tasks add", "/assistant:tasks review", "/assistant:tasks sync",
  "add a task", "what's on my list", "remind me to", "I'm done with X", or when another
  skill surfaces an action item to capture.
---

# Task management

Tasks live in `TASKS.md` — one plain markdown file the user and the assistant both read and write. No app, no lock-in.

**Visual editor:** `skills/dashboard.html` (open in Chrome or Edge) provides a board/list UI for the same `TASKS.md` — drag between sections, inline edit, auto-save. Point it at the working folder's `TASKS.md`.

## Location

`TASKS.md` in the working folder. Create it from the template below if missing.

## Dashboard setup (first run)

On **first interaction with tasks** (add, review, sync, or natural-language capture):

1. Check if `dashboard.html` exists in the working folder.
2. If not, copy it from `${CLAUDE_PLUGIN_ROOT}/skills/dashboard.html` (or the plugin's `skills/dashboard.html` path).
3. Tell the user: "Dashboard is ready at `dashboard.html`. Open it from your file browser (Chrome or Edge). Run `/assistant:start` for a light setup or `/assistant:setup` for the full profile."

## Format

```markdown
# Tasks

## To do
- [ ] Send Acme the revised deck — by Thu
- [ ] Draft Q3 SOW — next week

## In progress
- [ ] **Northwind API spec** — drafting endpoints (started Mon)

## In review
- [ ] **Q2 budget** — with Todd for sign-off (sent Fri)

## Done
- [x] ~~Submit expense report~~ (8 Jul)

## Cancelled
- [x] ~~Old vendor RFP~~ (cancelled 1 Jun — went with Acme)

## Blocked
- [ ] Insurance document — chasing provider (since 10 May)
- [ ] Acme contract reply — nudged 8 Jul
```

Task line: `- [ ] **Title** — context, for whom, due date`
Done: `- [x] ~~Task~~ (date)` — keep ~1 week in Done, then drop.
Cancelled: `- [x] ~~Task~~ (cancelled date — reason)` — keep briefly, then drop.

## Status sections

| Section | Use for |
|---------|---------|
| **To do** | Captured work not yet started — default for new tasks |
| **In progress** | Actively being worked on |
| **In review** | Waiting on feedback, sign-off, or review before done |
| **Done** | Completed successfully |
| **Cancelled** | Abandoned or no longer relevant |
| **Blocked** | Waiting on someone or something external — same list `follow-up-tracking` cross-checks |

Flag if **To do** + **In progress** exceeds ~40 items combined; suggest a review (hand to `weekly-review`).

## Legacy migration

If `TASKS.md` still uses **Active / Waiting On / Someday / Done**, offer a one-time remap:

| Legacy | New |
|--------|-----|
| Active | To do (or In progress if context says started) |
| Waiting On | Blocked |
| Someday | To do with a "someday" note, or Cancelled |
| Done | Done |

## How to interact

- **"What's on my list":** read `TASKS.md`, summarise To do, In progress, In review, and Blocked; surface overdue items first.
- **"Add a task" / "remind me to":** add to **To do** with context; tell the user what was added.
- **"I'm working on X":** move to **In progress**.
- **"Sent X for review":** move to **In review**.
- **"I'm done with X":** mark `[x]`, date it, move to **Done**.
- **"Cancel X" / "drop X":** mark `[x]`, note reason, move to **Cancelled**.
- **Blocked-on items:** put in **Blocked**; `follow-up-tracking` surfaces these alongside email/chat follow-ups.
- **From another skill:** when `inbox-triage`, `meeting-follow-up`, or `follow-up-tracking` surfaces an action, offer to capture it — don't add silently.

## External sync

When `/assistant:tasks sync` runs with `~~tasks` connected, or `/assistant:update tasks` / `--all` includes task sync, fetch open work assigned to the user and compare against `TASKS.md`.

**Sources (use what's connected):**

- **Project tracker** (`~~tasks`): Asana, Linear, Jira, monday.com, Asana, ClickUp, etc.
- **GitHub Issues** (when in a repo): `gh issue list --assignee=@me --state=open`

**Diff table:**

| External task | TASKS.md match? | Action |
|---------------|-----------------|--------|
| Found, not in TASKS.md | No match | Offer to add (default: To do) |
| Found, already in TASKS.md | Match by title (fuzzy) | Skip or update status if external state differs |
| In TASKS.md, not in external | No match | Flag as potentially stale |
| Completed externally | In To do / In progress / In review | Offer to mark Done |
| Cancelled externally | Any open section | Offer to move to Cancelled |

Present the diff and let the user decide what to add, complete, or cancel. Preserve external links in task notes when available. Fuzzy matching handles minor wording differences.

**Without connectors:** `sync` uses chat/paste only — surface action items from the conversation or a pasted issue list and offer to capture each.

## Triage (review / update)

When triaging stale items (review, `/assistant:update`, `/assistant:report`), flag:

- Tasks with due dates in the past (To do, In progress, In review)
- Tasks in To do or In progress for 30+ days untouched
- Tasks with no context (no person, no project)
- Blocked items with no activity for 14+ days

Present each for triage: **Done?** **In progress?** **Blocked?** **Cancelled?** **Reschedule?**

## Conventions

- Don't add a task without telling the user.
- Don't add vague tasks — ask for enough detail to act.
- Don't auto-complete — wait for confirmation.
- Never store credentials or account numbers in tasks.

## Approval frame

Follow [`rules/approval-frame.md`](../../rules/approval-frame.md) when surfacing task changes or recommendations.

`TASKS.md` changes are **not** duplicated as queue items unless a separate reviewable draft is produced (e.g. a proposed task description the user must approve before write). Routine task adds with user confirmation in chat do not need queue items.
