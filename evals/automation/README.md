# Eval automation (MA11)

Registers proof-harness domains for rule-based scoring and CI smoke runs.

| File | Purpose |
| ---- | ------- |
| [`manifest.yaml`](./manifest.yaml) | Domain registry (inbox, draft, feedback) |
| [`score_inbox.py`](./score_inbox.py) | Inbox triage golden validator + results scorer |
| [`score_draft.py`](./score_draft.py) | Draft quality golden validator + rule-based scorer (MA13) |
| [`score_feedback.py`](./score_feedback.py) | Feedback loop golden validator + rule-based scorer (MA13) |

**Inbox domain (MA12):** 44-thread corpus, ≥ 90% pass threshold, smoke ids in manifest.

**Draft domain (MA13):** ≥ 18 draft goldens, ≥ 90% pass on `draft_required` threads, rule checks for `must_not_contain`, `max_sentences`, grounding, variants.

**Feedback domain (MA13):** ≥ 3 profile-diff goldens with full `hunk_specs` (fb-03, fb-04, fb-05); smoke 5/5 pass.

```bash
# CI structural checks (no agent session required)
python3 evals/automation/score_inbox.py --validate-goldens
python3 evals/automation/score_draft.py --validate-goldens
python3 evals/automation/score_feedback.py --validate-goldens

# Score manual eval run logs
python3 evals/automation/score_draft.py --results path/to/eval-run-draft-results.yaml
python3 evals/automation/score_feedback.py --results path/to/eval-run-feedback-results.yaml
```

Manual workflow remains authoritative until agent-output CI is green — see [`../README.md`](../README.md) and rubrics under [`../rubric/`](../rubric/).
