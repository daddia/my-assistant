---
name: morning-briefing-agent
description: Named, schedulable agent that assembles the weekday morning briefing and
  saves it for the user to read with their coffee.
schedule: "0 8 * * 1-5"
enabled: false
tools: [Read, Write]
---

# Morning briefing agent

`job_id: morning-briefing` · catalog: `config/schedules.yaml`

Runs weekdays at 8am to produce the daily brief. Because a sleeping laptop misses local runs, the managed-agent version (`managed-agents/morning-briefing/agent.yaml`) on Anthropic infra is the reliable choice if the brief must always land. Walk the decision tree via `/assistant:schedules` or `docs/guide/07-always-on-reliability.md`.

## What it does each run

1. Read the profile (working hours, VIP tiers, voice).
2. Follow `skills/daily-brief/SKILL.md`: assemble today's calendar, priority unread (VIP-first), follow-ups going cold, due tasks from `TASKS.md`, and what needs attention before noon.
3. Keep it under ~400 words, scannable.
4. Save to `brief-YYYY-MM-DD.md`. If `~~chat` or `~~drive` is connected, optionally deliver there.

## Guardrails

- Read-only and draft-only — surfaces and drafts, never sends or books.

## Setup notes

- `enabled: false` by default.
- Pre-approve calendar/email read and file write.
- If the machine is often asleep at 8am, move this to the managed agent or a Claude Code cloud scheduled task.
