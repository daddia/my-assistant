---
description: Draft a reply in your voice, or review what's awaiting a response. Never sends.
argument-hint: "[draft|review|feedback]"
---

Parse `$ARGUMENTS` for the verb. Default to **draft** when empty or unrecognized.

## Preflight

- **Profile** — Read `~/.claude/plugins/config/my-assistant/profile.md` (or `profile.md` in the open workspace). If missing, note it and offer `/assistant:setup`; voice defaults still apply for pasted threads.
- **Working folder** — Confirm where `drafts/`, `pending-profile/`, and `review-queue/index.yaml` will be written. Note if the folder is read-only.
- **Connectors** — Detect `~~email`. State whether the run is connector-backed or paste-only.
- **Autonomy tier** — Read the configured tier from the profile (default: Tier 1 — Draft). Never exceed it.

## Plan

- **draft** — Run `skills/email-drafting/SKILL.md`. Draft a reply (Gmail draft when connected; copy-paste text when standalone). Never send.
- **review** — Run `skills/follow-up-tracking/SKILL.md`. Surface open loops and draft warm nudges for threads gone cold.
- **feedback** — Run `skills/email-feedback/SKILL.md`. Diff draft vs sent version; propose `profile-diff` queue items — never write `profile.md` directly.

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

## Verification

- Re-read drafts under `drafts/`, nudge drafts, `pending-profile/*.diff`, and queue items — confirm they match the plan.
- Confirm nothing was sent or deleted without explicit approval.
- Surface connector errors, missing thread context, or autonomy-tier blocks clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: email draft | email review | email feedback
- **Status**: success | partial | failed
- **Details**: draft paths, waiting count, feedback classification, connector mode
```

## Next Steps

- Send approved drafts from your mail client.
- Run `/assistant:email feedback` after editing a draft before send.
- Run `/assistant:inbox triage` for a full inbox pass.
- Approve `profile-diff` queue items to update your voice.
