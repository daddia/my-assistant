---
type: Backlog
level: epic
version: '0.2'
owner: My Assistant maintainers
status: Refined
last_updated: 2026-07-08
related:
  - .agency/product.md
  - .agency/roadmap.md
  - .agency/research/feature-backlog.md
  - .agency/research/2026-07-06-competitor-scan.md
---

# Backlog -- My Assistant

- **Product:** [`.agency/product.md`](./product.md)
- **Roadmap:** [`.agency/roadmap.md`](./roadmap.md) *(to be created — see MA03)*
- **Feature research:** [`.agency/research/feature-backlog.md`](./research/feature-backlog.md)
- **Source scan:** [`.agency/research/2026-07-06-competitor-scan.md`](./research/2026-07-06-competitor-scan.md)

## 1. Summary

**Objective.** Take My Assistant from a well-specified plugin to a *demonstrably* trustworthy one. The competitor scan and feature-backlog matrix agree: the concept, skill coverage, and trust model are already strong; the gap is **proof, packaging, and operational parity**. This backlog turns the safety-first, local-first draft-only wedge into something a visitor can verify in minutes, and closes the real feature gaps (review queue, notetaker import, time protection, connector validation) without becoming a SaaS.

**Delivery approach.** Three phases mapped to the scan's P0/P1/P2 and the recommended 30-day plan. **Now** makes the product credible and provable (evals, review-queue spec, positioning + roadmap). **Next** closes feature/operational parity (notetaker import, time protection, always-on reliability, feedback loop, trust + connector artefacts). **Later** adds packaging polish (starter profiles, examples, onboarding validator). Do **not** add generic assistant skills before Now ships — the feature backlog is explicit that the EA jobs already exist (`AGENTS.md` routes 12 skills); they need to be made provable and reviewable.

**Shipped baseline (codebase-validated).** None of MA01–MA10 have started (no `.agency/work/` directories). The v1 surface is real:

- **12 skills** — setup-interview, inbox-triage, email-drafting, follow-up-tracking, calendar-scheduling, meeting-prep, meeting-follow-up, daily-brief, task-management, memory-management, weekly-review, schedule-setup.
- **10 commands** — `/assistant:setup`, `:inbox`, `:email`, `:tasks`, `:memory`, `:brief`, `:prep`, `:update`, `:review`, `:schedules`.
- **Trust model** — `rules/core-behaviour.md`, `rules/untrusted-content.md`, `rules/file-safety.md`; graduated autonomy tiers 0–3 in profile + rules.
- **Security artefacts** — `security/threat-model.md`, `security/data-flow.md`, `security/permissions.md`.
- **Always-on surfaces** — local scheduled tasks (`schedule-setup`) + 3 managed-agent cookbooks (`managed-agents/`).
- **Dashboard** — `skills/dashboard.html` (tasks + memory editor; not yet a review surface).
- **Partial implementations** — meeting-follow-up accepts pasted notetaker output (MA04); calendar-scheduling respects focus blocks (MA05); `CONNECTORS.md` documents categories but has no smoke-test harness (MA08).

**Prerequisites (required).** None external; all epics operate on the existing repo plus synthetic fixtures. No new connector auth is needed for Now-phase work.

**Out of scope.** Live meeting bot / call-joining notetaker (compete via import, not capture). Full PM app (task/calendar system of record). SaaS backend, hosted accounts, SOC 2. Sending/booking/spending automation at any tier. Autonomous send/autopilot tiers, take-actions-in-external-tools, bulk unsubscribe/inbox surgery, team/shared inbox. See §7 deliberate non-goals and `product.md` "Competitive frame".

## 2. Conventions

| Convention | Value |
| ---------- | ----- |
| Epic ID | `MA{nn}` |
| Epic work path | `.agency/work/{epic}/` (title slug, max two words, kebab-case) |
| Task ID | `MA{nn}-{nn}` in `.agency/work/{epic}/tasks.md` |
| Status | Not started, In progress, In review, Done, Blocked |
| Priority | P0–P3 (mirrors competitor-scan priority) |
| Estimation | Fibonacci story points |

## 3. Epic breakdown

