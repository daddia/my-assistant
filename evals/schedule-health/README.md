# Schedule health fixtures

Synthetic working-folder health ledgers for miss-detection smoke tests and schema validation. Maintainer docs: [`.agency/work/always-on/`](../../.agency/work/always-on/) (design).

**Schema:** [`scheduled/schedules.schema.yaml`](../../scheduled/schedules.schema.yaml)  
**Catalog:** [`scheduled/schedules.yaml`](../../scheduled/schedules.yaml)

## Copy into a test working folder

```bash
WORK=/tmp/my-assistant-schedule-health-test
mkdir -p "$WORK/scheduled"

# Missed morning brief (sh-02 smoke)
cp evals/schedule-health/fixtures/sh-02-missed-morning-brief/*.yaml "$WORK/scheduled/"
```

Then run `/assistant:brief` on a weekday after 09:30 local — the **Schedule health** block should appear with "Missed", `morning-briefing`, and `managed-agents/morning-briefing`.

For the healthy case:

```bash
cp evals/schedule-health/fixtures/sh-01-healthy-weekday/*.yaml "$WORK/scheduled/"
# Ensure brief-2026-07-08.md exists in $WORK if testing artefact presence
```

The health block must **not** appear.

## Smoke subset

| Fixture | Expectation |
| ------- | ----------- |
| `sh-01-healthy-weekday` | No miss block on `/assistant:brief` |
| `sh-02-missed-morning-brief` | Miss block surfaces; no auto catch-up |

## Decision-tree review checklist

Human review when changing setup copy:

- [ ] Local default stated before managed option
- [ ] Cost caveat from `managed-agents/README.md` present when recommending managed
- [ ] Jobs without cookbooks name `cloud-code` path
- [ ] No language implying My Assistant hosts schedules

## Schema validation

Structural validation runs in `./evals/scripts/validate-fixtures.sh` (CI on every PR).
