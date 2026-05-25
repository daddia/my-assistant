---
name: update
description: Sync tasks and refresh memory from current activity. Use when triaging
  stale tasks, filling memory gaps, or running a comprehensive scan of email, calendar,
  and chat for missed todos.
argument-hint: "[--comprehensive]"
---

# Update

> If you see unfamiliar placeholders or need to check which tools are connected, see [CONNECTORS.md](../../CONNECTORS.md).

Keep your task list and memory current. Two modes:

- **Default:** Triage stale items, check memory for gaps
- **`--comprehensive`:** Deep scan email, calendar, chat — flag missed todos and suggest new memories

## Usage

```
/update
/update --comprehensive
```

## Default mode

### 1. Load current state

Read `TASKS.md`, `memory/`, and `CLAUDE.md`. If they don't exist, suggest `/start` first.

### 2. Triage stale items

Review active tasks and flag:
- Tasks with due dates in the past
- Tasks open for 30+ days
- Tasks with no context

Present each for triage: Mark done? Reschedule? Move to Someday?

### 3. Check memory for gaps

For each task, decode entities (people, places, projects):

```
Task: "Book Sarah's dentist appointment"

Decode:
- Sarah → ✓ daughter (in memory/people.md)
- dentist → ? No preferred dentist on file
```

Ask about unknowns and update memory files.

### 4. Report

```
Update complete:
- Tasks: X triaged, X completed
- Memory: X gaps filled
```

## Comprehensive mode (`--comprehensive`)

Everything in default mode, plus a deep scan of connected sources.

### Scan activity sources

Gather from available connectors:
- **Email (`~~email`):** Recent messages with action items
- **Calendar (`~~calendar`):** Upcoming events needing prep
- **Chat (`~~chat`):** Recent messages with commitments
- **Drive (`~~drive`):** Recently shared documents

### Flag missed todos

Compare activity against `TASKS.md`. Surface action items not yet tracked:

```
From your activity, these look like todos you haven't captured:

1. From email (Tuesday): "I'll call the plumber this week"
   → Add to TASKS.md?

2. From calendar (Friday): Parent-teacher meeting
   → Anything to prepare?
```

Let the user pick which to add.

### Suggest new memories

Surface new people, places, or projects not in memory. Offer to add with confirmation.

## Notes

- Never auto-add tasks or memories without user confirmation
- Safe to run frequently — only updates when there's new info
- `--comprehensive` always runs interactively
- If a connector isn't connected, skip it and note the gap
