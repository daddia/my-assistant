---
description: Draft a reply in your voice, or review what's awaiting a response. Never sends.
argument-hint: "[draft|review|feedback] [--variant shorter|longer|formal|casual]"
---

Parse `$ARGUMENTS` for the verb and optional variant flag. Default to **draft** when empty or unrecognized.

**Variant flag (draft path):** `--variant shorter|longer|formal|casual` passes through to `skills/email-drafting/SKILL.md`.

## Preflight

- **Profile & paths** — Resolve per `rules/paths.md`. If missing, note it and offer `/assistant:setup`; voice defaults still apply for pasted threads.
- **Working folder** — Confirm where `drafts/`, `pending-profile/`, and `review-queue/index.yaml` will be written. Note if the folder is read-only.
- **Connectors** — Detect `~~email`. Determine connector mode: `connected`, `paste-only`, or `fallback-degraded`.
- **Autonomy tier** — Read the configured tier from the profile (default: Tier 1 — Draft). Never exceed it.

## Plan

- **draft** — Run `skills/email-drafting/SKILL.md`. Draft a reply (Gmail draft when connected; copy-paste text when standalone). Surface grounding checklist and `Draft surface:` mode. Never send.
- **review** — Run `skills/follow-up-tracking/SKILL.md`. Surface open loops and draft warm nudges for threads gone cold.
- **feedback** — Run `skills/email-feedback/SKILL.md`. Diff draft vs sent version; propose `profile-diff` queue items — never write `profile.md` directly.

## draft (default)

Draft a reply without a full inbox triage. Read and follow `skills/email-drafting/SKILL.md`.

Load the profile voice first. Work on a pasted thread, a named message, or a connected mailbox thread. Create a Gmail draft on the thread when connected; return copy-paste text when standalone. Never send.

Produce full grounding checklist and `reply-draft` queue item when working folder is writable.

## review

Review sent mail awaiting a reply. Read and follow `skills/follow-up-tracking/SKILL.md`.

Find open loops, age them against the profile's cold threshold, draft warm nudges for anything gone quiet (sooner for VIPs), and cross-check the **Blocked** section of `TASKS.md`. Present the waiting list and drafts — never send.

## feedback

Capture feedback on a reply draft and propose voice/anti-style profile updates. Read and follow `skills/email-feedback/SKILL.md`.

Resolve the draft under review (from chat context, `drafts/reply-*.md`, or a review-queue `reply-draft` id). Classify outcome as `good`, `light-edit`, or `heavy-rewrite` from arguments or natural language. Diff assistant draft vs pasted sent version; write `pending-profile/*.diff` and a `profile-diff` queue item when warranted. Link `related_ids` to source `reply-draft` when known. Never write `profile.md` directly.

Argument hint: `[good | light-edit | heavy-rewrite] [paste final sent version]`

## Verification

### draft path

- Re-read drafts under `drafts/` — confirm grounding checklist and voice match plan.
- Confirm **Draft surface:** in summary; FALLBACK header when `fallback-degraded`.
- Confirm `reply-draft` queue item when drafts written; no false Gmail confirmation on degraded runs.
- Variant flag produces at most one variant B when requested.

### feedback path

- Re-read `pending-profile/*.diff` and queue items — hunks cite edit patterns with evidence quotes.
- Confirm `profile-diff` queue item when golden expects diff; `related_ids` when source draft known.
- Confirm nothing was sent or deleted without explicit approval.

### all paths

- Surface connector errors, missing thread context, or autonomy-tier blocks clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: email draft | email review | email feedback
- **Status**: success | partial | failed
- **Draft surface**: connected | paste-only | fallback-degraded (draft path)
- **Details**: draft paths, waiting count, feedback classification, variant (if any)
```

## Next Steps

- Send approved drafts from your mail client.
- Run `/assistant:email feedback` after editing a draft before send.
- Run `/assistant:inbox triage` for a full inbox pass.
- Approve `profile-diff` queue items to update your voice.
