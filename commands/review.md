---
description: Review what's awaiting a response — cold email threads or quiet chat
  messages. Drafts nudges in your voice. Never sends.
argument-hint: "[email|chat]"
---

Parse `$ARGUMENTS` for the channel. Default to **email** when empty or unrecognized.

**Channel aliases:** `slack`, `teams`, and `discord` map to **chat**.

## Preflight

- **Profile & paths** — Resolve per `rules/paths.md`. If missing, note it and offer `/assistant:setup`; follow-up defaults still apply.
- **Working folder** — Confirm where nudge drafts under `drafts/` will be written. Note if the folder is read-only.
- **Connectors** — Detect `~~email` for **email**; `~~chat` for **chat**. State connector-backed vs paste-only.
- **Autonomy tier** — Read the configured tier from the profile (default: Tier 1 — Draft). Never exceed it.

## Plan

- **email** — Run `skills/follow-up-tracking/SKILL.md`. Surface sent mail awaiting a reply; draft warm nudges for cold threads; cross-check `TASKS.md` Waiting On.
- **chat** — Run `skills/follow-up-tracking/SKILL.md` for `~~chat`. Surface messages the user sent that expect a reply and have gone quiet; draft short nudges in the user's voice. Cross-check `TASKS.md` Waiting On. Never send.

## email (default)

Review email awaiting a response. Read and follow `skills/follow-up-tracking/SKILL.md`.

Find open loops from `~~email` sent items (or a pasted list), age them against the profile's cold threshold, draft warm nudges for anything gone quiet (sooner for VIPs), and cross-check the Waiting On section of `TASKS.md`. Present the waiting list and drafts — never send.

## chat

Review chat awaiting a response. Read and follow `skills/follow-up-tracking/SKILL.md`.

Find messages the user sent in `~~chat` (Slack, Teams, etc.) that expect a reply and haven't had one — or work from a pasted list. Age them against the cold threshold; draft short, warm nudges in the user's voice. Cross-check `TASKS.md` Waiting On for non-chat blockers. Present the waiting list and drafts — never send.

If no `~~chat` connector is available, ask for a pasted list of sent messages awaiting reply — paste-only is **pass**, not fail.

## Verification

- Re-read nudge drafts under `drafts/` — confirm they match the plan.
- Confirm nothing was sent or deleted without explicit approval.
- Surface connector errors, partial data, or autonomy-tier blocks clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: review email | review chat
- **Status**: success | partial | failed
- **Details**: waiting count, nudge draft paths, channel, connector mode
```

## Next Steps

- Send approved nudges from your mail or chat client.
- Run `/assistant:update` for a full catch-up across tasks, memory, and follow-ups.
- Run `/assistant:draft email` or `/assistant:draft chat` for a new reply.
