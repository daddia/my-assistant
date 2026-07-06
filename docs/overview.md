# My Assistant — product strategy & architecture

**My Assistant** is a single installable plugin for [Claude Cowork](https://claude.com/product/cowork), Claude Code, and [Cursor](https://cursor.com) that acts as an AI chief of staff: inbox triage, reply drafting in the user's voice, follow-up tracking, meeting prep and follow-up, a daily briefing, scheduling drafts, tasks, and two-tier memory. It **drafts everything and never sends, books, or spends** on the user's behalf.

This document is the product and architecture source of truth. End-user setup is in the [user guide](./guide/00-introduction.md) and [README](../README.md).

---

## Positioning

- **One plugin, many skills** — modelled on the Vercel plugin (one install; `skills/`, `commands/`, `agents/`, one `.mcp.json`) and Anthropic's knowledge-work plugins, not a marketplace of separate plugins.
- **"Your AI chief of staff for inbox, calendar and follow-ups."** An executive/personal assistant, not a team workflow tool.
- **Draft-first as the core promise.** It prepares; you approve. This matches Cowork's draft-only Gmail connector and the SaaS norm (Fyxer never sends).
- **Zero-config-usable, sharper after a 10-minute setup interview.**

## Competitive frame

The canonical EA job list, benchmarked against Fyxer and Superhuman: inbox triage, reply drafting in voice, follow-up tracking, meeting prep + follow-up, scheduling, daily briefing, task capture, memory/context. My Assistant covers all of these in v1.

Honest gaps vs SaaS, and how we handle them:

- **No live meeting bot.** We compete on *prep* and *post-meeting follow-up from pasted notes/transcripts* (Granola/Fireflies/Otter output), not on joining calls.
- **Sweep-cadence, not instant drafts.** 3×/day inbox sweeps + managed-agent bursts get close; the review step is the safety feature.
- **Draft-only, never sends.** Framed as trust, and it matches the platform.

---

## Architecture

```
my-assistant/                     # repo root = the plugin
├── .claude-plugin/
│   ├── plugin.json               # Claude manifest
│   └── marketplace.json          # Claude marketplace (install via GitHub URL)
├── .cursor-plugin/
│   ├── plugin.json               # Cursor manifest (skills, commands, agents, hooks, rules, MCP)
│   └── marketplace.json          # Cursor marketplace
├── .mcp.json                     # connector suggestions (Slack, MS365, Notion, Jira, Linear, monday)
├── CLAUDE.md  →  @AGENTS.md
├── AGENTS.md                     # orchestration: trigger→skill map, draft-don't-send rule
├── CONNECTORS.md                 # ~~category placeholders, native vs MCP
├── commands/                     # 7 explicit slash commands
├── skills/                       # 12 auto-firing skills + dashboard.html
├── agents/                       # 3 named + schedulable agents (cron frontmatter)
├── managed-agents/               # 3 headless CMA cookbooks (agent.yaml)
├── hooks/hooks.json              # SessionStart: load the profile if present
├── rules/                        # core-behaviour, file-safety
└── config/profile.template.md    # copied to ~/.claude/plugins/config/my-assistant/ on setup
```

### Personalisation survives updates

All user personalisation lives in a **profile** at `~/.claude/plugins/config/my-assistant/profile.md` — outside the plugin directory, so `/plugin update` overwrites plugin files but never the profile. The setup interview writes it; a `SessionStart` hook loads it; every skill reads it. When a durable convention emerges mid-work, skills propose a profile diff and ask before writing.

### Connector-agnostic

Skills reference connectors by category (`~~email`, `~~calendar`, `~~chat`, `~~notes`, `~~tasks`, `~~drive`). Gmail, Google Calendar, and Google Drive are native Cowork connectors (Gmail draft-only); the rest are MCP suggestions in `.mcp.json`. Every skill is **standalone-first** — works on pasted content, supercharged by a connector.

### Graduated autonomy

Set in the profile, enforced by `rules/core-behaviour.md`. Default **Tier 1 (Draft)**. Tiers 0–3 range from suggest-only to notify-after; "send", "book", and "spend" are never automatic at any tier.

---

## The two always-on surfaces

| Surface | Where it runs | Use |
|---------|---------------|-----|
| **Scheduled tasks** (`skills/schedules`) | Local desktop (machine must be awake) | Default: morning brief, inbox sweeps, follow-up watcher, weekly review |
| **Managed-agent cookbooks** (`managed-agents/`) | Anthropic infra (immune to sleeping laptop) | Advanced/optional; the critical always-on jobs |

Same prompts and skills feed both — one source, two surfaces.

### Visual dashboard

`skills/dashboard.html` — a browser UI (Chrome/Edge) for the working folder's `TASKS.md` and two-tier memory. No server; uses the File System Access API. Complements chat-based task and memory skills.

---

## Design decisions

**Why one plugin, not a marketplace?** Consumers install one thing; every capability rides one namespace, one `.mcp.json`, one profile. Proven manageable at 25 skills by the Vercel plugin.

**Why draft-only?** It's the platform reality (Gmail connector can't send) and the trust model users expect. We lean into it.

**Why a profile outside the plugin?** So updates never wipe personalisation — the single biggest failure mode for config-in-plugin designs.

**Why standalone-first skills?** Useful on day one before any OAuth; the Anthropic house rule.

---

## Roadmap

See [roadmap.md](./product/roadmap.md). v1 ships the full EA surface as one plugin; Next covers wider connector validation and the managed-agent deployment path; Future covers a template gallery and richer scheduling.
