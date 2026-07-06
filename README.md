# My Assistant

**Your AI chief of staff for inbox, calendar, and follow-ups.**

One installable plugin for [Claude Cowork](https://claude.com/product/cowork) and Claude Code that triages your inbox, drafts replies in your voice, tracks follow-ups, preps your meetings, runs a morning briefing, and manages your tasks and memory.

It **drafts everything for your review and never sends, books, or spends on your behalf.** You glance, edit, and send. That's the whole promise.

## What it does

| Job | Command |
|-----|---------|
| Configure it to you (10-min interview) | `/my-assistant:setup` |
| Triage the inbox + draft replies | `/my-assistant:inbox` |
| Morning briefing | `/my-assistant:brief` |
| Prep for today's meetings | `/my-assistant:prep` |
| Sync tasks + memory | `/my-assistant:update` |
| Weekly review | `/my-assistant:review` |
| Set up scheduled tasks | `/my-assistant:schedules` |

Plus skills that fire on their own as you work: follow-up tracking, calendar drafting, meeting follow-up from pasted notes, task capture, and two-tier memory that decodes your shorthand ("ask todd re oracle").

## Install

**In Cowork or Claude Code:** Customize → Plugins → add a marketplace from this repo's GitHub URL (`https://github.com/daddia/my-assistant`), then install **my-assistant**. It appears in both chat and Cowork.

Then run:

```
/my-assistant:setup
```

A short interview captures who you are, how you write, your VIP tiers, and your email and calendar policy. It writes a **profile** to `~/.claude/plugins/config/my-assistant/profile.md` — outside the plugin, so `/plugin update` never overwrites it.

## Works on day one, sharper with connectors

Every skill is standalone-first: paste an email thread or your calendar and it just works. Connect Gmail, Google Calendar, Slack, Notion, or Microsoft 365 (Cowork → Settings → Connectors) and it works directly against your accounts. Gmail is **draft-only** by design — which is exactly how this plugin operates. See [`CONNECTORS.md`](./CONNECTORS.md).

## Always-on options

- **Scheduled tasks** (`/my-assistant:schedules`) — morning briefing, inbox sweeps, follow-up watcher, weekly review. Run locally; the machine must be awake.
- **Managed-agent cookbooks** ([`managed-agents/`](./managed-agents/)) — the same jobs on Anthropic's infrastructure, immune to a sleeping laptop. Advanced/optional.

## How it's built

Plain English — skills, rules, and a profile you can read and edit. No application code. See [`AGENTS.md`](./AGENTS.md) for the trigger→skill map and [the docs](./docs/) for the full guide.

## Licence

[MIT](LICENSE) · Copyright (c) 2026 daddia.
