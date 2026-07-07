---
type: Roadmap
version: '0.1'
owner: My Assistant maintainers
status: Draft
last_updated: 2026-07-08
related:
  - .agency/product.md
  - .agency/backlog.md
  - CHANGELOG.md
  - .agency/research/2026-07-06-competitor-scan.md
---

# Roadmap -- My Assistant

## 1. Roadmap intent

My Assistant's concept, skill coverage, and trust model are already strong (12 skills shipped, draft-only enforced by rule). The competitor scan and feature-backlog matrix agree the gap is **proof, packaging, and operational parity** — not missing capability. This roadmap sequences the backlog ([`.agency/backlog.md`](./backlog.md)) so credibility is established before feature parity is chased, and feature parity is closed before packaging polish is applied. Phasing matters because proof and review-queue work are prerequisites the rest of the backlog depends on or is judged against: shipping a new import path before an eval rubric exists would mean shipping capability with no way to demonstrate its trust behaviour.

## 2. Sequencing logic

1. **Prove before you extend.** No new user-facing capability ships without an eval and injection-defense baseline to measure against.
2. **Operationalize trust before proposing more autonomy.** The review-queue spec must land before time protection and trust artefacts, since both introduce new categories of proposal the queue needs to model.
3. **Close documentation gaps early and independently.** Positioning and roadmap work has no dependencies and blocks nothing — it runs in parallel with proof and review-queue work inside Now.
4. **Reliability before onboarding polish.** Always-on reliability precedes onboarding polish, since a validator without a defined local-vs-cloud decision tree has nothing stable to validate against.
5. **No new skills before existing skills are provable.** Per the feature-backlog rule (§8 of the backlog), Later-phase packaging work must not be pulled forward to substitute for proving the 12 shipped skills.

Dependency detail stays canonical in [`.agency/backlog.md`](./backlog.md) §3 and §8.

## 3. Phases

Epic points, dependencies, and status live in [`.agency/backlog.md`](./backlog.md) §3 — not repeated here.

### Now: Prove and specify

Make the existing 12-skill surface demonstrably trustworthy and close the documentation gaps a new visitor hits first. Credibility artefacts (eval suite, review-queue spec, positioning and comparison docs) land before feature-parity work begins, because later capabilities need a baseline to be measured against. Competitor-gap rationale: [`.agency/research/feature-backlog.md`](./research/feature-backlog.md) Part 1 (`●●` strengths already shipped; proof and packaging are the gap).

Phase moves and shipped artefacts: [CHANGELOG.md](../CHANGELOG.md#unreleased).

### Next: Close feature and operational parity

Close the real feature and reliability gaps identified in the competitor scan — notetaker import, time protection, always-on reliability, draft feedback, and trust artefacts — each held to the proof harness and review-queue standards established in Now. Propose-only calendar behaviour and connector smoke tests stay within the draft-first wedge ([`backlog.md` §7](./backlog.md#7-deliberate-non-goals)).

Phase moves and shipped artefacts: [CHANGELOG.md](../CHANGELOG.md#unreleased).

### Later: Packaging polish

Package the now-proven, now-reliable product for smoother first use — starter profiles, an examples gallery, install validation, and eval automation — without adding new capability surface or substituting packaging for proof. Skill sprawl remains a named risk ([`backlog.md` §9](./backlog.md#9-risks), R8).

Phase moves and shipped artefacts: [CHANGELOG.md](../CHANGELOG.md#unreleased).

## 4. Milestones

| Milestone | Phase | Customer-visible? |
| --------- | ----- | ------------------ |
| Eval suite + demo script published | Now | No (internal proof) |
| Review-queue spec + approval-language rollout | Now | Yes (skill output changes) |
| Positioning, roadmap, compare-alternatives live | Now | Yes |
| Notetaker import ships | Next | Yes |
| Time-protection proposals ship | Next | Yes |
| Local-vs-cloud reliability decision tree published | Next | Yes |
| Draft feedback loop live | Next | Yes |
| Trust artefacts (admin guide, privacy explainer, connector smoke tests) published | Next | Yes |
| Starter profiles + examples gallery live | Later | Yes |
| `/assistant:doctor` validator ships | Later | Yes |

Epic-to-milestone mapping: [`.agency/backlog.md`](./backlog.md) §3.

## 5. External dependencies

| Dependency | Owner squad | Gates |
| ---------- | ----------- | ----- |
| None — all Now-phase and Next-phase work operates on the existing repo and synthetic fixtures per `.agency/backlog.md` §1 "Prerequisites" | — | — |
| Live connector OAuth (optional, for connector smoke-test verification beyond fixtures) | My Assistant maintainers | Trust-artefacts live-check sub-scope only |

## 6. Deferred beyond this cycle

- Live meeting bot / call-joining notetaker (permanent non-goal; compete via notetaker import instead).
- Autonomous send / autopilot tiers at any level.
- Bulk unsubscribe / inbox surgery automation.
- Team collaboration / shared inbox support.
- Enterprise governance (SOC 2, SSO, SCIM).
- NL search / deep mail Q&A (revisit as a memory/search deepening, not a new epic).

Full rationale for each: `.agency/backlog.md` §7 "Deliberate non-goals".

## 7. Review cadence

- **Weekly:** Check epic status in `.agency/backlog.md` §3 against this roadmap's phase gates; flag any epic slipping its phase.
- **Pre-phase-gate:** Before moving Now → Next or Next → Later, verify phase outcomes in §3 are met and update `status` in this file's frontmatter; record the move in [CHANGELOG.md](../CHANGELOG.md#unreleased).
- **Quarterly:** Re-validate sequencing logic (§2) against the competitor scan; refresh if a competitor ships a feature that changes priority.
