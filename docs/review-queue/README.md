# Review queue

File-based approval surface for everything the assistant drafts but does not send, book, archive, or write without your review. Skills append **pending** items to `review-queue/index.yaml` in your **working folder**; you approve or dismiss in chat (primary) or by editing the index and sidecar files.

Full specification: [`spec.md`](./spec.md) (MA02-02). Machine-readable shape: [`schema.yaml`](./schema.yaml).

## Six queue types

| `type` | What awaits approval | Typical `source_path` |
| ------ | -------------------- | --------------------- |
| `reply-draft` | Email or message reply not yet sent | `drafts/reply-*.md` |
| `archive-proposal` | Threads proposed for archive | `review-queue/archives-*.yaml` |
| `follow-up-nudge` | Cold-thread nudge draft | `drafts/follow-up-*.md` |
| `memory-suggestion` | Proposed `CLAUDE.md` or `memory/` change | `pending-memory/*.md` |
| `profile-diff` | Proposed change to `profile.md` | `pending-profile/*.diff` |
| `calendar-proposal` | Proposed times or invite draft | `drafts/calendar-*.md` |

Every item requires: `id`, `type`, `status`, `created_at`, `source_skill`, `title`, `source_path`, `approval_prompt`, `autonomy_tier`. Optional: `priority`, `external_ref`, `related_ids`, `resolved_at`. See [`schema.yaml`](./schema.yaml).

## Working-folder layout

Queue files live in your **working folder** — the same directory you use for `TASKS.md`, briefs, and drafts — **not** inside the plugin install directory.

```text
{working-folder}/
  review-queue/
    index.yaml              # authoritative list of pending items
  drafts/                   # reply, follow-up, calendar drafts
  pending-memory/           # proposed memory writes
  pending-profile/          # proposed profile diffs
  brief-YYYY-MM-DD.md
  TASKS.md
```

**Important:** Skills and the dashboard must **never** write `review-queue/` under the plugin path (`skills/`, `rules/`, etc.). User data belongs in the working folder or profile directory only (`rules/file-safety.md`). Plugin updates overwrite the install directory.

## Fixtures — copy into a test working folder

Use the synthetic fixtures for dashboard smoke tests and schema validation before running live skills.

### 1. Create folder structure

In a scratch working folder:

```bash
WORK=/tmp/my-assistant-review-queue-test
mkdir -p "$WORK/review-queue" "$WORK/drafts" "$WORK/pending-memory" "$WORK/pending-profile"
```

### 2. Copy the sample index

```bash
cp docs/review-queue/fixtures/sample-index.yaml "$WORK/review-queue/index.yaml"
```

(Path assumes repo root; adjust if your cwd differs.)

### 3. Copy companion source files

Copy everything under `docs/review-queue/fixtures/sources/` into the working folder, preserving relative paths:

```bash
cp -R docs/review-queue/fixtures/sources/drafts "$WORK/"
cp -R docs/review-queue/fixtures/sources/pending-memory "$WORK/"
cp -R docs/review-queue/fixtures/sources/pending-profile "$WORK/"
cp docs/review-queue/fixtures/sources/review-queue/archives-2026-07-08.yaml "$WORK/review-queue/"
```

After copy, every `source_path` in `index.yaml` must resolve to a real file under the working folder. The fixture index includes **one pending item per queue type** (six items total).

### 4. Open the dashboard Review tab

1. Open `skills/dashboard.html` from the plugin directory in Chrome or Edge.
2. Select your test working folder (`$WORK`).
3. Switch to the **Review** tab — you should see six queue groups with pending items.
4. Open any item to confirm `source_path` content matches `title` / `approval_prompt`.

## Run a skill and verify queue items

1. Copy MA01 eval fixtures into a test working folder (profile + corpus thread).
2. Run `/assistant:inbox triage` on `evals/corpus/threads/01-vip-board-update.md`.
3. Confirm chat output includes all four approval-frame headings (`rules/approval-frame.md`).
4. Verify `review-queue/index.yaml` gains at least one `pending` `reply-draft` item.
5. Refresh the dashboard Review tab — new item appears with matching `source_path`.
6. Confirm no email is sent and no profile file is written without explicit user confirmation.

## Definition of Done (epic MA02)

- [ ] All eight tasks' Gherkin scenarios pass via manual verification
- [ ] Fixture folder renders all six queue types in dashboard Review tab without console errors
- [ ] All 12 skills contain an Approval frame subsection linking `rules/approval-frame.md`
- [ ] No approve/send/book buttons in dashboard; no queue files written under plugin directory
- [ ] PR reviewed and merged

### Quick verification commands

```bash
# Schema + fixtures
LANG=en_US.UTF-8 ./evals/scripts/validate-fixtures.sh

# All skills link approval frame
grep -l 'approval-frame.md' skills/*/SKILL.md | wc -l   # expect 12

# Entry-point links
grep -r 'docs/review-queue' AGENTS.md README.md docs/guide/03-skills-and-commands.md
```

## Manual verification notes (MA01 corpus)

**Thread:** `evals/corpus/threads/01-vip-board-update.md`  
**Profile:** `evals/profile.fixture.md`

Expected after `/assistant:inbox triage` with queue-writing enabled:

- Chat uses `## What I found`, `## What I drafted`, `## What I recommend`, `## What needs your approval`
- `review-queue/index.yaml` contains `reply-draft` (and optionally `archive-proposal`) items
- `drafts/reply-*.md` local mirror exists for each reply draft
- Footer: `Review queue: +N pending (…) — review-queue/index.yaml`
- No send/book/write without user confirmation

## Schema validation checklist

Compare [`fixtures/sample-index.yaml`](./fixtures/sample-index.yaml) items against [`schema.yaml`](./schema.yaml):

- [ ] Exactly six `type` values appear in the schema enum
- [ ] Every item has all required fields with correct types
- [ ] Every `source_path` in the sample index exists under `fixtures/sources/` at the same relative path
- [ ] `autonomy_tier` is an integer 0–3; `status` is one of `pending`, `approved`, `dismissed`, `expired`

Optional: run `yamllint docs/review-queue/fixtures/sample-index.yaml` for syntax checks.

## Error-path fixtures

Manual verification for dashboard and parser error handling (design §3.3).

### Invalid YAML — `fixtures/broken-index.yaml`

**Path:** `docs/review-queue/fixtures/broken-index.yaml`

**How to test:** Copy to a scratch working folder as `review-queue/index.yaml`:

```bash
cp docs/review-queue/fixtures/broken-index.yaml "$WORK/review-queue/index.yaml"
```

**Expected behaviour:** The dashboard Review tab (or any YAML parser loading the index) must **not** show a silent empty queue. Instead:

- Display an **error message** describing the parse failure (e.g. unclosed string), **or**
- Fall back to a **raw file view** with the error surfaced in the UI.

The user should see that the index failed to load — not "No pending items."

### Broken `source_path` (documented; no separate fixture file)

If `index.yaml` parses but an item's `source_path` points to a missing file:

- The item row shows a **warning badge**.
- Other valid items still render.
- Fix: re-run the skill that created the item, or remove the stale row from `index.yaml`.

### Missing index

If `review-queue/index.yaml` does not exist:

- Empty state: *"Create `review-queue/index.yaml` or run a skill that produces approvals."*

### Plugin-directory write attempt

Skills must never create `review-queue/` under the plugin install path. Queue writes are **working-folder only**.

---

See also: [`spec.md`](./spec.md) · [`schema.yaml`](./schema.yaml) · [`rules/approval-frame.md`](../../rules/approval-frame.md)
