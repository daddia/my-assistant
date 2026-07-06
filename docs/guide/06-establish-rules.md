# Establish working rules

How My Assistant keeps you in control.

## Draft, don't send

By default My Assistant can:

- Research and summarise
- Triage, plan, and draft (emails, invites, nudges, recaps)
- Track tasks and follow-ups
- Write briefings and reviews to your working folder

It needs your explicit approval to:

- Send emails or messages
- Make bookings or spend money
- Create, move, or delete calendar events
- Delete files

Set during `/my-assistant:setup`; adjust anytime by re-running it.

## Graduated autonomy

Your profile sets an **autonomy tier** (default Tier 1). The plugin never operates above it:

| Tier | Behaviour |
|------|-----------|
| 0 — Suggest | Proposes actions; does nothing until told |
| **1 — Draft** (default) | Writes drafts and labels; leaves them for review |
| 2 — Act-within-rails | Auto-archives marketing, auto-labels, files FYI; still only drafts replies |
| 3 — Notify-after | Narrow pre-approved actions (e.g. declining spam meetings); acts then reports. Opt-in |

"Send", "book", and "spend" are never automatic at any tier. Raise your tier only after a week of good drafts.

## Proposing changes to your rules

When a durable pattern emerges — a new VIP, a changed reply threshold, a tone correction you keep making — the assistant proposes a profile update and shows you the exact diff before writing. Only the setup interview writes your profile without asking.

## Separate scopes

If you set scope to personal-only, anything work-shaped is flagged before it proceeds (and vice versa). Keep distinct contexts in distinct profiles/working folders.

## If something feels wrong

Re-run `/my-assistant:setup` and tell it what it should never do without asking. It follows those rules every session. Full detail: [`rules/core-behaviour.md`](../../rules/core-behaviour.md).
