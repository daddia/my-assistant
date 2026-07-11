---
name: inbox-triage
description: Sort recent email into needs-reply / FYI / marketing / VIP buckets and
  summarise long threads. Activate when the user says "/assistant:inbox", "/assistant:inbox triage",
  "/assistant:inbox sweep", "triage my inbox", "sweep my mail", "what needs a reply",
  or asks what's in their inbox. Works on a connected mailbox or on pasted threads.
---

# Inbox triage

Turn a full inbox into a short, ranked list of what actually needs the user — and hand off to `email-drafting` for the replies. This is the wedge that matches Fyxer and Superhuman; do it well and fast.

## Modes

Invoked via `/assistant:inbox triage` (default) or `/assistant:inbox sweep`:

- **Triage** — full pass: bucket, summarise, and hand needs-reply + VIP to `email-drafting`.
- **Sweep** — lighter pass: bucket and summarise only; propose labels/archives; skip reply drafting unless a Tier 1 VIP needs immediate attention.

## Read the profile first

Load the profile per `rules/paths.md` (default `~/MyAssistant/config/profile.md`) for VIP tiers, email policy (reply threshold, auto-archive senders, labels), and voice. If there's no profile, use sensible defaults and mention that `/assistant:setup` will sharpen the buckets.

## Standalone vs connected

- **Connected (`~~email`):** read messages since the last sweep (or the last ~50 unread). Gmail is draft-only — you can read and label, never send.
- **Standalone:** the user pastes threads. Triage exactly the same way and return the buckets.

## The buckets

Classify each message in priority order:

1. **VIP** — from anyone in the profile's Tier 1/2. Surface first, never auto-archive, draft fastest.
2. **Needs-reply** — a real person expecting a response, or an action item addressed to the user.
3. **FYI** — informational, no reply expected (receipts, notifications, cc's, newsletters worth reading → the `@ToRead`-style label).
4. **Marketing** — bulk/promotional/newsletter-platform senders. Candidates for archive.

Use the profile's exact-sender auto-archive list and newsletter-platform list. When a message is ambiguous (score 0), leave it in the inbox and flag it in the summary rather than guessing.

## What you produce

A scannable triage report, most-important first:

```
Inbox sweep — 18 new since 8:00am

VIP (2) — drafted replies
  • Priya Rao — "Re: Q3 board deck" — wants the revised deck by Thu. Draft ready.
  • Dad — "Sunday lunch?" — Draft ready.

Needs-reply (3) — drafted
  • Acme billing — invoice query. Draft ready.
  • ...

FYI (7) — no reply needed
  • 4 receipts, 2 GitHub notifications, 1 newsletter → @ToRead

Marketing (6) — propose archive
  • [table of exact senders]  →  Archive all?  (say the word)
```

## Actions by autonomy tier

Respect the profile's tier (default Tier 1):

- **Tier 0:** list buckets only, do nothing.
- **Tier 1 (default):** create reply drafts for needs-reply + VIP (hand to `email-drafting`); propose labels and archives in the report but don't apply.
- **Tier 2:** additionally apply labels and archive marketing that matches the exact-sender list; still only drafts replies.
- **Tier 3:** as Tier 2, plus any narrow pre-approved auto-actions; report what was done.

Never send. Never mark a Tier 1 VIP as read without separate confirmation. Always show the proposed archive list before archiving anything.

## Long threads

For any thread over ~5 messages, add a two-line summary (what's being decided, what's outstanding) above the draft so the user doesn't reread the chain.

## Hand-offs

- Replies → `email-drafting`
- Sent-but-silent items the sweep surfaces → note for `follow-up-tracking`
- Action items that aren't email replies → offer to add to `TASKS.md` via `task-management`

## Approval frame

Follow [`rules/approval-frame.md`](../../rules/approval-frame.md) for every triage and sweep report with reviewable work.

**Queue types:**

- **Reply drafts** — when handing off to `email-drafting`, write `reply-draft` items with `source_path` under `drafts/reply-*.md` after the draft file is created.
- **Archive proposals** — write **one batched** `archive-proposal` item per triage or sweep run when marketing/archive candidates exist. Set `source_path` to `review-queue/archives-YYYY-MM-DD.yaml` listing proposed threads.

Append the observability footer when queue items are written. Tier 2+ auto-archives still create `pending` items with `autonomy_tier` ≥ 2 for audit.
