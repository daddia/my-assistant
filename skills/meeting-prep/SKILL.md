---
name: meeting-prep
description: Produce a pre-meeting brief — who's in the room, what they do, last
  contact, and what to prepare. Activate when the user says "/assistant:meeting prep",
  "prep me for my next meeting", "who am I meeting", or on a meeting-prep schedule.
---

# Meeting prep

Walk into every meeting knowing who's across the table and what it's about. This is the plugin's answer to a notetaker — we compete on *prep and follow-up*, not on joining the call.

## Read the profile first

Load key people from the profile, VIP tiers from `{assistantPath}/policies/email.policy.md`, and voice. Load `memory/` for anything already known about the attendees.

## What it does

For each upcoming meeting (from `~~calendar`, or a meeting the user names/pastes):

1. **Who** — attendees, their role and company. Pull from `memory/people/`, `memory/glossary.md`, the profile's key people, and any `~~notes`/`~~drive` context. If external and unknown, say so plainly rather than inventing a bio.
2. **What** — the meeting's purpose, from the invite, the thread that spawned it, and related docs.
3. **Last contact** — when the user last spoke to this person and about what (from `~~email` history or memory). One line.
4. **Prep needed** — the 1–3 things the user should have ready: a decision to make, a doc to bring, a question to ask, an open thread to close.

After the prep list, check whether a **prep block** exists before the target meeting (via `~~calendar` or pasted agenda). If the meeting matches prep triggers from [`config/calendar.yaml`](../../config/calendar.yaml) — external attendee, Tier 1–2, or important meeting — and no prep block is present, offer a single prep block proposal using the unified `BlockProposal` shape from `calendar-scheduling` (including `severity` when focus-related; `source_path` under `drafts/calendar-block-*.md`). Use propose-only language: "I can draft a prep block for you to add manually."

Keep each brief to a tight paragraph plus a short prep list. A day of meetings should fit on one screen.

## Output shape

```
Meeting prep — Tue 8 Jul

10:00  Acme quarterly review (Sam Lee, VP Ops; Priya Rao, our side)
  Who:  Sam runs Acme ops, your main contact since Feb. Priya = your lead.
  What: Review Q2 delivery, agree Q3 scope.
  Last: Emailed Sam 4 Jul re contract (awaiting reply — see follow-ups).
  Prep: Bring revised deck. Decision: sign off Q3 scope or defer. Ask: renewal timing.

14:00  1:1 — Dana (direct report)
  ...
```

## Standalone

No calendar? The user pastes the invite or names the meeting; you prep from memory, the profile, and any pasted context.

## Hand-offs

- Contract/thread status → `follow-up-tracking`
- Times/conflicts → `calendar-scheduling`
- After the meeting → `meeting-follow-up`
- New facts learned about an attendee → offer to save via `memory-management`

## Rules

- Don't fabricate a person's background. Unknown is "external contact, no prior context on file".
- Read-only: prep never books, sends, or edits the calendar.

## Approval frame

Follow [`rules/approval-frame.md`](../../rules/approval-frame.md) when prep surfaces schedule proposals or draft replies.

Calendar-related proposals that need user action use queue type `calendar-proposal` with `source_path` under `drafts/calendar-block-*.md` (protect blocks) or `drafts/calendar-*.md` (scheduling slot offers). Reply drafts from prep hand off to `email-drafting` queue conventions (`reply-draft`).

Append the observability footer when queue items are written.
