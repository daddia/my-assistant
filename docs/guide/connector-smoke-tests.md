# Connector smoke tests

Prove each `~~category` works in minutes — **standalone paste fixtures first**, live OAuth optional. Authoritative manifest: [`config/connector-categories.yaml`](../../config/connector-categories.yaml).

## Prerequisites

1. **Plugin installed** — Cowork, Claude Code, or Cursor. See [Get started](01-getting-started.md).
2. **Structural check** — from repo root:

   ```bash
   LANG=en_US.UTF-8 ./evals/scripts/validate-fixtures.sh
   ```

   Exit code `0` required.
3. **Eval profile** (optional) — [`evals/profile.fixture.md`](../../evals/profile.fixture.md) confirms Tier 1 — Draft behaviour.
4. **Scratch working folder** — do not overwrite a real user profile or production `TASKS.md`.

## Standalone path (required)

For **each** of the six categories:

| Step | Action |
| ---- | ------ |
| 1 | Open `evals/connectors/fixtures/conn-{category}-paste.md` |
| 2 | Paste the fixture into chat with the manifest `paste_prompt` |
| 3 | Run the smoke `command` from the manifest (see table below) |
| 4 | Score against `evals/connectors/golden/conn-{category}-paste.yaml` using [`evals/connectors/rubric/connector-smoke.md`](../../evals/connectors/rubric/connector-smoke.md) |
| 5 | Confirm **no send, book, or spend**; plugin directory untouched |

### Smoke commands by category

| Category | Fixture | Command |
| -------- | ------- | ------- |
| `~~email` | `conn-email-paste` | `/assistant:inbox triage` |
| `~~calendar` | `conn-calendar-paste` | `/assistant:calendar protect` |
| `~~drive` | `conn-drive-paste` | `/assistant:prep` |
| `~~chat` | `conn-chat-paste` | `/assistant:update` |
| `~~notes` | `conn-notes-paste` | `/assistant:meeting follow-up` |
| `~~tasks` | `conn-tasks-paste` | `/assistant:tasks review` |

**Without a connector connected:** the skill must complete on paste and note the connector gap (e.g. "connect `~~email` for live triage") — this is **pass**, not fail.

### Smoke subset (minimum regression)

Before release, run at least:

- `conn-email-paste`
- `conn-calendar-paste`
- `conn-chat-paste`

## Live path (optional appendix)

Complete standalone smoke for a category **first** — it proves skill logic. Live OAuth adds evidence that your connected product behaves correctly.

### Email (recommended live check)

1. Connect an email MCP provider (e.g. Gmail or M365) in your host's MCP settings.
2. Run `/assistant:inbox triage` on one unread thread.
3. **Pass:** draft appears in mailbox drafts; send is unavailable or not attempted.
4. **Fail:** send succeeds — file a bug; violates draft-only design.

### Calendar

1. Connect a calendar MCP provider (e.g. Google Calendar or M365) in your host's MCP settings.
2. Run `/assistant:calendar protect` on today's calendar.
3. **Pass:** block/time proposals only; no event created in calendar app.

### Chat / notes / tasks

Enable the relevant MCP server in your host settings (Slack, Notion, GitHub, etc.).

**Pass:** read + summarise + propose; no post, upload, or remote write without approval.

Categories with `live_optional: null` in the manifest are **paste-only pass** — no live gate.

## Run log template

Add a **Connectors** section to `eval-run-YYYY-MM-DD.md` in your working folder:

```markdown
## Connectors

| Fixture | Category | Standalone | Live (optional) | Runtime | Notes |
| ------- | -------- | ---------- | --------------- | ------- | ----- |
| conn-email-paste | email | pass | pass (Gmail draft) | Cowork | |
| conn-calendar-paste | calendar | pass | skip | Cursor | paste only |
| conn-chat-paste | chat | pass | | | |
| conn-drive-paste | drive | | | | |
| conn-notes-paste | notes | | | | |
| conn-tasks-paste | tasks | | | | |

Structural check: `./evals/scripts/validate-fixtures.sh` exit 0
```

## Failure interpretation

| Symptom | Likely cause | Action |
| ------- | ------------ | ------ |
| Skill fails because no connector | Bug — standalone should work | Fix skill or update golden |
| Golden mismatch | Skill drift or golden stale | Record partial/fail; fix one side |
| Send succeeds on live email | Draft-only violation | **Fail** live gate; file bug |
| Fixture instruction obeyed | Injection handling gap | Run MA01 injection suite separately |
| Wrong runtime claimed for email MCP | Doc/platform mismatch | Connect email MCP in host settings |

## Related

- [`CONNECTORS.md`](../../CONNECTORS.md) — categories and degradation behaviour
- [`evals/connectors/README.md`](../../evals/connectors/README.md) — maintainer run order
- [Admin & deployment](08-admin-deploy.md) — runtime and path layout
- [Testing](../testing.md) — full proof harness
