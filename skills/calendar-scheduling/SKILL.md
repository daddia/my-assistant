---
name: calendar-scheduling
description: Propose meeting times, check conflicts, and draft invites and scheduling
  replies. Activate when the user asks to schedule something, find a time, check for
  conflicts, or draft an invite. Proposes and drafts only — never books, moves, or
  declines without approval.
---

# Calendar scheduling

Do the scheduling legwork — find the slots, spot the clashes, draft the offer — and stop short of booking. The user confirms; you never auto-book.

## Read the profile first

Load the calendar policy: working hours, meeting-length defaults, buffers, focus-time defence level, what may be auto-proposed vs must-always-ask, and how scheduling replies should read.

## What it does

1. **Find times.** Against `~~calendar` (or a pasted agenda), find slots that fit working hours, respect buffers, and defend focus blocks at the configured level.
2. **Check conflicts.** Flag overlaps, back-to-backs with no buffer, and anything that eats a protected block. Say what clashes, don't silently drop it.
3. **Draft the offer.** Propose 2–3 specific slots *with timezone*, in the user's voice, formality matched to the contact's VIP tier. Put the booking onus on nobody — offer concrete times, not "when works for you?".
4. **Draft the invite** if the user picks a slot — but leave it for them to send/create.

## Standalone

No calendar connector? The user pastes their week; you reason over it the same way and return proposed times and a draft reply they can send.

## Output shape

```
Scheduling — 30 min with Sam (Acme), this/next week

Proposed (fit hours, buffered, clear of focus block):
  • Tue 8 Jul, 2:00–2:30pm AEST
  • Wed 9 Jul, 11:00–11:30am AEST
  • Thu 10 Jul, 3:30–4:00pm AEST

Conflicts avoided: Tue 10am (clashes standup), Wed 9am (focus block).

Draft reply to Sam:
  Hi Sam — any of these suit for 30 min?
  • Tue 8 Jul 2pm, Wed 9 Jul 11am, or Thu 10 Jul 3:30pm (AEST).
  Send a calendar invite once you've picked one.
  Jon
```

## Rules

- **Never auto-book, move, or decline.** Propose and draft; the user acts. (Confirmation model in `rules/core-behaviour.md`.)
- Always include the timezone in offered slots.
- Never double-book or offer a slot that breaks a buffer or focus block without flagging it.
- Match reply formality to the contact's tier.
- Hand meeting *content* prep to `meeting-prep`, not this skill.
