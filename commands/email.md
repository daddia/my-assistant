---
description: Draft a reply in your voice, or review what's awaiting a response.
  Never sends.
argument-hint: "[draft|review|feedback]"
---

Parse `$ARGUMENTS` for the verb. Default to **draft** when empty or unrecognized.

## draft (default)

Draft a reply without a full inbox triage. Read and follow `skills/email-drafting/SKILL.md`.

Load the profile voice first. Work on a pasted thread, a named message, or a connected mailbox thread. Create a Gmail draft on the thread when connected; return copy-paste text when standalone. Never send.

## review

Review sent mail awaiting a reply. Read and follow `skills/follow-up-tracking/SKILL.md`.

Find open loops, age them against the profile's cold threshold, draft warm nudges for anything gone quiet (sooner for VIPs), and cross-check the Waiting On section of `TASKS.md`. Present the waiting list and drafts — never send.

## feedback

Capture feedback on a reply draft and propose voice/anti-style profile updates. Read and follow `skills/email-feedback/SKILL.md`.

Resolve the draft under review (from chat context, `drafts/reply-*.md`, or a review-queue `reply-draft` id). Classify outcome as `good`, `light-edit`, or `heavy-rewrite` from arguments or natural language. Diff assistant draft vs pasted sent version; write `pending-profile/*.diff` and a `profile-diff` queue item when warranted. Never write `profile.md` directly.

Argument hint: `[good | light-edit | heavy-rewrite] [paste final sent version]`
