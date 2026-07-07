---
description: Post-meeting follow-up — paste a notetaker export or your notes to get
  structured extraction, recap drafts, and memory proposals. Never sends; does not
  join calls.
argument-hint: "[follow-up]"
---

Parse `$ARGUMENTS` for the verb. Default to **follow-up** when empty or unrecognized.

## follow-up (default)

Import and follow up on meeting notes or a transcript. Read and follow `skills/meeting-follow-up/SKILL.md`.

**Import mode** — prompt the user to paste a notetaker export (Granola, Fireflies, Otter, Google Meet / Gemini notes) or hand-typed notes. Detect format via `config/notetaker-formats.yaml`, extract decisions and action items, draft follow-up emails, and write pending queue items. Never send.

If the user has not pasted content yet, ask for notes and list supported formats. Remind them that My Assistant **does not join calls or record** — it works from what they bring.
