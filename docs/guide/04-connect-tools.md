# Connect email, calendar, and chat

My Assistant works without any connections — every skill runs on content you paste. Connect MCP servers in your host and it works directly against your real inbox, calendar, and messages.

## How to connect

**Cowork / Claude Code:** enable MCP servers in your host settings, or connect your own MCP provider per category.

**Cursor:** enable the MCP servers bundled in the plugin (Slack, Notion, GitHub) via **Settings → MCP**, or connect your own MCP server in the same category. For `~~email`, `~~calendar`, and `~~drive`, add an MCP provider or paste content.

## What you can connect

| Category | Examples | What My Assistant does |
|----------|----------|------------------------|
| **Email** (`~~email`) | Gmail, Microsoft 365 | Read mail, triage, create reply drafts — never sends |
| **Calendar** (`~~calendar`) | Google Calendar, Microsoft 365 | See your schedule, prep meetings, propose times |
| **Drive** (`~~drive`) | Google Drive, OneDrive | Read shared documents for meeting prep |
| **Chat** (`~~chat`) | Slack, Teams | Scan messages, post digests you've opted into |
| **Notes** (`~~notes`) | Notion, Confluence | Notes and knowledge lookups |
| **Tasks** (`~~tasks`) | GitHub, Jira, Linear, monday | Task and work-item context |

Connect only what you use. The plugin refers to tools by category (`~~email`, `~~calendar`, `~~chat`, …) so any provider in that category works — see [`CONNECTORS.md`](../../CONNECTORS.md).

## Draft-only by design

My Assistant **drafts everything for your review and never sends, books, or spends** on your behalf. If your email connector supports draft-only outbound, that matches this plugin exactly.

## Using connectors

Once connected:

```
/assistant:inbox triage          # triages your real inbox
/assistant:brief                 # pulls today's real calendar + unread
/assistant:update --comprehensive # scans email/calendar/chat for missed todos
```

It always asks before adding a task or a memory, and never sends or books automatically.

## Without connectors

Everything still runs — paste a thread, your agenda, or work from `TASKS.md` and memory alone. Skills skip any missing connector and note the gap rather than failing.

> **Paste-first verification:** prove each category works without OAuth using [connector smoke tests](connector-smoke-tests.md). Fixtures live in `evals/connectors/fixtures/`; one paste per `~~category`.

## How to verify

| Goal | Where |
| ---- | ----- |
| Prove "works with email/calendar/chat…" without live OAuth | [Connector smoke tests](connector-smoke-tests.md) |
| Category manifest and smoke commands | [`config/connector-categories.yaml`](../../config/connector-categories.yaml) |
| Product ↔ category mapping | [`CONNECTORS.md`](../../CONNECTORS.md) |

## Next

[Protect your privacy →](05-protect-privacy.md)
