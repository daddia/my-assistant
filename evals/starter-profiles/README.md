# Starter profiles — validation scope

Structural checks for `config/starter-profiles/` and `examples/before-after/` run as part of:

```bash
LANG=en_US.UTF-8 ./evals/scripts/validate-fixtures.sh
```

## What is validated

- Every entry in [`config/starter-profiles/manifest.yaml`](../../config/starter-profiles/manifest.yaml) has a readable profile file
- All `required_sections` from the manifest appear in each starter
- Word count per starter ≤ `max_words`
- Fictional-only domain allowlist (no real personal email domains)
- Every entry in [`examples/before-after/manifest.yaml`](../../examples/before-after/manifest.yaml): corpus, golden, generic, and starter paths exist
- Generic drafts contain ≥2 items from `generic_violations`

## What is not validated (manual / MA11)

- LLM-as-judge scoring of profile-tuned drafts against goldens
- Voice quality or persona differentiation (human review)

## Gallery

Visitor-facing index: [`examples/README.md`](../../examples/README.md)

## Eval persona unchanged

Proof harness evals continue to use [`evals/profile.fixture.md`](../profile.fixture.md) (Alex Rivera). Starters are additional onboarding personas.
