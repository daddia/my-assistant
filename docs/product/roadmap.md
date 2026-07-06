---
type: Roadmap
domain: my-assistant
version: '1.0'
owner: JD
status: Active
last_updated: 2026-07-06
related:
  - strategy.md
  - ../guide/05-protect-privacy.md
---

# Roadmap — My Assistant

Delivery roadmap for the [My Assistant](./strategy.md) plugin. Phases are **Now → Next → Future**: outcome-based, with testable exit criteria.

## 1. Intent

Ship a trustworthy **single plugin** that covers the full executive-assistant surface (inbox, replies, follow-ups, meetings, briefing, tasks, memory) draft-first on Cowork and Claude Code — then extend connector coverage and the always-on managed-agent path, then broaden into a forkable kit.

## 2. Sequencing logic

1. **One plugin, full surface first** — all EA jobs under one install and one profile before adding breadth.
2. **Draft-first and privacy early** — draft-don't-send, file-safety, and profile-outside-plugin are part of Now, not deferred.
3. **Standalone before connectors** — every skill works on pasted content; connectors supercharge.
4. **Desktop scheduling before managed agents** — prove the jobs locally, then offer the always-on cloud surface for the critical ones.

## 3. Phases

### Phase 1 — Now (v1: the plugin)

**Objective:** Ship the one-install My Assistant plugin with the full EA surface, draft-first, on Cowork and Claude Code.

**Delivered**

| Area | Delivery |
|------|----------|
| Packaging | Single plugin: `plugin.json` + single-plugin `marketplace.json`; installable via GitHub URL |
| Skills | 12 skills (setup, inbox-triage, reply-drafting, follow-up-tracker, calendar-manager, meeting-prep, meeting-follow-up, daily-brief, task-management, memory, weekly-review, schedules) |
| Commands | 7 (`setup`, `brief`, `inbox`, `prep`, `update`, `review`, `schedules`) |
| Agents | 3 named + schedulable agents; 3 managed-agent cookbooks |
| Personalisation | Profile at `~/.claude/plugins/config/my-assistant/`, survives `/plugin update`; `SessionStart` hook loads it |
| Guardrails | `rules/core-behaviour` (draft-don't-send, 4 autonomy tiers), `rules/file-safety` |
| Connectors | `.mcp.json` suggestions + `CONNECTORS.md`; native Gmail/Calendar/Drive; standalone fallback |

**Exit criteria**

- [x] One install exposes all 7 commands and 12 skills under the `my-assistant` namespace
- [x] `/my-assistant:setup` writes a profile outside the plugin directory
- [x] Every skill works standalone (pasted content) and degrades gracefully without connectors
- [x] No skill sends, books, or spends; confirmation model documented
- [x] Packaged scheduled-task prompts shipped with machine-awake + tool-preapproval caveats

**Out of scope for this phase**

- Live meeting bot / call recording (we compete on prep + follow-up)
- Auto-send of any kind

---

### Phase 2 — Next (connectors, managed agents, examples)

**Objective:** Harden connector coverage and the always-on path; validate voice/anti-style quality against real use.

| Area | Delivery |
|------|----------|
| Managed agents | Documented deployment of the three cookbooks to a managed-agent environment (vault OAuth, burst schedules) |
| Connectors | Validate `~~email`/`~~calendar`/`~~chat` across Gmail, Microsoft 365, and Slack end-to-end |
| Autonomy | Tier 2/3 rollout guidance with the "edits fewer than ~1 in 5 drafts" benchmark |
| Quality | Voice-sample workflow (`voice/`) and anti-style regression checks |

**Exit criteria**

- [ ] One managed-agent cookbook deployed and running on a burst schedule with drafts landing
- [ ] Inbox triage + reply drafting validated on a second email provider
- [ ] Documented path to raise a user from Tier 1 → Tier 2 safely

---

### Phase 3 — Future (kit at scale)

**Direction (not committed scope)**

- Template variants for different roles (founder, IC, family ops)
- Provider-agnostic scheduling abstraction
- Richer memory tooling and shorthand learning

**Exit criteria (refined when Next completes)**

- [ ] Next phase exit criteria all met
- [ ] Future broken into a phased backlog with owners

## 4. Review cadence

- **Weekly (active Now/Next work):** progress against exit criteria; draft-quality issues
- **Pre-phase-gate:** all exit criteria checked before starting the next phase
- **Quarterly:** revisit Future; adjust for platform changes (Cowork scheduling, Managed Agents API)
