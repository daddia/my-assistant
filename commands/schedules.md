---
description: Set up the packaged Cowork scheduled tasks — morning briefing, inbox
  sweep, meeting-prep watcher, follow-up watcher, weekly review.
---

## Preflight

- **Profile & paths** — Resolve per `rules/paths.md`. If missing, note it and offer `/assistant:setup` before scheduling jobs that depend on personalisation.
- **Working folder** — Confirm where `scheduled/{job_id}.yaml` will be initialised. Note if the folder is read-only.
- **Connectors** — Advisory only; note which `~~category` connectors each scheduled job will use when the machine is awake.
- **Autonomy tier** — Read the configured tier from the profile (default: Tier 1 — Draft). Scheduled jobs draft only — never send, book, or spend.

## Plan

- Run `skills/schedule-setup/SKILL.md`.
- Walk the decision tree from `scheduled/schedules.yaml` — default `local`, offer `cloud-code` or `managed` per job when sleep is a problem.
- Initialise `scheduled/{job_id}.yaml` (one file per job); hand copy-paste prompts and cadences from the catalog. State caveats up front (machine awake, tool pre-approval, quota).

## Commands

Walk the user through creating scheduled tasks. Read and follow `skills/schedule-setup/SKILL.md`.

State the three caveats up front (machine must be awake on local surface, pre-approve tools, quota use). Walk the **decision tree** from `scheduled/schedules.yaml` — default `local`, offer `cloud-code` or `managed` per job when sleep is a problem. Initialize one file per job under `scheduled/` in the working folder with chosen surfaces. Offer the full set or the minimal starter (morning briefing + inbox sweep). Hand them each copy-paste prompt and cadence from the catalog. Link `docs/guide/07-always-on-reliability.md` for the full reliability story.

## Verification

- Re-read `scheduled/` — confirm chosen jobs and surfaces match the plan.
- Confirm no scheduled prompts were created that send, book, or spend without review.
- Surface platform limitations (sleeping laptop, missing pre-approvals) clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: schedule setup
- **Status**: success | partial | failed
- **Details**: jobs configured, surfaces chosen, schedules ledger initialised
```

## Next Steps

- Confirm heartbeats appear in `scheduled/{job_id}.yaml` after the first run.
- Run `/assistant:health` to verify schedule health.
- See `managed-agents/` for always-on cookbooks when local scheduling is unreliable.
