# Eval automation (MA11)

Registers proof-harness domains for rule-based scoring and CI smoke runs.

| File | Purpose |
| ---- | ------- |
| [`manifest.yaml`](./manifest.yaml) | Domain registry (inbox registered by MA12) |

**Inbox domain (MA12):** 35-thread corpus, ≥ 90% pass threshold, smoke ids in manifest. Scorer implementation ships with MA11 (`evals/automation/` runner).

Until the MA11 runner exists, use manual workflow in [`../README.md`](../README.md) and [`../rubric/triage-accuracy.md`](../rubric/triage-accuracy.md).
