---
description: Draft a communication in your voice — email, chat message, or formal letter.
  Never sends.
argument-hint: "[email|chat|letter]"
---

Parse `$ARGUMENTS` for the channel. Default to **email** when empty or unrecognized.

**Channel aliases:** `slack`, `teams`, and `discord` map to **chat**.

## Preflight

- **Profile & paths** — Resolve per `rules/paths.md`. If missing, note it and offer `/assistant:setup`; voice defaults still apply for pasted content.
- **Working folder** — Confirm where `drafts/` and `review-queue/index.yaml` will be written. Note if the folder is read-only.
- **Connectors** — Detect `~~email` for **email**; `~~chat` for **chat**. State connector-backed vs paste-only per channel.
- **Autonomy tier** — Read the configured tier from the profile (default: Tier 1 — Draft). Never exceed it.

## Plan

- **email** — Run `skills/email-drafting/SKILL.md` for a mail reply. Gmail draft when connected; copy-paste text when standalone.
- **chat** — Run `skills/email-drafting/SKILL.md` for a short chat message in the user's voice. Post via connector only when the host supports draft/suggest mode; otherwise return copy-paste text. Never send.
- **letter** — Run `skills/email-drafting/SKILL.md` for formal correspondence (paste-only or from named context). Longer form, full letter structure; never send.

## email (default)

Draft an email reply. Read and follow `skills/email-drafting/SKILL.md`.

Load the profile voice first. Work on a pasted thread, a named message, or a connected mailbox thread. Create a Gmail draft on the thread when connected; return copy-paste text when standalone. Never send.

## chat

Draft a chat message. Read and follow `skills/email-drafting/SKILL.md`.

Write a concise message in the user's voice for Slack, Teams, or similar (`~~chat`). Work from a pasted thread, named channel/DM context, or a connected chat connector. Shorter and more casual than email — still match the profile voice. Never send.

## letter

Draft a formal letter. Read and follow `skills/email-drafting/SKILL.md`.

Write a full letter (salutation, body, close) in the user's voice from pasted context or remaining arguments. Save under `drafts/` when the working folder is writable. Never send or post.

## Verification

- Re-read drafts under `drafts/` — confirm they match the plan and channel.
- Confirm nothing was sent or deleted without explicit approval.
- Surface connector errors, missing thread context, or autonomy-tier blocks clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: draft email | draft chat | draft letter
- **Status**: success | partial | failed
- **Details**: draft path, channel, connector mode
```

## Next Steps

- Send or post approved drafts from your client.
- Run `/assistant:email feedback` after editing a draft before send.
- Run `/assistant:inbox triage` for a full inbox pass.
