---
type: Comparison
version: '0.1'
owner: My Assistant maintainers
status: Draft
last_updated: 2026-07-08
related:
  - .agency/positioning.md
  - .agency/roadmap.md
  - .agency/backlog.md
  - .agency/research/2026-07-06-competitor-scan.md
---

# Compare alternatives

Honest, point-in-time comparison of **My Assistant** against six named competitors from the [2026-07-06 competitor scan](../.agency/research/2026-07-06-competitor-scan.md). For positioning language and the "why us" wedge, see [positioning.md](../.agency/positioning.md). For what ships when, see [roadmap.md](../.agency/roadmap.md).

**Last reviewed:** 2026-07-08 · **Suggested refresh cadence:** quarterly manual review against competitor changelogs and the feature-backlog matrix.

## Rating legend

| Rating | Meaning |
| ------ | ------- |
| **Strong** | Core, differentiated capability — productionised or clearly specified with evidence |
| **Adequate** | Present and usable; not a category wedge |
| **Weak** | Partial, unproven, or deliberately limited |
| **Absent** | Not in scope or not offered |

## Feature matrix

Ratings derive from the competitor scan feature table (2026-07-06). Reclaim and Motion are split where their strengths diverge.

| Capability | My Assistant | Fyxer | Lindy | Superhuman | Shortwave | Reclaim | Motion |
| ---------- | ------------ | ----- | ----- | ---------- | --------- | ------- | ------ |
| Inbox triage | Strong spec, unproven UX | Strong | Strong | Strong | Strong | Weak | Weak |
| Reply drafting in voice | Strong spec | Strong | Strong | Strong | Strong | Weak | Weak |
| Draft-only safety | **Strong** | Adequate | Mixed | Mixed | Mixed | Mixed | Mixed |
| Follow-up tracking | Strong spec | Strong | Strong | Strong | Adequate | Weak | Weak |
| Calendar scheduling | Adequate | Strong | Strong | Adequate | Adequate | Strong | Strong |
| Auto time-blocking | Weak | Weak | Weak | Weak | Weak | **Strong** | **Strong** |
| Meeting prep | Strong spec | Adequate | Strong | Weak | Weak | Adequate | Adequate |
| Meeting capture / notes | Weak by design | Strong | Strong | Weak | Weak | Weak | **Strong** |
| Post-meeting follow-up | Strong spec | Strong | Strong | Weak | Adequate | Weak | Strong |
| Task management | Adequate (plain files) | Weak | Adequate | Weak | Adequate | Strong | Strong |
| Memory / personal context | **Strong** | Strong | Strong | Adequate | Adequate | Adequate | Adequate |
| Cross-tool automation | Adequate via MCP | Adequate | Strong | Weak–Adequate | Strong | Strong (own suite) | Strong (own suite) |
| Local-first / open | **Strong** | Absent | Absent | Absent | Absent | Absent | Absent |
| Enterprise governance | Weak artefacts | Adequate–Strong | Strong claims | Adequate | Adequate | Strong (teams) | Strong (teams) |
| Observability / evals | Weak | Unknown | Unknown | Unknown | Unknown | Adequate | Adequate |
| Market proof | Weak | Strong | Strong | Strong | Strong | Strong | Strong |

## Where competitors win

| Product | Primary advantage over My Assistant |
| ------- | ----------------------------------- |
| **Fyxer** | Productionised inbox outcomes — organised mail, drafts waiting, meeting notes, enterprise packaging |
| **Lindy** | Breadth and 24/7 cloud-agent positioning across inbox, calendar, and ad-hoc tasks |
| **Superhuman** | Premium email-client UX — split inbox, reminders, polished daily mail workflow |
| **Shortwave** | In-product natural-language email automation with app polish and integrations |
| **Reclaim** | Automatic calendar optimisation — focus time, buffers, habits, smart meetings |
| **Motion** | AI work superapp — projects, tasks, calendar, meeting notes, and replanning in one suite |

## Where My Assistant wins

- **Draft-first as promise** — never send, book, spend, or delete without per-instance approval; safety is the product, not a limitation.
- **Untrusted-content defense** — email, invites, transcripts, and pasted docs are data, not instructions; prompt-injection resistance is a headline feature.
- **Local-first / open** — profile, tasks, and memory in plain files you own; readable skills and rules; no SaaS lock-in.

## What we decline

My Assistant deliberately does **not** chase every capability competitors sell. We compete on **agentic preparation, human authority** — not autopilot. Summary of [deliberate non-goals](../.agency/backlog.md#7-deliberate-non-goals):

| Area | Our stance |
| ---- | ---------- |
| Autonomous send / autopilot | Draft-only at every tier — the core promise |
| Actions in external tools | Propose; user approves side-effects |
| Live meeting bots | Prep + notetaker import instead of joining calls |
| Auto time-blocking | Propose blocks; never book without approval |
| Bulk inbox surgery | Propose lists; user executes one-click actions |
| Team / shared inbox | ICP is the individual knowledge worker |
| Enterprise governance (SOC 2, SSO) | Local-first plugin, not a hosted enterprise platform |
| NL search / deep mail Q&A | Valuable later; not a positioning wedge now |
| Attachment auto-filing | Propose filing via connectors; no silent mutation |

Full rationale for each row: [backlog.md §7](../.agency/backlog.md#7-deliberate-non-goals).

## Out of scope for this page

Platform competitors (Microsoft 365 Copilot, Google Workspace/Gemini, Glean) and meeting-intelligence complements (Granola, Fireflies, Otter) are documented in the [competitor scan](../.agency/research/2026-07-06-competitor-scan.md). My Assistant integrates with notetaker output rather than replacing capture tools.

## Maintenance

Re-run this comparison when a named competitor ships a feature that changes the matrix, or at least once per quarter. Update `last_updated` in frontmatter and add a note to [CHANGELOG.md](../CHANGELOG.md) if ratings change materially.
