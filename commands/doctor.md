---
description: Run an install-and-setup health check — profile, working folder, schedules,
  connectors (advisory), and platform fit. Prints a scannable pass / warn / fail / skip report
  with concrete fix steps.
---

## Preflight

- **Profile** — Locate `~/.claude/plugins/config/my-assistant/profile.md` (or workspace `profile.md`). Missing profile is a check result, not a blocker.
- **Working folder** — Resolve the working folder for `TASKS.md`, `schedule-health/`, and optional report output. Note if read-only.
- **Connectors** — Advisory scan of available `~~category` connectors; doctor does not require OAuth.
- **Autonomy tier** — Read from profile if present; include in report context only.

## Plan

- Run `skills/install-doctor/SKILL.md`.
- Parse `$ARGUMENTS`: `--save` writes `doctor-report-YYYY-MM-DD.md` to the working folder when writable; default is chat-only.
- Load `config/doctor-checklist.yaml`, run all checks, render pass/warn/fail/skip report with fix links. Read-only — never mutate profile, plugin files, or working-folder state.

## Commands

Run the install doctor. Read and follow `skills/install-doctor/SKILL.md`.

Parse `$ARGUMENTS`:

- **`--save`** — after rendering the report in chat, also write `doctor-report-YYYY-MM-DD.md` to the working folder (only when the folder is writable; otherwise note the save failure and keep chat output).
- **No flags** — chat report only (default; no unsolicited file writes).

Resolve profile and working folder, load `config/doctor-checklist.yaml`, run all checks, and render the markdown report with fix links. Never mutate profile, plugin files, or working-folder state unless the user explicitly asks outside this command.

## Verification

- Re-read the rendered report — confirm every checklist item has pass/warn/fail/skip with a concrete fix.
- Confirm no profile, plugin, or working-folder files were modified (except optional `--save` report).
- Surface checklist load failures or unreadable paths clearly.

## Summary

Present a concise result block:

```
## Result
- **Action**: install doctor
- **Status**: success | partial | failed
- **Details**: pass/warn/fail/skip counts, report path if --save
```

## Next Steps

- Fix any **fail** rows via `/assistant:setup`, `/assistant:schedules`, or the linked guide chapter.
- Re-run `/assistant:doctor` after plugin updates or connector changes.
- Run `/assistant:doctor --save` to keep a dated report in the working folder.
