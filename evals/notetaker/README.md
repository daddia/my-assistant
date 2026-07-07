# Notetaker eval corpus — meeting-follow-up import

Manual evals for **notetaker import**: format detection, structured extraction, follow-up drafts, and injection defence. Extends the MA01 proof harness — no live connectors or real user data.

## Prerequisites

Same as [`evals/README.md`](../README.md): plugin installed, fresh session, [`profile.fixture.md`](../profile.fixture.md) loaded, structural check passing:

```bash
LANG=en_US.UTF-8 ./evals/scripts/validate-fixtures.sh
```

## Run order

1. **Load profile** — confirm Alex Rivera eval persona.
2. **For each fixture** in [`manifest.yaml`](./manifest.yaml):
   - Paste [`fixtures/{id}.md`](./fixtures/) into chat.
   - Invoke `/assistant:meeting follow-up` (or natural language: "follow up on that meeting").
3. **Score** against [`golden/{id}.yaml`](./golden/) using [`rubric/follow-up-extraction.md`](./rubric/follow-up-extraction.md).
4. **Confirm** draft-only behaviour, approval frame, and queue writes per golden `queue_items_min` / `drafts_expected`.
5. **Injection** — after smoke fixtures, run `nt-07-injection-heavy` and re-run [`inj-08`](../injection/fixtures/inj-08-transcript-action-items.md); compare to [`injection/expected-behaviour.yaml`](../injection/expected-behaviour.yaml).

## Smoke subset (5 fixtures)

| Fixture | Format family | Golden |
| ------- | ------------- | ------ |
| `nt-01-granola-product-sync` | Granola | [golden](./golden/nt-01-granola-product-sync.yaml) |
| `nt-03-otter-standup` | Otter | [golden](./golden/nt-03-otter-standup.yaml) |
| `nt-05-hand-typed-brain-dump` | Hand-typed baseline | [golden](./golden/nt-05-hand-typed-brain-dump.yaml) |
| `nt-06-ambiguous-owners` | Ambiguity | [golden](./golden/nt-06-ambiguous-owners.yaml) |
| `nt-07-injection-heavy` | Injection | [golden](./golden/nt-07-injection-heavy.yaml) |

## Run-log section

Add a **Notetaker import** table to `eval-run-YYYY-MM-DD.md`:

```markdown
## Notetaker import

| Fixture id | Format | Extraction | Drafts | Queue | Injection | Notes |
| ---------- | ------ | ---------- | ------ | ----- | --------- | ----- |
| nt-01-granola-product-sync | granola | pass / partial / fail | | | n/a | |
| nt-03-otter-standup | otter | | | | n/a | |
| nt-05-hand-typed-brain-dump | hand-typed | | | | n/a | |
| nt-06-ambiguous-owners | granola | | | | n/a | |
| nt-07-injection-heavy | granola | | | | pass / fail | |
```

## Related

- [`config/notetaker-formats.yaml`](../../config/notetaker-formats.yaml) — format fingerprints
- [`skills/meeting-follow-up/SKILL.md`](../../skills/meeting-follow-up/SKILL.md) — import mode
- [`commands/meeting.md`](../../commands/meeting.md) — `/assistant:meeting follow-up`
- [MA04 design](../../.agency/work/notetaker-import/design.md)

**Language:** English-first corpus. Multilingual exports deferred unless fixtures are added.
