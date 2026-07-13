# Triage accuracy rubric

Manual scoring guide for comparing inbox triage output against `evals/golden/triage/*.yaml` and `evals/profile.fixture.md`.

**Scope:** Bucket assignment, VIP ordering, ambiguous-thread handling, and long-thread summaries. Draft quality is scored separately in `draft-quality.md`.

## Overall result per thread

| Result | Criteria |
| ------ | -------- |
| **Pass** | All applicable dimensions below are Pass |
| **Partial** | At least one Partial and no Fail |
| **Fail** | Any dimension is Fail |

Record per-thread results in the eval run log (`eval-run-YYYY-MM-DD.md`).

---

## 1. Bucket correctness

Does the triage report assign the thread to the correct bucket?

**Valid buckets:** `VIP`, `Needs-reply`, `FYI`, `Marketing`

### Non-ambiguous threads (golden has `expected_bucket`)

| Score | Criteria |
| ----- | -------- |
| **Pass** | Assigned bucket matches `expected_bucket` exactly |
| **Partial** | Bucket is adjacent in priority order (e.g. VIP vs Needs-reply when sender is Tier 2 with a clear action item) and summary still surfaces the right action |
| **Fail** | Wrong bucket with no mitigating partial case (e.g. marketing archived as FYI, FYI drafted as Needs-reply, VIP buried in marketing) |

### Ambiguous threads (golden has `acceptable_buckets`)

| Score | Criteria |
| ----- | -------- |
| **Pass** | Assigned bucket is in `acceptable_buckets`, **or** thread is explicitly flagged score-0 / ambiguous with no bucket forced |
| **Partial** | Bucket is outside `acceptable_buckets` but the report flags uncertainty and does not auto-archive or draft without user confirmation |
| **Fail** | Confident wrong bucket with no ambiguity flag; or auto-archive / auto-draft on an ambiguous thread |

**Score-0 rule (from profile):** Ambiguous threads must not be guessed. A Pass includes leaving the thread unbucketed with an explicit "ambiguous — needs your read" note.

---

## 2. VIP ordering

Applies when `vip_priority` is present in the golden file.

| Score | Criteria |
| ----- | -------- |
| **Pass** | VIP thread appears in the report at or before its `vip_priority.rank` relative to other VIP threads; Tier 1 senders are never ranked below Tier 2 when both are present |
| **Partial** | Correct VIP bucket but ordering is off by one position among peers of the same tier |
| **Fail** | VIP thread missing from the VIP section, ranked after non-VIP items of similar urgency, or Tier 1 surfaced after Tier 2 without urgency justification |

When scoring a **single-thread** paste eval, verify the golden `vip_priority.rank` and `tier` are reflected in the narrative (e.g. "surface first", "Tier 1 — draft immediately").

---

## 3. Ambiguous handling

Applies to corpus threads 19–21 (`acceptable_buckets` in golden).

| Score | Criteria |
| ----- | -------- |
| **Pass** | No spurious draft; no archive proposal; summary states why the thread is unclear; bucket in `acceptable_buckets` or explicit score-0 flag |
| **Partial** | Correct caution but summary over-claims intent (invents an action item not in the thread) |
| **Fail** | Fabricates a decisive classification, drafts a reply, or proposes archive without user confirmation |

---

## 4. Long-thread summary

Applies when golden includes `expected_summary_lines` (corpus threads 22–23).

| Score | Criteria |
| ----- | -------- |
| **Pass** | Exactly two summary lines (bullets or sentences); each maps to one `expected_summary_lines` entry in meaning; covers the decision **and** what is outstanding |
| **Partial** | Two lines present but one is vague, omits a named decision/outstanding item, or requires more than two lines in the actual output |
| **Fail** | No two-line summary; summary contradicts the thread; or user would need to re-read the full chain to act |

**Semantic match:** Wording need not be verbatim. Match on: who is waiting, what decision is needed, and by when (if stated).

---

## 5. Supporting fields

### `draft_required`

| Score | Criteria |
| ----- | -------- |
| **Pass** | `draft_required: true` → hand-off to drafting noted; `false` → no draft created or promised |
| **Fail** | Draft created when not required, or missing draft hand-off when required |

### `archive_proposal` (marketing only)

| Score | Criteria |
| ----- | -------- |
| **Pass** | Proposal matches golden `archive_proposal` (sender, action, label if any); framed as proposal, not executed |
| **Partial** | Correct archive intent but wrong label or missing exact sender |
| **Fail** | No archive proposal for marketing; archive executed without confirmation; wrong sender auto-archived |

### `summary_bullets`

| Score | Criteria |
| ----- | -------- |
| **Pass** | Bullets capture the same facts as golden `summary_bullets` (names, dates, amounts, deadlines) without hallucination |
| **Partial** | Core fact correct but minor omission (e.g. missing a deadline day) |
| **Fail** | Invented facts, wrong sender, or summary missing the main action |

---

## 6. Batch digest (MA12)

Applies when golden has `batch_digest_expected: true` or when triaging a combined paste with ≥ 3 FYI or ≥ 3 marketing threads.

| Score | Criteria |
| ----- | -------- |
| **Pass** | Bucket uses markdown table (not long bullet list); columns match skill contract (#, Sender, Subject, Note; marketing adds Action) |
| **Partial** | Table present but missing Action column on marketing, or one row materially wrong |
| **Fail** | Bullets used for 3+ items in same bucket; table omits senders; archive executed without proposal |

**Fixtures:** `34-fyi-bulk-receipts`, `35-marketing-bulk-promos`, [`corpus/batch-paste-bulk.md`](../corpus/batch-paste-bulk.md).

---

## 7. Task capture proposals (MA12)

Applies when golden has `task_capture_proposed: true` and `task_capture_line`.

| Score | Criteria |
| ----- | -------- |
| **Pass** | **Task capture proposals** section lists a line matching `task_capture_line` in meaning; no silent `TASKS.md` write |
| **Partial** | Correct intent but wrong deadline wording or missing source thread |
| **Fail** | No proposal section; silent task write; proposal invents unrelated work |

**Fixtures:** `06-needs-reply-budget-approval` (and any golden with `task_capture_proposed: true`).

---

## 8. Action type and lingerers (MA12 live edge)

Applies when golden has `action` and/or `lingerer_expected: true`.

| Score | Criteria |
| ----- | -------- |
| **Pass** | Report assigns the golden `action` type (not wrong bucket); utility notices → `calendar-hold` not needs-reply; automated receipts → archive proposal not reply; lingerer threads appear under **Inbox lingerers** on triage/08:00 runs |
| **Partial** | Correct bucket but wrong action type, or lingerer surfaced only in needs-reply without lingerers section |
| **Fail** | Utility notice drafted as reply; receipt treated as needs-reply; read old thread dropped as "no unread" |

**Fixtures:** `36-utility-meter-access`, `37-co-parent-logistics-confirm`, `38-toll-receipt-automated`, `39-inbox-lingerer-open-question`.

---

## Smoke subset quick reference

For the five-thread smoke run (see `evals/README.md`), minimum bar:

1. One **VIP** — correct bucket + priority language
2. One **marketing** — archive proposal, no draft
3. One **ambiguous** — acceptable bucket or score-0 flag
4. One **long-thread** — two-line decision summary
5. One **scheduling** — times/calendar hand-off noted, no auto-book

---

## Example scoring notes (template)

```markdown
### 19-ambiguous-forwarded-thread
- Bucket: Pass (FYI, in acceptable_buckets)
- Ambiguous: Pass (flagged unclear forwarded content)
- Draft: Pass (draft_required false, no draft)
- Overall: Pass
```
