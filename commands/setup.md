---
description: Configure the assistant — a 10-minute interview that writes your profile
  (identity, voice, VIP tiers, email and calendar policy, autonomy tier).
---

## Preflight

- **Profile** — Check whether `~/.claude/plugins/config/my-assistant/profile.md` (or workspace `profile.md`) already exists. If so, confirm whether the user wants to update or start fresh.
- **Working folder** — Confirm where post-setup health output may be written. Note if the folder is read-only.
- **Connectors** — Advisory only; note which connectors the user plans to connect after setup.
- **Autonomy tier** — Explain tiers during the interview; default to Tier 1 — Draft unless the user chooses otherwise.

## Plan

- Run `skills/setup-interview/SKILL.md`.
- Offer 2-minute quick-start, a starter profile, or the full 10-minute interview.
- Write the profile to `~/.claude/plugins/config/my-assistant/profile.md` (outside the plugin). Run post-setup health subset; do not overwrite an existing profile without confirmation.

## Commands

Run the onboarding interview. Read and follow `skills/setup-interview/SKILL.md`.

Offer a 2-minute quick-start or the full 10-minute interview. Write the profile to `~/.claude/plugins/config/my-assistant/profile.md` (outside the plugin, so updates don't overwrite it). Confirm each section as you go, run the post-setup health subset, then point the user at `/assistant:inbox triage`, `/assistant:brief`, and `/assistant:doctor` for a full check.

## Verification

- Re-read the written profile — confirm identity, voice, VIP tiers, email/calendar policy, and autonomy tier are complete.
- Confirm the profile was written outside the plugin directory.
- Surface write failures (permissions, read-only config path) clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: setup interview
- **Status**: success | partial | failed
- **Details**: profile path, interview mode (quick-start | starter | full)
```

## Next Steps

- Run `/assistant:doctor` for a full install health check.
- Run `/assistant:inbox triage` or paste a demo thread from `examples/`.
- Run `/assistant:brief` for a morning briefing.
- Connect tools via Cowork → Settings → Connectors when ready.
