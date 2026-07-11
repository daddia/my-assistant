---
description: Pre-meeting briefs or post-meeting follow-up — who's in the room and what
  to prepare, or turn notes into extraction, recap drafts, and memory proposals. Never
  sends; does not join calls.
argument-hint: "[prep|follow-up]"
---

Parse `$ARGUMENTS` for the verb. Default to **follow-up** when empty or unrecognized.

## Preflight

- **Profile & paths** — Resolve per `rules/paths.md`. If missing, note it and offer `/assistant:setup`; the plugin still works with pasted invites or notes.
- **Working folder** — Confirm where `drafts/`, `review-queue/index.yaml`, `TASKS.md`, and memory updates will be written. Note if the folder is read-only.
- **Connectors** — Detect `~~calendar`, `~~email`, `~~chat`, `~~notes` if relevant. State whether prep uses a connected calendar or pasted invite; whether follow-up drafts use a connector or copy-paste output.
- **Autonomy tier** — Read the configured tier from the profile (default: Tier 1 — Draft). Never exceed it.

## Plan

- **prep** — Run `skills/meeting-prep/SKILL.md`. For each meeting: who / what / last contact / prep needed. Use `memory/` for context; do not fabricate unknown attendee backgrounds. Draft-only — never send outreach or book follow-ups.
- **follow-up** — Run `skills/meeting-follow-up/SKILL.md`. Extract decisions and action items from pasted notes; draft follow-up emails and queue items; propose memory and task captures. Never send.

## prep

Prep the user for their meetings. Read and follow `skills/meeting-prep/SKILL.md`.

Read the profile and `memory/` first. Cover who / what / last contact / prep needed per meeting, kept tight. Don't fabricate an unknown attendee's background — say "external contact, no prior context on file". Works from the calendar or from a pasted invite. Never send email or book calendar events.

## follow-up (default)

Import and follow up on meeting notes or a transcript. Read and follow `skills/meeting-follow-up/SKILL.md`.

**Import mode** — prompt the user to paste a notetaker export (Granola, Fireflies, Otter, Google Meet / Gemini notes) or hand-typed notes. Detect format via `config/notetaker.yaml`, extract decisions and action items, draft follow-up emails, and write pending queue items. Never send.

If the user has not pasted content yet, ask for notes and list supported formats. Remind them that My Assistant **does not join calls or record** — it works from what they bring.

## Verification

- Re-read prep output or extraction output, follow-up drafts under `drafts/`, queue items, and any proposed `TASKS.md` or memory updates — confirm they match the plan.
- Confirm nothing was sent, booked, or deleted without explicit approval.
- Surface connector errors, format-detection failures, partial notes, missing attendee context, calendar gaps, or autonomy-tier blocks clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: meeting prep | meeting follow-up
- **Status**: success | partial | failed
- **Details**: meetings covered or format detected, action-item count, draft paths, queue ids, connector mode
```

## Next Steps

- After **prep** → run `/assistant:meeting follow-up` after the meeting with pasted notes; run `/assistant:calendar protect` if prep surfaced scheduling conflicts.
- After **follow-up** → send approved follow-up drafts from your mail client; run `/assistant:meeting prep` before your next meeting with the same attendees.
- Run `/assistant:tasks add` to capture action items you confirmed.
- Run `/assistant:memory add` for new people or project context.
