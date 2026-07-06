---
name: follow-up-tracker
description: Track sent mail awaiting a reply and draft polite nudges when it goes
  cold. Activate when the user asks "what am I waiting on", "anything gone quiet",
  "who hasn't replied", during /my-assistant:update, or on a follow-up schedule.
  Drafts nudges only — never sends.
---

# Follow-up tracker

The things that fall through the cracks are the ones you're *waiting on*. This skill watches sent mail that hasn't been answered and drafts the nudge — so nothing important goes silent.

## Read the profile first

Load VIP tiers (VIP silences escalate faster and harder) and voice (nudges must sound like the user). Default cold threshold: **3 business days**; override from the profile if set.

## What it does

1. **Find open loops.** From `~~email` sent items (or a pasted list), find messages the user sent that expect a reply and haven't had one.
2. **Age them.** Flag anything silent past the threshold — sooner for VIPs.
3. **Draft the nudge.** For each cold item, write a short, warm follow-up in the user's voice. Never guilt-trip; assume the thread was missed, not ignored.
4. **List, don't send.** Present the drafts and the waiting list. Drafts only.

## Also feeds the task list

Cross-reference the **Waiting On** section of `TASKS.md` (via `task-management`): things the user is blocked on that aren't email (a document from a provider, a callback). Surface those alongside the email follow-ups so "what am I waiting on" is one answer, not two.

## Output shape

```
Waiting on — 4 items

Cold, nudge drafted (2)
  • Acme contract — sent 4 business days ago, no reply. Nudge ready.
  • Priya re board deck — VIP, sent 2 days ago, silent. Nudge ready.

Still within window (1)
  • Supplier quote — sent yesterday. Give it till Thursday.

Non-email (from TASKS.md → Waiting On)
  • Insurance document — chased 10 May, still outstanding.
```

## Nudge draft example

```
Draft nudge — Re: Acme contract (to Sam)

  Hi Sam,

  Circling on this — any thoughts on the draft from last week?
  Happy to jump on a quick call if that's easier.

  Jon
```

(Note: "circling on this" is fine as a genuine short nudge; avoid the profile's banned corporate-speak in the body.)

## Rules

- **Draft only**, every tier.
- Escalate VIP silences to `~~chat` only if the user has asked for that; otherwise just surface in the list.
- Don't nudge threads the user explicitly closed, or where the ball is in *their* court.
- One nudge per thread per run; don't re-draft a nudge the user already sent.