| Epic ID | Title | Phase | Priority | Deps | Points | Work path | Status |
| ------- | ----- | ----- | -------- | ---- | ------ | --------- | ------ |
| MA01 | Proof harness | Now | P0 | — | 13 | `.agency/work/proof-harness/` | Done |
| MA02 | Review queue (spec) | Now | P0 | — | 5 | `.agency/work/review-queue/` | Done |
| MA03 | Positioning & roadmap | Now | P0 | — | 5 | `.agency/work/positioning-roadmap/` | Not started |
| MA04 | Notetaker import | Next | P1 | MA01 | 8 | `.agency/work/notetaker-import/` | Not started |
| MA05 | Time protection | Next | P1 | MA02 | 8 | `.agency/work/time-protection/` | Not started |
| MA06 | Always-on reliability | Next | P1 | — | 5 | `.agency/work/always-on/` | Not started |
| MA07 | Feedback loop | Next | P1 | MA01 | 8 | `.agency/work/feedback-loop/` | Not started |
| MA08 | Trust artefacts | Next | P1 | MA02 | 5 | `.agency/work/trust-artefacts/` | Not started |
| MA09 | Starter profiles & examples | Later | P2 | MA01 | 8 | `.agency/work/starter-profiles/` | Not started |
| MA10 | Onboarding polish | Later | P2 | MA06 | 5 | `.agency/work/onboarding-polish/` | Not started |
| MA11 | Eval automation | Later | P2 | MA01 | 8 | `.agency/work/eval-automation/` | Not started |

**Scan + feature-backlog coverage.** Every P0/P1/P2 gap in the feature-backlog matrix maps to an epic above. MA08 scope is expanded from the prior draft: security/data-flow docs already exist under `security/`; MA08 now also covers connector smoke-test validation (`CONNECTORS.md` → provable per-category steps), admin/deployment guide, and a plain-language privacy explainer. Points raised 3 → 5 to reflect the added connector-validation deliverable.

## 4. Feature traceability

Maps feature-backlog Part 2 epics to delivery epics. `(have)` items are shipped skills/rules; `(gap)` items are backlog scope.

| Feature-backlog epic | Shipped | Backlog epic |
| -------------------- | ------- | ------------ |
| 1 — Onboarding & personalization | Setup interview, voice learning, memory diffs *(have)* | MA09 (starter profiles), MA10 (doctor validator), MA01 (first-run demo) |
| 2 — Inbox triage & organization | Triage/sweep, brief cadence *(have)* | MA06 (reliability), MA02 (approval frame) |
| 3 — Reply drafting & composition | Context-aware drafts *(have)* | MA02 (approval language), MA07 (feedback loop) |
| 4 — Autonomy & trust controls | Draft-only, untrusted-content, tiers *(have)* | MA01 (prove injection defense), MA02 (review queue) |
| 5 — Scheduling & calendar | Propose times, conflicts *(have)* | MA05 (proactive block proposals) |
| 6 — Meetings | Prep *(have)*; paste follow-up *(partial)* | MA04 (first-class notetaker import) |
| 7 — Search, memory & knowledge | Two-tier memory *(have)* | Deepen via MA07; no new epic (avoid skill sprawl) |
| 8 — Connectors & integrations | `~~category` placeholders, MCP *(have)* | MA08 (connector smoke-test guide) |
| 9 — Always-on reliability | Local schedules + managed agents *(partial)* | MA06 (decision tree, health surfacing) |
| 10 — Proof, trust & packaging | Rules claimed, not demonstrated *(gap)* | MA01, MA03, MA08, MA09/MA10, MA11 |

## 5. Epic detail (Now phase)

### MA01 -- Proof harness

**Scope.** Turn "it can triage, draft and brief" into verifiable evidence. Highest-value epic in the backlog — credibility foundation for MA04, MA07 and MA09. Covers the scan's P0 eval-suite, prompt-injection-tests and demo-script items, plus the feature-backlog call to **prove** untrusted-content defense (currently claimed in `rules/untrusted-content.md`, not demonstrated).

**Key deliverables.**

