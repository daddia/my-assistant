---
description: Run an install-and-setup health check — profile, working folder, schedules,
  connectors (advisory), and platform fit. Prints a scannable pass / warn / fail / skip report
  with concrete fix steps.
---

Run the install doctor. Read and follow `skills/install-doctor/SKILL.md`.

Parse `$ARGUMENTS`:

- **`--save`** — after rendering the report in chat, also write `doctor-report-YYYY-MM-DD.md` to the working folder (only when the folder is writable; otherwise note the save failure and keep chat output).
- **No flags** — chat report only (default; no unsolicited file writes).

Resolve profile and working folder, load `config/doctor-checklist.yaml`, run all checks, and render the markdown report with fix links. Never mutate profile, plugin files, or working-folder state unless the user explicitly asks outside this command.
