# Connectors

## How tool references work

Plugin files use `~~category` as a placeholder for whatever tool the user connects in that category. For example, `~~email` might mean Gmail or Microsoft 365.

Plugins are **tool-agnostic** — they describe workflows in terms of categories (chat, email, calendar, etc.) rather than specific products. The `.mcp.json` pre-configures MCP servers, but any MCP server in that category works.

## Connectors for this plugin

| Category | Placeholder | Default | Alternatives |
|----------|-------------|---------|--------------|
| Chat | `~~chat` | Slack | Microsoft Teams, Discord |
| Office suite | `~~office suite` | Google Workspace | Microsoft 365 |
| Email | `~~email` | Gmail | Microsoft 365 |
| Calendar | `~~calendar` | Google Calendar | Microsoft 365 |
| Drive | `~~drive` | Google Drive | Microsoft 365 (OneDrive) |
| Knowledge base | `~~knowledge base` | — | Notion, Confluence, Guru |
| Work management | `~~work management` | — | Jira, Linear, monday.com, Asana, ClickUp |

### Native integrations

Gmail, Google Calendar, and Google Drive are native Claude integrations — no MCP connector install needed. Connect them in Cowork → Settings → Connectors.

### Optional connectors

Knowledge base and work management are optional. Without them, manage tasks and memory manually in `TASKS.md` and `memory/`.
