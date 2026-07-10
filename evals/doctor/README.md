# Install doctor fixtures

Synthetic install states and golden expected reports for `/assistant:doctor` structural regression. Maintainer design: [`.agency/work/onboarding-polish/`](../../.agency/work/onboarding-polish/).

**Checklist:** [`config/doctor-checklist.yaml`](../../config/doctor-checklist.yaml)  
**Report schema:** [`config/doctor-report.schema.yaml`](../../config/doctor-report.schema.yaml)  
**Skill:** [`skills/install-doctor/SKILL.md`](../../skills/install-doctor/SKILL.md)

## Fixture matrix

| Fixture | Scenario |
| ------- | -------- |
| `fx-no-profile` | No profile; empty working folder |
| `fx-quick-start-profile` | Post quick-start interview; thin VIP/calendar (`post-setup-subset`) |
| `fx-full-profile` | Complete profile + scaffolded working folder |
| `fx-folder-scaffold` | Profile OK; missing `TASKS.md` and `memory/` |
| `fx-schedule-healthy` | Healthy `schedules/index.yaml` |
| `fx-schedule-missed-local` | `morning-briefing` local with `miss_count_7d >= 2` |
| `fx-cursor-platform` | Cursor + local critical job — platform and escalation warns |

Golden reports are **structural** (check IDs + statuses + fix_ref), not LLM-judged prose.

## Manual smoke

1. Copy a fixture profile to your test profile path (or paste in chat).
2. Point the working folder at the fixture `working/` subdirectory.
3. Run `/assistant:doctor` and compare check statuses to the matching golden file in `golden/`.

Post-setup subset: run `/assistant:setup` quick-start against `fx-quick-start-profile` — confirm the **Setup health** block appears before the inbox/brief wedge.

## Schema validation

Structural validation runs in `./evals/scripts/validate-fixtures.sh` (CI on every PR). The script asserts:

- Every `check_id` in `doctor-checklist.yaml` appears in at least one golden report
- Golden `summary` counts match `results` status tallies
- Fixture files and working-folder paths exist

## Checklist versioning

Doctor is stateless — new checks ship with plugin updates. Re-run `/assistant:doctor` after `/plugin update` to pick up new checklist rows. No migration of saved reports is required.
