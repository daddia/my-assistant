# Eval automation (MA11)

Registers proof-harness domains for rule-based scoring and CI smoke runs.

| File | Purpose |
| ---- | ------- |
| [`manifest.yaml`](./manifest.yaml) | Domain registry (inbox registered by MA12) |
| [`score_inbox.py`](./score_inbox.py) | Rule-based golden validator + results scorer |

**Inbox domain (MA12):** 39-thread corpus, ≥ 90% pass threshold, smoke ids in manifest.

```bash
# CI structural check (no agent session required)
python3 evals/automation/score_inbox.py --validate-goldens

# Score a manual eval run (eval-run-results.yaml with per-thread pass/partial/fail)
python3 evals/automation/score_inbox.py --results path/to/eval-run-results.yaml
```

Until the MA11 runner exists, use manual workflow in [`../README.md`](../README.md) and [`../rubric/triage-accuracy.md`](../rubric/triage-accuracy.md).
