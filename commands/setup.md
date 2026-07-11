---
description: Configure the assistant — a 10-minute interview that writes your profile
  (identity, voice, working rules) and policies (VIP tiers, email and calendar rules),
  and sets up your working folder (default ~/MyAssistant).
---

## Preflight

- **Profile & paths** — Resolve per `rules/paths.md`. If a profile already exists, confirm whether the user wants to update or start fresh.
- **Working folder** — Step 0 of setup: suggest `~/MyAssistant`, accept an alternate path, create `{assistantPath}/policies/`. Note if the folder is read-only.
- **Connectors** — Advisory only; note which connectors the user plans to connect after setup.
- **Autonomy tier** — Explain tiers during the interview; default to Tier 1 — Draft unless the user chooses otherwise.

## Plan

- Run `skills/setup-interview/SKILL.md`.
- Establish working folder first, then offer 2-minute quick-start, a starter profile, or the full 10-minute interview.
- Write `{assistantPath}/config/profile.md`, `{assistantPath}/policies/*.policy.md`, and `{assistantPath}/config/my-assistant.json` once (no duplicate legacy copies). Run post-setup health subset; do not overwrite an existing profile without confirmation.

## Commands

Run the onboarding interview. Read and follow `skills/setup-interview/SKILL.md`.

Offer a 2-minute quick-start or the full 10-minute interview. Confirm the working folder (`~/MyAssistant` by default), then write profile, policies, and install config under `{assistantPath}/config/`. Confirm each section as you go, run the post-setup health subset, then point the user at `/assistant:inbox triage`, `/assistant:brief`, and `/assistant:health` for a full check.

## Verification

- Re-read the written profile — confirm identity, voice, and autonomy tier are complete.
- Re-read `{assistantPath}/policies/email.policy.md` and `calendar.policy.md` — confirm VIP tiers, email rules, and calendar rules are captured.
- Confirm `my-assistant.json` has `assistantPath`, `configPath`, `policiesPath`, `scope`, `setupAt`, and `lastUpdated`.
- Confirm files were written under the working folder, not inside the plugin directory.
- Surface write failures (permissions, read-only path) clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: setup interview
- **Status**: success | partial | failed
- **Details**: assistantPath, profile path, interview mode (quick-start | starter | full)
```

## Next Steps

- Open `{assistantPath}` in Cowork or Cursor so hooks and schedules resolve paths.
- Run `/assistant:health` for a full install health check.
- Run `/assistant:inbox triage` or paste a demo thread from `examples/`.
- Run `/assistant:brief` for a morning briefing.
- Connect tools via Cowork → Settings → Connectors when ready.
