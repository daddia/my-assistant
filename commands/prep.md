---
description: Pre-meeting brief — who's in the room, what they do, your last contact,
  and what to prepare — for today's meetings or one you name.
---

## Preflight

- **Profile** — Read `~/.claude/plugins/config/my-assistant/profile.md` (or `profile.md` in the open workspace). If missing, note it and offer `/assistant:setup`; prep still works with pasted invites.
- **Working folder** — Confirm where prep notes or queue references will be written. Note if the folder is read-only.
- **Connectors** — Detect `~~calendar`, `~~email`, `~~chat`. State whether prep uses a connected calendar or a pasted invite.
- **Autonomy tier** — Read the configured tier from the profile (default: Tier 1 — Draft). Prep is read-only analysis — never send, book, or spend.

## Plan

- Run `skills/meeting-prep/SKILL.md`.
- For each meeting: who / what / last contact / prep needed. Use `memory/` for context; do not fabricate unknown attendee backgrounds.
- Draft-only: propose talking points and prep actions; do not send outreach or book follow-ups.

## Commands

Prep the user for their meetings. Read and follow `skills/meeting-prep/SKILL.md`.

Read the profile and `memory/` first. Cover who / what / last contact / prep needed per meeting, kept tight. Don't fabricate an unknown attendee's background — say "external contact, no prior context on file". Works from the calendar or from a pasted invite. Never send email or book calendar events.

## Verification

- Re-read the prep output — confirm each meeting has who/what/last-contact/prep sections per the plan.
- Confirm nothing was sent, booked, or deleted without explicit approval.
- Surface connector errors, missing attendee context, or calendar gaps clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: meeting prep
- **Status**: success | partial | failed
- **Details**: meetings covered, gaps noted, connector mode
```

## Next Steps

- Run `/assistant:meeting follow-up` after the meeting with pasted notes.
- Run `/assistant:calendar protect` if prep surfaced scheduling conflicts.
- Run `/assistant:memory add` for new attendees worth remembering.
