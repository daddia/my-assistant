---
description: Triage or sweep your inbox — bucket mail, draft replies in your voice,
  and propose what to archive. Never sends.
argument-hint: "[triage|sweep]"
---

Parse `$ARGUMENTS` for the verb. Default to **triage** when empty or unrecognized.

## triage (default)

Full inbox pass. Read and follow `skills/inbox-triage/SKILL.md` and `skills/email-drafting/SKILL.md` for replies.

Read the profile first for VIP tiers and email policy. Respect the configured autonomy tier (default: draft replies and propose labels/archives, apply nothing). Work on the connected mailbox or on pasted threads. Always show the proposed archive list before archiving.

## sweep

Lighter pass — bucket and summarise only. Read and follow `skills/inbox-triage/SKILL.md` in sweep mode:

- Classify into VIP / needs-reply / FYI / marketing buckets and summarise long threads.
- Propose labels and archives per autonomy tier; do **not** draft replies unless a Tier 1 VIP item needs immediate attention (then hand to `email-drafting` for that item only).
- Note sent-but-silent threads for `follow-up-tracking`.

Read the profile first. Work on the connected mailbox or pasted threads. Always show the proposed archive list before archiving.
