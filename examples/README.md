# Examples gallery

See My Assistant in a realistic persona in minutes — no live mail, no profile from scratch.

**Evals vs starters:** The [proof harness](../evals/README.md) uses Alex Rivera ([`evals/profile.fixture.md`](../evals/profile.fixture.md)). Starter profiles below are for **onboarding and demos** only — they do not replace the eval persona.

## Visitor funnel

1. **Browse** — pick a persona and a before/after demo below
2. **Setup** — `/assistant:setup` → choose a starter (or blank interview)
3. **Try it** — paste a corpus thread → `/assistant:inbox triage` → `/assistant:email draft`
4. **Compare** — your draft vs the curated reference in `before-after/`

## Starter personas

| ID | ICP | Profile | Demo threads |
|----|-----|---------|--------------|
| `founder` | Early-stage CEO or co-founder | [`config/starter-profiles/founder.md`](../config/starter-profiles/founder.md) | 01, 04 |
| `consultant` | Independent advisor | [`config/starter-profiles/consultant.md`](../config/starter-profiles/consultant.md) | 01, 24 |
| `sales-lead` | Account executive / sales lead | [`config/starter-profiles/sales-lead.md`](../config/starter-profiles/sales-lead.md) | 04, 24 |
| `operator` | Chief of staff / ops lead | [`config/starter-profiles/operator.md`](../config/starter-profiles/operator.md) | 01, 04 |
| `investor` | Angel / micro-VC | [`config/starter-profiles/investor.md`](../config/starter-profiles/investor.md) | 01, 24 |

Canonical list: [`config/starter-profiles/manifest.yaml`](../config/starter-profiles/manifest.yaml)

## Workflows

| Walkthrough | What it covers |
|-------------|----------------|
| [Setup with a starter](./workflows/setup-with-starter.md) | Pick persona → quick customize → first triage |
| [Inbox triage (paste-only)](./workflows/inbox-triage-paste.md) | Paste corpus thread → triage → draft |
| [First run in 3 minutes](./workflows/first-run-three-minutes.md) | Quick demo script (Alex Rivera eval path) |

## Before/after demos

Side-by-side **generic AI** (what not to ship) vs **profile-tuned** reference drafts. Corpus threads are shared with [`evals/corpus/`](../evals/corpus/); goldens in [`evals/golden/drafts/`](../evals/golden/drafts/).

| Thread | Context | Demos |
|--------|---------|-------|
| [01 — VIP board update](./before-after/01-vip-board-update/) | Board pre-read deadline | generic + founder, consultant, operator, investor |
| [04 — Contract renewal](./before-after/04-needs-reply-contract-renewal/) | Commercial negotiation | generic + founder, sales-lead |

Manifest: [`before-after/manifest.yaml`](./before-after/manifest.yaml)

## Next steps

- [Getting started guide](../docs/guide/01-getting-started.md)
- [Configure your profile](../docs/guide/02-configure-profile.md)
- [Proof harness](../evals/README.md) — maintainer eval workflow
