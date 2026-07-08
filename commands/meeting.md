---
description: Post-meeting follow-up — paste a notetaker export or your notes to get
  structured extraction, recap drafts, and memory proposals. Never sends; does not
  join calls.
argument-hint: "[follow-up]"
---

Parse `$ARGUMENTS` for the verb. Default to **follow-up** when empty or unrecognized.

## Preflight

- **Profile** — Read `~/.claude/plugins/config/my-assistant/profile.md` (or `profile.md` in the open workspace). If missing, note it and offer `/assistant:setup`; the plugin still works with pasted notes.
- **Working folder** — Confirm where `drafts/`, `review-queue/index.yaml`, `TASKS.md`, and memory updates will be written. Note if the folder is read-only.
- **Connectors** — Detect `~~email`, `~~notes`, `~~chat` if relevant. State whether follow-up drafts use a connector or copy-paste output.
- **Autonomy tier** — Read the configured tier from the profile (default: Tier 1 — Draft). Never exceed it.

## Plan

- **follow-up** — Run `skills/meeting-follow-up/SKILL.md`. Extract decisions and action items from pasted notes; draft follow-up emails and queue items; propose memory and task captures. Never send.

## follow-up (default)

Import and follow up on meeting notes or a transcript. Read and follow `skills/meeting-follow-up/SKILL.md`.

**Import mode** — prompt the user to paste a notetaker export (Granola, Fireflies, Otter, Google Meet / Gemini notes) or hand-typed notes. Detect format via `config/notetaker-formats.yaml`, extract decisions and action items, draft follow-up emails, and write pending queue items. Never send.

If the user has not pasted content yet, ask for notes and list supported formats. Remind them that My Assistant **does not join calls or record** — it works from what they bring.

## Verification

- Re-read extraction output, follow-up drafts under `drafts/`, queue items, and any proposed `TASKS.md` or memory updates — confirm they match the plan.
- Confirm nothing was sent, booked, or deleted without explicit approval.
- Surface format-detection failures, partial notes, or autonomy-tier blocks clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: meeting follow-up
- **Status**: success | partial | failed
- **Details**: format detected, action-item count, draft paths, queue ids
```

## Next Steps

- Send approved follow-up drafts from your mail client.
- Run `/assistant:tasks add` to capture action items you confirmed.
- Run `/assistant:memory add` for new people or project context.
- Run `/assistant:prep` before your next meeting with the same attendees.
