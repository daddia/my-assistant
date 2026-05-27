---
type: Roadmap
domain: ai-assistant-adk
version: '0.1'
owner: JD
status: Active
last_updated: 2026-05-27
parent_product: product.md
related:
  - product.md
  - strategy.md
  - ../guide/05-protect-privacy.md
---

# Roadmap — AI Assistant ADK

Delivery roadmap for the [AI Assistant ADK](./product.md) (Agent Development Kit). Phases are **Now → Next → Future**: outcome-based, with testable exit criteria — not an epic backlog.

## 1. Roadmap intent

Sequence the ADK from a **proven desktop assistant** (Cowork + my-assistant + privacy baseline) to **multi-runtime and cloud-capable** delivery, then to a **broader kit** others can fork for many assistant shapes.

## 2. Sequencing logic

1. **Desktop first** — local files, user-controlled folder, minimal moving parts; proves install, setup, skills, and governance before cloud complexity.
2. **One reference workspace** — my-assistant must work end-to-end before adding more examples or providers.
3. **Security and privacy early** — gitignore, rules, and user-facing privacy docs are part of Now, not deferred to Next.
4. **Providers and hosting after proof** — cloud runtimes and alternate adapters build on portable artifacts already validated on desktop.

## 3. Phases

### Phase 1 — Now (desktop, Cowork, my-assistant)

**Objective:** Ship a trustworthy **desktop** reference assistant on **Claude Cowork** using the **my-assistant** template, with clear **security and privacy** defaults.

**In flight**

| Area | Delivery |
|------|----------|
| Runtime | Claude Cowork on desktop (folder pointed at user workspace) |
| Install | Claude Code agentic install + README quick start |
| Reference workspace | `workspaces/my-assistant/` template; `personal-assistant` gitignored |
| Plugins | `skills/assistant`, `skills/productivity` copied into workspace |
| ADK positioning | README, strategy, CONTRIBUTING aligned on Agent Development Kit |
| Security & privacy | `rules/file-safety`, `rules/core-behavior`; guide [05-protect-privacy](../guide/05-protect-privacy.md); no personal data in Git |

**Exit criteria**

- [ ] New user completes install → `/setup` → `/productivity:start` on desktop Cowork without manual skill editing
- [ ] `workspaces/personal-assistant/` is gitignored; only template context is committed
- [ ] Privacy guide states what stays local, what goes to the model provider, and connector opt-in behaviour
- [ ] Confirmation model documented: no send/book/delete without explicit approval per action
- [x] Canonical skills under `skills/` and `.claude/skills/`; no workspace skill copies to sync

**Out of scope for this phase**

- Cloud-hosted or always-on agent runtimes
- Cursor / Managed Agents / third-party adapter documentation beyond stubs
- Multiple published example workspaces (beyond my-assistant)
- Automated scheduling layer independent of Cowork UI

---

### Phase 2 — Next (cloud, providers, examples, stronger privacy)

**Objective:** Extend the ADK beyond **desktop Cowork** — **cloud-capable** operation, **additional providers**, more **assistant examples**, and **enhanced** security and privacy guidance.

**In flight**

| Area | Delivery |
|------|----------|
| Cloud | Documented path for cloud / managed agent runtimes (API or hosted Cowork-class execution) |
| Providers | At least one non-Cowork adapter (e.g. Cursor rules + skills path, or Claude Managed Agents) |
| Examples | Additional assistant templates (use cases beyond personal my-assistant) |
| Security & privacy | Hardened docs, config patterns, and rules for cloud + multi-provider (secrets, data residency, connector scope) |

**Exit criteria**

- [ ] Documented “cloud running” setup: what runs where, what data leaves the machine, and required secrets handling
- [ ] One additional provider adapter doc with parity list (install, workspace folder, skills location)
- [ ] ≥1 new example workspace committed (fictional/generic context) with README pointer from main README
- [ ] Privacy/security docs updated for cloud and connectors (threat model summary, checklist for forkers)
- [ ] Provider-agnostic skill wording validated on second runtime (smoke test checklist passed)

**Out of scope for this phase**

- Full template marketplace or private plugin registry
- Provider-agnostic cron/automation replacing all runtime schedulers
- Enterprise SSO or team admin console

---

### Phase 3 — Future (kit at scale)

**Objective:** Mature the ADK as a **forkable platform** — template gallery, scheduling abstraction, and team distribution — without collapsing back into a single product.

**Direction (not committed scope)**

- Template gallery for verticals (work, family ops, research, etc.)
- Provider-agnostic schedule / automation layer backed by `tasks/*.task.md`
- Team distribution via plugins (`.claude-plugin` / MCP bundles)
- Consolidate legacy `shared/` into canonical `skills/` and `rules/`

**Exit criteria (to be refined when Next completes)**

- [ ] Roadmap reviewed; Future broken into phased backlog with owners
- [ ] Next phase exit criteria all met

**Out of scope until replanned**

- Commercial hosting product
- Compliance certifications (SOC2, etc.) unless explicitly sponsored

## 4. Milestones

| Milestone | Phase | Customer-visible? | Notes |
|-----------|-------|-------------------|-------|
| ADK README + strategy published | Now | Yes (GitHub) | Agent Development Kit positioning |
| Desktop install + `/setup` path verified | Now | Yes | Cowork folder + Claude Code install |
| Privacy guide + gitignore enforced | Now | Yes | Personal workspace never committed |
| Cloud adapter doc published | Next | Yes (docs) | Defines data boundary for cloud run |
| Second provider adapter published | Next | Yes (docs) | e.g. Cursor or Managed Agents |
| Second example workspace shipped | Next | Yes | Beyond my-assistant |
| Future scope replanned | Future | Internal | After Next gate |

## 5. Cross-domain dependencies

| Dependency | Owner | Gates | Current status |
|------------|-------|-------|----------------|
| Anthropic Cowork desktop stability | Anthropic | Now — folder + skills UX | In use |
| Claude Code for agentic install | Anthropic | Now — README install prompt | In use |
| Provider APIs for cloud phase | TBD per provider | Next — cloud running | Not started |
| `daddia/skills` tooling (e.g. write-roadmap) | JD | Docs/product hygiene | Available |

## 6. Out of scope for this roadmap cycle

- Story-level backlog / epic acceptance criteria in `roadmap.md` (use a separate backlog if needed)
- Implementation modules or stack choices (see [strategy.md](./strategy.md))
- Commercial pricing or GTM strategy

## 7. Review cadence

- **Weekly (active Now work):** progress against Now exit criteria; blockers on install/setup/privacy
- **Pre-phase-gate:** all exit criteria checked before starting Next
- **Quarterly:** revisit Future; adjust Next if provider landscape shifts
