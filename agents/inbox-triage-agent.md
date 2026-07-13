---
name: inbox-triage-agent
description: Named, schedulable agent that triages the inbox in the morning and
  sweeps midday/afternoon — buckets mail and drafts replies for review. Never sends.
schedule: "0 8,12,16 * * 1-5"
enabled: false
tools: [Read, Write]
---

# Inbox triage agent

`job_id: inbox-triage-am` (08:00) · `inbox-sweep` (12:00/16:00) · catalog: `scheduled/schedules.yaml`

Runs **triage** weekday mornings (drafts replies + action proposals) and **sweep** midday/afternoon (bucket/summarise only). Enable as a named agent, or copy schedules into Cowork scheduled tasks. For always-on reliability that survives a sleeping laptop, use the managed-agent version at `managed-agents/inbox-triage/agent.yaml`. See `/assistant:schedules` and `docs/guide/07-always-on-reliability.md`.

## What it does each run

**08:00 — triage (`inbox-triage-am`):**

1. Read the profile and `{assistantPath}/policies/email.policy.md` + `actions.policy.md` per `rules/paths.md`.
2. Follow `skills/inbox-triage/SKILL.md` in **triage** mode — full pass with lingerers scan.
3. Follow `skills/email-drafting/SKILL.md` for needs-reply + VIP. **Draft only — never send.**
4. Save `sweep-YYYY-MM-DD-0800.md` and run `scripts/update_ledger.py --job-id inbox-triage-am`.

**12:00 / 16:00 — sweep (`inbox-sweep`):**

1. Follow `skills/inbox-triage/SKILL.md` in **sweep** mode — no reply drafts except Tier 1 VIP urgency.
2. Save `sweep-YYYY-MM-DD-{slot}.md` and run `scripts/update_ledger.py --job-id inbox-sweep`.

Both runs: summarise long threads; emit digest of drafts, action proposals, and archive candidates.

## Guardrails

- Draft-only, every autonomy tier. No send, book, or spend.
- Apply labels/archives only at Tier 2+; otherwise propose them in the digest.
- Never mark a Tier 1 VIP read without confirmation.
- Pre-check `~~email` before implying Gmail drafts exist.

## Setup notes

- `enabled: false` by default — turn on deliberately.
- Pre-approve the tools it needs (Gmail draft, label, file write, `update_ledger.py`) so unattended runs don't stall.
- Desktop must be awake for scheduled runs; see `skills/schedule-setup/SKILL.md`.
