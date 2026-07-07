---
description: Set up the packaged Cowork scheduled tasks — morning briefing, inbox
  sweep, meeting-prep watcher, follow-up watcher, weekly review.
---

Walk the user through creating scheduled tasks. Read and follow `skills/schedule-setup/SKILL.md`.

State the three caveats up front (machine must be awake on local surface, pre-approve tools, quota use). Walk the **decision tree** from `config/schedule-catalog.yaml` — default `local`, offer `cloud-code` or `managed` per job when sleep is a problem. Initialize `schedule-health/index.yaml` in the working folder with chosen surfaces. Offer the full set or the minimal starter (morning briefing + inbox sweep). Hand them each copy-paste prompt and cadence from the catalog. Link `docs/guide/07-always-on-reliability.md` for the full reliability story.
