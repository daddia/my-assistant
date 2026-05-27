# Productivity Plugin

Task management, memory sync, and daily updates for **my-assistant** — adapted from [Anthropic's knowledge-work productivity plugin](https://github.com/anthropics/knowledge-work-plugins/tree/main/productivity).

Local copy — no blackbox plugin install. Edit and fine-tune the skills directly.

## What it does

- **Task management** — markdown task list (`TASKS.md`) that my-assistant reads, writes, and tracks
- **Memory sync** — fills gaps in your personal memory during task triage
- **Activity scan** — optional deep scan of email, calendar, and chat for missed todos

## Commands

| Command | What it does |
|---------|--------------|
| `/productivity:start` | Initialise tasks and memory on first run |
| `/productivity:update` | Triage stale tasks, check memory for gaps |
| `/productivity:update --comprehensive` | Deep scan email, calendar, chat for missed todos |

## Skills

| Skill | Description |
|-------|-------------|
| `start` | Bootstrap tasks and memory |
| `update` | Sync and triage — default and comprehensive modes |
| `task-management` | Markdown task tracking using `TASKS.md` |
| `memory-management` | Memory gap detection during sync workflows |

## Connectors

Connect tools in Cowork → Settings → Connectors for the best experience. Without them, manage tasks and memory manually.

| Category | Default | Alternatives |
|----------|---------|--------------|
| Chat | Slack | Microsoft Teams, Discord |
| Office suite | Google Workspace | Microsoft 365 |
| Email | Gmail | Microsoft 365 |
| Calendar | Google Calendar | Microsoft 365 |
| Drive | Google Drive | Microsoft 365 (OneDrive) |
| Knowledge base | — | Notion, Confluence |
| Work management | — | Jira, Linear, monday.com |

See [CONNECTORS.md](CONNECTORS.md) for details.

## Example workflows

### Getting started

```
You: /productivity:start

Claude: [Creates TASKS.md and memory/ if missing]
        [Asks about household, priorities, recurring commitments]
        my-assistant is ready. Use /productivity:update to keep things current.
```

### Morning sync

```
You: /productivity:update --comprehensive

Claude: [Scans email, calendar, chat if connected]
        [Flags: "Plumber callback due today — still open"]
        [Suggests: "School newsletter arrived — add to tasks?"]
```

### Adding tasks naturally

```
You: I need to call the plumber this week and renew the car rego in June

Claude: [Adds both to TASKS.md]
        Added 2 tasks. Anything else?
```
