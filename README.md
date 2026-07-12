# My Assistant

**Your AI chief of staff for inbox, calendar, and follow-ups.**

One installable plugin for [Claude Cowork](https://claude.com/product/cowork), Claude Code, and [Cursor](https://cursor.com) that triages your inbox, drafts replies in your voice, tracks follow-ups, preps your meetings, runs a morning briefing, and manages your tasks and memory.

It **drafts everything for your review and never sends, books, or spends on your behalf.** Instructions buried in emails, invites, or pasted docs are never obeyed — they're surfaced for you to confirm. You glance, edit, and send. That's the whole promise.

## Try it in 3 minutes

1. Browse the [**examples gallery**](./examples/README.md) — pick a persona and see before/after draft demos
2. Run `/assistant:start` for a fast tasks + memory bootstrap, or `/assistant:setup` for the full profile interview
3. Paste a demo thread → `/assistant:inbox triage` → compare your draft to the reference

No connectors required. Eval maintainers: see [`evals/demo/first-run-script.md`](./evals/demo/first-run-script.md) (Alex Rivera eval persona).

## What it does

### Workflow commands

| Job | Command |
|-----|---------|
| Configure it to you (10-min interview) | `/assistant:setup` |
| Fast tasks + memory bootstrap | `/assistant:start` |
| Morning briefing | `/assistant:brief` |
| Bring the assistant up to date (`tasks` · `memory` · `--all`) | `/assistant:update` |
| Weekly report | `/assistant:report` |
| Set up scheduled tasks | `/assistant:schedules` |

### Domain commands (noun + verb)

| Job | Command |
|-----|---------|
| Triage inbox + draft replies | `/assistant:inbox triage` (default) |
| Lighter inbox sweep | `/assistant:inbox sweep` |
| Draft one reply | `/assistant:email draft` |
| Review what's awaiting a response | `/assistant:email review` |
| Add / review / sync tasks | `/assistant:tasks add` · `review` · `sync` |
| Prep for meetings / follow up on notes | `/assistant:meeting prep` · `follow-up` (default) |

Plus skills that fire on their own as you work: calendar scheduling, meeting follow-up from pasted notes, and two-tier memory that decodes your shorthand ("ask todd re oracle").

## Install

**Claude Cowork or Claude Code:** Customize → Plugins → add a marketplace from this repo's GitHub URL (`https://github.com/daddia/my-assistant`), then install **My Assistant**.

**Cursor:** Settings → Plugins → Add plugin → paste `https://github.com/daddia/my-assistant`, then install **My Assistant**.

| What you see | Value |
|--------------|-------|
| **Display name** | My Assistant |
| **Repo & marketplace** | `my-assistant` |
| **Plugin id** (manifest `name`) | `assistant` |
| **Working folder** | `~/MyAssistant` (configurable at setup) |
| **Profile** | `~/MyAssistant/config/profile.md` |
| **Policies** | `~/MyAssistant/policies/*.policy.md` |
| **Install config** | `~/MyAssistant/config/my-assistant.json` |
| **Commands** | `/assistant:*` |

Then run:

```
/assistant:setup
```

A short interview captures who you are, how you write, your VIP tiers, and your email and calendar policy. Setup creates your working folder (default `~/MyAssistant`) and writes `config/profile.md`, `policies/*.policy.md`, and selective `config/my-assistant.json` — outside the plugin, so `/plugin update` never overwrites it. Policy templates ship in the plugin's `policies/` directory.

## Works on day one, sharper with connectors

Every skill is standalone-first: paste an email thread or your calendar and it just works. Connect Slack, Notion, GitHub, or your own MCP servers for `~~email`, `~~calendar`, and `~~drive` to work directly against your accounts. See [`CONNECTORS.md`](./CONNECTORS.md).

## Always-on options

- **Scheduled tasks** (`/assistant:schedules`) — guided decision tree for local Cowork schedules, Claude Code cloud schedules, or managed agents. Canonical job list: [`scheduled/schedules.yaml`](./scheduled/schedules.yaml).
- **Managed-agent cookbooks** ([`managed-agents/`](./managed-agents/)) — the same jobs on Anthropic's infrastructure, immune to a sleeping laptop. Advanced/optional.
- **Reliability guide** — [Always-on reliability](./docs/guide/07-always-on-reliability.md): when to stay local, when to escalate, and how missed runs surface in chat via `scheduled/`.

## Visual dashboard

Open `{assistantPath}/dashboard.html` in Chrome or Edge for a board/list view of `TASKS.md`, a browser for `AGENTS.md` + `memory/`, and a **Review** tab for pending approvals. Copied into your working folder at setup; or open `skills/dashboard.html` from the plugin and point it at your working folder.

## How it's built

Plain English — skills, rules, and a profile you can read and edit. See [`AGENTS.md`](./AGENTS.md) for the trigger→skill map and [the docs](./docs/) for the full guide.

### Trust artefacts

| Topic | Guide |
| ----- | ----- |
| Privacy in plain language | [Protect your privacy](./docs/guide/05-protect-privacy.md) |
| Deploy paths, profile, working folder | [Admin & deployment](./docs/guide/08-admin-deploy.md) |
| Prove "works with X" without OAuth | [Connector smoke tests](./docs/guide/connector-smoke-tests.md) |
| Security deep dive | [security/README.md](./security/README.md) |

To verify triage, drafts, injection defence, and connector categories against fixtures, see the [proof harness](./evals/README.md).

## Licence

Released under the [MIT](LICENSE) licence — you're free to use, modify, and distribute this project.

Copyright (c) 2026 Jonathan Daddia