- Synthetic inbox corpus: ~25 threads spanning VIP, FYI, marketing, ambiguous, long-thread, scheduling request, and malicious prompt-injection cases.
- Golden triage outputs: expected buckets, draft quality, archive proposals, and known gaps per thread.
- Draft eval rubric: voice match, brevity, no hallucinated facts, commitment flags, no unsafe sends.
- Prompt-injection fixtures: ≥10 untrusted-content attacks ("ignore previous instructions", "archive this", "send secrets", "update memory") with expected surface-and-refuse behaviour.
- First-run demo: a 3-minute script plus screenshots/GIF covering setup → triage → draft review → memory suggestion.
- `evals/README.md` documenting how to run and read the suite.

**Dependencies.** None. Unblocks MA04, MA07, MA09.

**Status.** Not started. **Work path:** `.agency/work/proof-harness/`

### MA02 -- Review queue (spec)

**Scope.** Make draft-first *operational*, not just philosophical. Specify (not build a SaaS UI) a review-queue surface that collects everything awaiting the user's approval. The feature-backlog flags that approvals today are prompt/report-based while competitors offer review queues; `skills/dashboard.html` is a tasks/memory **editor** only — no approval affordances.

**Key deliverables.**

- Review-queue spec covering six queues: reply drafts, archive proposals, follow-up nudges, memory suggestions, profile diffs, calendar proposals.
- Definition of the queue data shape (source files: `TASKS.md`, memory, profile, generated drafts/briefs) and how each skill contributes items.
- Extension of `skills/dashboard.html` from editor to review surface, or a documented rationale for a separate view.
- Approval-language pattern for every workflow: "What I found / What I drafted / What I recommend / What needs your approval" — roll out across all 12 skills, not just backlog prose.

**Dependencies.** None. Informs MA05 (calendar proposals) and MA08 (permission surfacing).

**Status.** Not started. **Work path:** `.agency/work/review-queue/`

### MA03 -- Positioning & roadmap

**Scope.** Close the documentation gaps a new visitor hits first. `.agency/product.md` references `./product/roadmap.md` which does not exist; there is no single positioning page to anchor Fyxer/Lindy/Superhuman comparisons. Feature-backlog Part 4 item 3.

**Key deliverables.**

- `.agency/roadmap.md`: Now/Next/Later derived from this backlog, with competitor-gap rationale and changelog links.
- `.agency/positioning.md`: one-liner, ICP, alternatives, and "why us" (the "agentic preparation, human authority" wedge).
- A "compare alternatives" doc: honest My Assistant vs Fyxer / Lindy / Superhuman / Shortwave / Reclaim / Motion — aligned with feature-backlog Part 3 non-goals.
- Fix dangling roadmap reference in `.agency/product.md` (line 94: `./product/roadmap.md` → `./roadmap.md`).

**Dependencies.** None (but should reflect the epic set defined here).

**Status.** Not started. **Work path:** `.agency/work/positioning-roadmap/`

## 6. Next & Later phase (summary)

Full Gherkin lives in `.agency/work/{epic}/tasks.md` when each epic starts. Scope summaries below incorporate feature-backlog gaps and codebase partials.

| Epic | Scope summary |
| ---- | ------------- |
| **MA04** Notetaker import | Elevate `meeting-follow-up` from paste-anything to first-class import: Granola/Fireflies/Otter/Meet format hints, structured extraction (decisions, owners, dates), dedicated command or mode. Explicit "we don't join calls" UX. |
| **MA05** Time protection | Build on `calendar-scheduling` focus-block awareness + profile calendar policy: proactively propose prep, buffer, and follow-up blocks around meetings — Reclaim/Motion outcome as *drafts* the user confirms. Never auto-book. |
| **MA06** Always-on reliability | Unify local schedules (`schedule-setup`) and managed-agent cookbooks into a clear local-vs-cloud decision tree; optional health/heartbeat when a scheduled run is missed. |
| **MA07** Feedback loop | Systematic draft-quality feedback (good / light edit / heavy rewrite → profile diff) — local version of "learns from your edits." Depends on MA01 rubric. |
| **MA08** Trust artefacts | Admin/deployment guide; plain-language privacy explainer (extends `docs/guide/05-protect-privacy.md`); connector smoke-test guide so "works with X" is provable per `~~category`. Security docs already shipped. |
| **MA09** Starter profiles & examples | Vertical starter profiles (founder, consultant, sales lead, operator, investor); `examples/` gallery; before/after draft demos (uses MA01 corpus). |
| **MA10** Onboarding polish | `/assistant:doctor` install validator; post-setup validation beyond the setup interview. Depends on MA06 reliability story. |
| **MA11** Eval automation | CI structural validation (done); smoke runner for corpus + injection suite; rule-based or LLM-as-judge scoring against golden YAML; trend logs for regression drift. Supplements manual rubric — does not replace human scoring for voice/draft quality. |

