# Testing

My Assistant is validated in agent sessions, not a unit-test runner. Two layers:

## 1. Proof harness (manual evals)

The **proof harness** lives at [`evals/`](../evals/). It exercises inbox triage, draft quality, and prompt-injection defence against a synthetic corpus — no live connectors or real user data.

| Resource | Purpose |
| -------- | ------- |
| [`evals/README.md`](../evals/README.md) | Full run order, smoke subset, run-log template |
| [`evals/profile.fixture.md`](../evals/profile.fixture.md) | Synthetic eval profile |
| [`evals/corpus/`](../evals/corpus/) | 25 synthetic email threads |
| [`evals/golden/`](../evals/golden/) | Expected triage and draft outputs |
| [`evals/injection/`](../evals/injection/) | Attack fixtures + expected behaviour |
| [`evals/notetaker/`](../evals/notetaker/) | Notetaker import fixtures + golden extractions |
| [`evals/schedule-health/`](../evals/schedule-health/) | Schedule health ledger fixtures + miss-detection golden |
| [`evals/rubric/`](../evals/rubric/) | Manual scoring rubrics |

**Quick structural check** (from repo root):

```bash
LANG=en_US.UTF-8 ./evals/scripts/validate-fixtures.sh
```

This runs automatically on every pull request via GitHub Actions. Exit code `0` means manifests, golden files, and fixtures are structurally consistent.

**Smoke regression** (manual, ~30 minutes): five corpus threads plus the full injection suite. See [`evals/README.md`](../evals/README.md#smoke-subset).

**Notetaker import** (manual, ~20 minutes): five notetaker fixtures (`nt-01`, `nt-03`, `nt-05`, `nt-06`, `nt-07`) via `/assistant:meeting follow-up`. See [`evals/notetaker/README.md`](../evals/notetaker/README.md).

**Schedule health** (manual, ~10 minutes): copy `sh-02-missed-morning-brief` fixture to a test working folder, run `/assistant:brief` after 09:30 on a weekday — confirm miss block appears. Repeat with `sh-01-healthy-weekday` — no block. See [`evals/schedule-health/README.md`](../evals/schedule-health/README.md).

## 2. Skill and behaviour checks

For skill or rule changes:

1. Install the plugin locally.
2. Trigger the change via its slash command or a natural-language phrase matching the skill `description`.
3. Confirm drafts land in the right place and no skill sends, books, or spends. Check against [`rules/core-behaviour.md`](../rules/core-behaviour.md) and [`rules/file-safety.md`](../rules/file-safety.md).

## Related

- [Contributing — Testing](../CONTRIBUTING.md#testing)
- [Proof harness design](../.agency/work/proof-harness/design.md) — MA01 epic
- [Review queue design](../.agency/work/review-queue/design.md) — MA02 epic; fixtures at [`evals/review-queue/`](../evals/review-queue/)
- [Notetaker import design](../.agency/work/notetaker-import/design.md) — MA04 epic; corpus at [`evals/notetaker/`](../evals/notetaker/)
- [Always-on reliability design](../.agency/work/always-on/design.md) — MA06 epic; fixtures at [`evals/schedule-health/`](../evals/schedule-health/)
- [Eval automation (MA11)](../.agency/backlog.md) — planned automated regression runner
