# Calendar eval corpus — time protection + scheduling

Manual evals for **proactive time protection** and **scheduling accuracy**: violation detection, block proposals, rejected-slots clarity, queue integration, and injection defence. Extends the MA01 proof harness — no live connectors or real user data.

## Prerequisites

Same as [`evals/README.md`](../README.md): plugin installed, fresh session, [`profile.fixture.md`](../profile.fixture.md) loaded (includes **Habit blocks** row for `cal-09`), structural check passing:

```bash
LANG=en_US.UTF-8 ./evals/scripts/validate-fixtures.sh
```

## Run order

### Protect fixtures (`mode: protect` or default)

1. **Load profile** — confirm Alex Rivera eval persona with moderate focus defence (override assertive for `cal-10`), 15 min buffer, 09:00–10:00 protected window, prep/follow-up durations, Morning review habit.
2. **For each protect fixture** in [`manifest.yaml`](./manifest.yaml) with `mode: protect`:
   - Paste [`fixtures/{id}.md`](./fixtures/) into chat.
   - Invoke `/assistant:calendar protect` (or natural language: "protect my calendar").
3. **Score** against [`golden/{id}.yaml`](./golden/) using [`rubric/time-protection.md`](./rubric/time-protection.md).
4. **Confirm** draft-only behaviour, unified approval frame, violation summary table, and queue writes per golden.

### Schedule fixtures (`mode: schedule`)

1. **For each schedule fixture** (`cal-07`, `cal-08`, `cal-11`):
   - Paste fixture into chat.
   - Invoke `/assistant:calendar schedule`.
2. **Score** against golden using [`rubric/scheduling-accuracy.md`](./rubric/scheduling-accuracy.md).
3. **Confirm** proposed + rejected slot tables, timezone in offers, and `drafts/calendar-*.md` reply drafts.

### Injection

`cal-06-invite-injection` must refuse embedded scheduling commands while still detecting buffer gaps.

## Smoke subset (5 fixtures — CI)

| Fixture | Mode | Scenario | Golden |
| ------- | ---- | -------- | ------ |
| `cal-01-back-to-back-day` | protect | Buffer gaps | [golden](./golden/cal-01-back-to-back-day.yaml) |
| `cal-03-focus-intrusion` | protect | Focus window overlap | [golden](./golden/cal-03-focus-intrusion.yaml) |
| `cal-04-healthy-day` | protect | No violations | [golden](./golden/cal-04-healthy-day.yaml) |
| `cal-06-invite-injection` | protect | Injection + buffers | [golden](./golden/cal-06-invite-injection.yaml) |
| `cal-08-schedule-conflicts` | schedule | Rejected-slots table | [golden](./golden/cal-08-schedule-conflicts.yaml) |

Schedule smoke minimum: **cal-07**, **cal-08** for MA14 close.

## Run-log sections

Add **Time protection** and **Scheduling** tables to `eval-run-YYYY-MM-DD.md`:

```markdown
## Time protection

| Fixture id | Violations | Proposals | Queue | Injection | Notes |
| ---------- | ---------- | --------- | ----- | --------- | ----- |
| cal-01-back-to-back-day | pass / partial / fail | | | n/a | |
| cal-03-focus-intrusion | | | | n/a | |
| cal-04-healthy-day | | | | n/a | |
| cal-06-invite-injection | | | | pass / fail | |
| cal-09-habit-gap | | | | n/a | |
| cal-10-assertive-focus-defence | | | | n/a | |

## Scheduling

| Fixture id | Slots | Rejected | Draft | Queue | Notes |
| ---------- | ----- | -------- | ----- | ----- | ----- |
| cal-07-schedule-slot-offer | pass / partial / fail | n/a | | | |
| cal-08-schedule-conflicts | | | | | |
| cal-11-schedule-timezone | | | | | |
```

## Related

- [`config/calendar.yaml`](../../config/calendar.yaml) — block type definitions (including `habit`)
- [`skills/calendar-scheduling/SKILL.md`](../../skills/calendar-scheduling/SKILL.md) — protect + schedule modes
- [`commands/calendar.md`](../../commands/calendar.md) — `/assistant:calendar protect|schedule`
- [MA14 design](../../.agency/work/calendar-depth/design.md)

**Language:** English-first corpus. Multilingual calendar exports deferred unless fixtures are added.

**Epic close bar:** ≥ **90% Pass** on protect rubric, schedule rubric, and combined 11-fixture domain per [`evals/automation/manifest.yaml`](../automation/manifest.yaml).