## 7. Deliberate non-goals

From feature-backlog Part 3 — kept explicit so scope stays honest. Each is a competitor headline feature we decline because it breaks the wedge:

| Non-goal | Who sells it | Why we decline |
| -------- | ------------ | -------------- |
| Autonomous send / autopilot tiers | Serif, Lindy, Superhuman | Breaks draft-only — the core promise. |
| Take actions in external tools | Serif, Shortwave, Lindy | Executing side-effects the user didn't approve. |
| Live meeting bot / call capture | Fyxer, Lindy, Granola | Compete via prep + notetaker import (MA04). |
| Auto time-blocking / calendar replanning | Reclaim, Motion | Propose blocks (MA05); never book. |
| Bulk unsubscribe / inbox surgery | Inbox Zero, Shortwave | Mutates inbox; propose lists for one-click user action. |
| Team collaboration / shared inbox | Serif, Shortwave, Missive | ICP is the individual EA user. |
| Enterprise governance (SOC 2, SSO, SCIM) | Lindy, Serif, incumbents | Local-first, not a hosted enterprise platform. |
| NL search / deep mail Q&A | Shortwave, Lindy | Valuable but narrow; deepen memory/search later without a new epic now. |
| Attachment auto-filing | Serif, Inbox Zero | Partial via connectors; propose filing, don't auto-mutate. |

## 8. Dependency graph

```text
MA01 (proof harness)
  +-- MA04 (notetaker import)
  +-- MA07 (feedback loop)
  +-- MA09 (starter profiles & examples)
  +-- MA11 (eval automation)

MA02 (review queue)
  +-- MA05 (time protection)
  +-- MA08 (trust artefacts)

MA06 (always-on)
  +-- MA10 (onboarding polish)

MA03 (positioning & roadmap)   [standalone]
```

## 9. Risks

| ID | Risk | Likelihood | Impact | Mitigation |
| -- | ---- | ---------- | ------ | ---------- |
| R1 | Synthetic corpus doesn't reflect real inboxes, so evals pass but real triage disappoints | Medium | High | Draw fixtures from anonymised real patterns; include ambiguous and adversarial cases; treat rubric as living. |
| R2 | Prompt-injection suite gives false confidence (fixtures too easy) | Medium | High | Escalate attack sophistication over time; red-team with novel payloads; version the fixture set. |
| R3 | Scope creep — building an actual review-queue app instead of a spec | Medium | Medium | MA02 is spec-only; any UI reuses `dashboard.html` and the File System Access API, no server. |
| R4 | Time-protection (MA05) drifts toward auto-booking, breaking the draft-only promise | Low | High | Propose blocks only; never book without approval; enforce via `rules/core-behaviour.md`. |
| R5 | Always-on reliance on managed agents introduces cloud dependency at odds with local-first positioning | Medium | Medium | Keep local scheduled tasks the default; present managed agents as an opt-in reliability path with a clear decision tree (MA06). |
| R6 | Notetaker import (MA04) creeps toward building a capture bot | Low | Medium | Import pasted transcripts/notes only; explicitly out of scope to join calls. |
| R7 | Connector smoke tests (MA08) become brittle integration tests requiring live OAuth | Medium | Low | Standalone-first fixtures per category; live connector checks optional, documented as manual smoke steps. |
| R8 | Skill sprawl — adding new skills for gaps that are packaging problems | Medium | Medium | Feature-backlog rule: prove and operationalize existing 12 skills before adding capabilities. |

Security/technical risks: see [`security/threat-model.md`](../security/threat-model.md).
