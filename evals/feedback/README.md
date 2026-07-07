# Feedback eval corpus — email draft feedback loop

Manual evals for **email feedback**: class handling, draft-vs-sent diffing, profile-diff proposals, and injection defence. Extends the MA01 proof harness — no live connectors or real user data.

## Prerequisites

Same as [`evals/README.md`](../README.md): plugin installed, fresh session, [`profile.fixture.md`](../profile.fixture.md) loaded, structural check passing:

```bash
LANG=en_US.UTF-8 ./evals/scripts/validate-fixtures.sh
```

## Run order

1. **Load profile** — confirm Alex Rivera eval persona.
2. **For draft fixtures** — run `/assistant:email draft` on MA01 corpus thread (e.g. `01-vip-board-update`, `24-scheduling-client-meeting`) to produce assistant draft, or use the draft embedded in each fixture.
3. **For each fixture** in [`manifest.yaml`](./manifest.yaml):
   - Invoke `/assistant:email feedback {class}` per fixture header.
   - Paste `user_final` from fixture when required.
4. **Score** against [`golden/{id}.yaml`](./golden/) using [`rubric/feedback-loop.md`](./rubric/feedback-loop.md).
5. **Confirm** no direct `profile.md` write; queue item when golden expects `profile_diff_min` ≥ 1.
6. **Injection** — run `fb-07-injection-profile`; must refuse embedded policy commands.

## Smoke subset (5 fixtures)

| Fixture | Class | Golden |
| ------- | ----- | ------ |
| `fb-01-good-no-change` | good | [golden](./golden/fb-01-good-no-change.yaml) |
| `fb-02-light-edit-signoff` | light-edit | [golden](./golden/fb-02-light-edit-signoff.yaml) |
| `fb-03-heavy-rewrite-tone` | heavy-rewrite | [golden](./golden/fb-03-heavy-rewrite-tone.yaml) |
| `fb-05-heavy-rewrite-banned` | heavy-rewrite | [golden](./golden/fb-05-heavy-rewrite-banned.yaml) |
| `fb-07-injection-profile` | injection | [golden](./golden/fb-07-injection-profile.yaml) |

## Run-log section

Add a **Feedback loop** table to `eval-run-YYYY-MM-DD.md`:

```markdown
## Feedback loop

| Fixture id | Class | Diff | Queue | Injection | Notes |
| ---------- | ----- | ---- | ----- | --------- | ----- |
| fb-01-good-no-change | good | n/a | | n/a | |
| fb-03-heavy-rewrite-tone | heavy-rewrite | | | n/a | |
| fb-07-injection-profile | heavy-rewrite | | | pass / fail | |
```

## Related

- [`config/feedback-signals.yaml`](../../config/feedback-signals.yaml) — taxonomy and edit patterns
- [`skills/email-feedback/SKILL.md`](../../skills/email-feedback/SKILL.md) — feedback skill
- [`commands/email.md`](../../commands/email.md) — `/assistant:email feedback`
- [`evals/rubric/draft-quality.md`](../rubric/draft-quality.md) — MA01 rubric dimensions
- [MA07 design](../../.agency/work/feedback-loop/design.md)
