# Connector smoke eval corpus

Standalone paste fixtures prove each `~~category` works **without live OAuth**. One fixture and golden per category; structural parity enforced by `validate-fixtures.sh`.

## Prerequisites

Same as [`evals/README.md`](../README.md): plugin installed, fresh session, optional [`profile.fixture.md`](../profile.fixture.md), structural check passing:

```bash
LANG=en_US.UTF-8 ./evals/scripts/validate-fixtures.sh
```

Canonical manifest: [`config/connectors.yaml`](../../config/connectors.yaml)

## Run order

1. **Structural check** — exit code `0` required.
2. **Load profile** (optional) — Alex Rivera eval persona confirms Tier 1 defaults.
3. **For each fixture** in [`manifest.yaml`](./manifest.yaml):
   - Open [`fixtures/conn-{category}-paste.md`](./fixtures/).
   - Paste into chat with the manifest `paste_prompt`.
   - Invoke the smoke `command` from the manifest.
4. **Score** against [`golden/`](./golden/) using [`rubric/connector-smoke.md`](./rubric/connector-smoke.md).
5. **Confirm global invariants** — no send, book, spend; plugin dir untouched.
6. **Record** pass | partial | fail in `eval-run-YYYY-MM-DD.md` **Connectors** table.

Full guide: [`docs/guide/connector-smoke-tests.md`](../../docs/guide/connector-smoke-tests.md).

## Smoke subset (3 categories)

Minimum regression before release:

| Fixture | Category | Command |
| ------- | -------- | ------- |
| `conn-email-paste` | `~~email` | `/assistant:inbox triage` |
| `conn-calendar-paste` | `~~calendar` | `/assistant:calendar protect` |
| `conn-chat-paste` | `~~chat` | `/assistant:update` |

## Documentation review checklist

- [`docs/guide/05-protect-privacy.md`](../../docs/guide/05-protect-privacy.md) readable without opening `security/threat-model.md`.
- [`docs/guide/08-admin-deploy.md`](../../docs/guide/08-admin-deploy.md) covers Cowork, Claude Code, and Cursor.
- Live OAuth steps in smoke guide clearly marked optional.
- Permission summary table matches `security/permissions.md` Tier 1 column.
- No duplicate of threat-model narrative — cite only.

## Related

- [Connector smoke guide](../../docs/guide/connector-smoke-tests.md)
- [Testing](../../docs/testing.md)
- [Trust artefacts design](../../.agency/work/trust-artefacts/design.md) — MA08
