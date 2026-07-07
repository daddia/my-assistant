---
name: meeting-follow-up
description: Turn meeting notes or a transcript into a summary, action items, and
  follow-up email drafts. Activate when the user pastes notes or a transcript, says
  "follow up on that meeting", "what were the actions", or "draft the recap". Works
  with Granola/Fireflies/Otter output or hand-typed notes. Drafts only.
---

# Meeting follow-up

The value of a meeting is in what happens after it. Paste the notes; get a clean summary, a real action list, and the follow-up emails drafted in the user's voice.

## Read the profile first

Load voice, anti-style, and VIP tiers (so drafts to attendees match their relationship). Load `memory/` to resolve who's who.

## Input

Whatever the user has:
- Notes they typed
- A transcript from an external notetaker (Granola, Fireflies, Otter, etc.)
- A rough brain-dump right after the call

We don't join calls or record — we work from what the user brings. Say so if they expect a live bot.

## What it produces

1. **Summary** — 3–5 lines: what was discussed, what was decided. No filler.
2. **Action items** — a clean list with owner and due date where stated. Separate *the user's* actions from others'.
3. **Follow-up drafts** — for each thread that needs one (recap to attendees, a promised doc, a next-step email), a draft in the user's voice. Draft only.
4. **Task + memory offers** — offer to add the user's actions to `TASKS.md` (via `task-management`) and to save any durable new facts about people/projects (via `memory-management`).

## Output shape

```
Follow-up — Acme quarterly review (Tue 8 Jul)

Summary
  Agreed Q3 scope (3 workstreams). Sam to send updated SLA. Renewal
  deferred to Sept. Pricing concern raised on workstream 2.

Your actions
  • Send revised deck to Sam — by Thu
  • Draft Q3 SOW — next week
Others
  • Sam → updated SLA doc (this week)

Drafts
  • Recap email to Sam + Priya — ready
  • Doc-delivery note to Sam — ready

Add your 2 actions to TASKS.md? Save "Acme renewal → Sept" to memory?
```

## Rules

- **Draft only.** Recaps and follow-ups are drafts the user sends.
- Attribute actions accurately; don't put someone else's task on the user, or vice versa.
- Don't invent decisions the notes don't support. If the notes are ambiguous, flag it: "unclear who owns the SLA — confirm".

## Approval frame

Follow [`rules/approval-frame.md`](../../rules/approval-frame.md) for every follow-up report with drafts or memory proposals.

**Queue types:**

- `reply-draft` — follow-up email drafts use `source_path` under `drafts/reply-*.md`
- `memory-suggestion` — durable facts proposed for memory use `source_path` under `pending-memory/*.md`

Append the observability footer when queue items are written.
