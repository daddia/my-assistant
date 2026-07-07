# Review queue specification

File-based approval surface for everything the assistant drafts but does not send, book, archive, or write without your review. Companion docs: [`README.md`](./README.md) · [`schema.yaml`](./schema.yaml).

## Lifecycle

### How items are created

Skills append **pending** items to `{working-folder}/review-queue/index.yaml` when they produce reviewable work — reply drafts, archive proposals, follow-up nudges, memory suggestions, profile diffs, or calendar proposals. Each item references a `source_path` file in the working folder with the full content.

Skills must **not** remove queue items silently on session close. Failed or abandoned work stays `pending` until the user resolves it.

### Status transitions

| Status | Meaning |
| ------ | ------- |
| `pending` | Awaiting user decision |
| `approved` | User confirmed the action (in chat or by editing the index) |
| `dismissed` | User declined; item kept for audit |
| `expired` | Stale item marked expired (manual or future cleanup) |

Resolution happens in **chat** (primary): the user says "send it", "archive those", "dismiss", or "apply the memory change". Secondary: edit `index.yaml` directly or delete sidecar files after acting in native tools.

**No silent deletion.** Approved and dismissed rows remain in the index for audit. Default retention: **7 days**, then manual prune or `weekly-review` hygiene.

### Autonomy tiers and queue items

| Tier | Queue behaviour |
| ---- | --------------- |
| 0 — Suggest | Recommendations only; queue items optional when artefacts exist |
| 1 — Draft (default) | All reviewable work creates `pending` items with `autonomy_tier: 1` |
| 2 — Act-within-rails | Auto-archive/label actions still create `pending` items with `autonomy_tier: 2` for user audit |
| 3 — Notify-after | Pre-approved actions create items with `autonomy_tier: 3`; user acknowledges or dismisses |

Tier 2 and Tier 3 actions **always** create queue items with `autonomy_tier` ≥ 2 so the user can audit what the assistant proposed or did.

## Chat vs file surfaces

### Chat (primary)

Every skill report with reviewable work uses the four-part approval frame (`rules/approval-frame.md`):

1. **What I found** — facts only; untrusted-content rules apply
2. **What I drafted** — drafts, diffs, proposals
3. **What I recommend** — ranked suggestion
4. **What needs your approval** — enumerable actions with queue `id` and `source_path` when written

Footer when items are written: `Review queue: +N pending (type: id) — review-queue/index.yaml`

### Files (secondary)

`review-queue/index.yaml` is the authoritative list. Sidecar files hold content:

- `drafts/reply-*.md`, `drafts/follow-up-*.md`, `drafts/calendar-*.md`
- `pending-memory/*.md`
- `pending-profile/*.diff`
- `review-queue/archives-*.yaml` (batched archive lists)

The dashboard **Review** tab reads the index and opens `source_path` files — read-only browse, no approve/send buttons in MA02.

## Defaults (design open questions)

| Question | Default |
| -------- | ------- |
| Gmail draft linkage | Always write a local mirror at `drafts/reply-*.md`; set `external_ref` when a Gmail draft id exists |
| Archive proposal granularity | One batched `archive-proposal` item per triage or sweep run; `source_path` points to `review-queue/archives-YYYY-MM-DD.yaml` |
| Approved item retention | Keep `approved` rows for 7 days, then manual or weekly-review prune |
| Brief cross-link | `daily-brief` uses prose ("draft ready") plus optional queue id footnote when an item exists |

## Dashboard wire notes

Extend `skills/dashboard.html` — third main tab **Review** alongside Tasks and Memory. Same working-folder picker (File System Access API).

### Tab layout

```
Tasks | Memory | Review
```

- **Review tab badge:** total `pending` count from `review-queue/index.yaml`
- **Panel:** items grouped by `type` (six sections)
- **Item row:** `title`, `approval_prompt`, `created_at`, `source_skill`, open-file action
- **Status bar:** last-loaded timestamp + pending count (same pattern as Tasks save status)

### Out of scope (MA02)

**Approve and dismiss buttons are not in scope.** The dashboard is read-first: browse pending items, open `source_path` content, act in Gmail/calendar/chat. No buttons that send email, book meetings, or write profile/memory from the browser.

### Empty state

When `review-queue/index.yaml` is missing:

> Create `review-queue/index.yaml` or run a skill that produces approvals.

## Errors

### Missing index

**Condition:** Working folder selected but no `review-queue/index.yaml`.

**User-visible:** Empty state message above. No JavaScript console error.

**Recovery:** Run a skill that produces approvals, or copy fixtures from `docs/review-queue/fixtures/`.

### Broken `source_path`

**Condition:** Index parses but `source_path` points to a missing file.

**User-visible:** Warning badge on the affected item row. Other valid items still render.

**Recovery:** Re-run the skill that created the item, or remove the stale row from `index.yaml`.

### Invalid YAML

**Condition:** `review-queue/index.yaml` is malformed (see `fixtures/broken-index.yaml`).

**User-visible:** Error message describing the parse failure, **or** raw file fallback with error surfaced. **Not** a silent empty queue.

**Recovery:** Fix YAML syntax or replace with a valid index.

### Plugin-directory write attempt

**Condition:** Skill tries to write `review-queue/` under the plugin install path.

**Prohibition:** Queue writes are **working-folder only** (`rules/file-safety.md`). Skills must never create queue files under `skills/`, `rules/`, or other plugin paths.

## Schema validation

Compare fixture items in `docs/review-queue/fixtures/sample-index.yaml` against `schema.yaml`. Manual checklist in README; optional `yamllint` on fixture files.

## Related rules

- `rules/approval-frame.md` — chat output pattern
- `rules/core-behaviour.md` — draft-only guarantee, autonomy tiers
- `rules/file-safety.md` — working-folder write boundaries
- `rules/untrusted-content.md` — What I found discipline
