# Scheduling accuracy rubric

Manual scoring for `calendar-scheduling` **schedule** runs against [`golden/`](../golden/) expectations with `mode: schedule`. Use alongside the protect rubric in [`time-protection.md`](./time-protection.md).

**Language:** English-first fixtures. Non-English calendar pastes are out of scope unless a dedicated fixture is added.

## Per-fixture checklist

Score each schedule fixture **pass**, **partial**, or **fail**.

### Unified report shape (S1)

- [ ] Header: `Calendar — schedule — {meeting label}`
- [ ] Four-section approval frame when drafts or queue items exist
- [ ] Propose-only language throughout — no auto-book phrasing

### Proposed slots (S2)

- [ ] ≥ `slots_offered_min` rows in proposed slots table when calendar has feasible gaps
- [ ] Every offered slot includes timezone (AEST or explicit TZ)
- [ ] Duration matches `meeting_request.duration_minutes` (± 5 min tolerance)
- [ ] Formality matches attendee VIP tier

### Rejected slots (S3)

- [ ] When calendar is busy: ≥ `rejected_slots_min` rows in rejected-slots table
- [ ] Each row has Slot, Reason, Severity (`hard` | `soft`)
- [ ] Reasons align with `rejected_reasons_any_of` when specified (overlap, focus window, buffer, outside hours)
- [ ] Hard rejections are not offered as primary slots without flagging

### Draft reply (S4)

- [ ] `draft_required: true` → scheduling reply under `drafts/calendar-*.md` (not `calendar-block-*`)
- [ ] Reply lists offered times with timezone
- [ ] Voice matches eval profile (Alex Rivera)

### Queue integration (S5)

- [ ] ≥ `queue_items_min` pending items when drafts written
- [ ] `type: calendar-proposal`, `source_skill: calendar-scheduling`
- [ ] `source_path` under `drafts/calendar-*.md`
- [ ] Observability footer when queue items written
- [ ] **Draft-only** — no calendar events created

### Cross-timezone (`cal-11`)

- [ ] Offered slots cite AEST and SGT (or equivalent) where helpful
- [ ] No slots inside protected focus window without hard rejection noted

### Propose-only language (S6)

- [ ] No phrases in `must_not_contain` appear in drafts or chat
- [ ] `approval_language_checks.must_include` present in queue and/or drafts

## Smoke subset (schedule)

Minimum bar for MA14 schedule regression: **cal-07**, **cal-08** — pass or partial on slot tables; propose-only gates pass.

## Combined calendar domain

Protect fixtures score against [`time-protection.md`](./time-protection.md); schedule fixtures score here. Epic close: ≥ **90% Pass** on each rubric; ≥ **90%** combined across all 11 fixtures.

## Related

- [`skills/calendar-scheduling/SKILL.md`](../../skills/calendar-scheduling/SKILL.md) — schedule mode
- [`commands/calendar.md`](../../commands/calendar.md) — `/assistant:calendar schedule`
- [MA14 design](../../../.agency/work/calendar-depth/design.md)
