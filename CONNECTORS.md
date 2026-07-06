# Connectors

## How tool references work

Skills use `~~category` as a placeholder for whatever tool the user has connected in that category. `~~email` might mean Gmail or Microsoft 365; `~~chat` might mean Slack or Teams.

Every skill is **standalone-first**: it works with content you paste in, and gets *supercharged* when a connector is present. Nothing here requires OAuth to be useful on day one.

## Connectors for this plugin

| Category | Placeholder | Default | Alternatives |
|----------|-------------|---------|--------------|
| Email | `~~email` | Gmail (native) | Microsoft 365 |
| Calendar | `~~calendar` | Google Calendar (native) | Microsoft 365 |
| Drive | `~~drive` | Google Drive (native) | Microsoft 365 (OneDrive) |
| Chat | `~~chat` | Slack | Microsoft Teams, Discord |
| Notes / knowledge | `~~notes` | Notion | Confluence, Guru |
| Tasks / work | `~~tasks` | — | Jira, Linear, monday.com, Asana, ClickUp |

## Native integrations (no MCP install needed)

Gmail, Google Calendar, and Google Drive are native Cowork connectors. Connect them in **Cowork → Settings → Connectors**.

**Gmail is draft-only.** Claude can read mail and create drafts, but cannot send. This plugin is built around that: it drafts, you send.

## MCP connectors (bundled suggestions)

`.mcp.json` pre-configures suggestions for Slack, Microsoft 365, Notion, Atlassian (Jira/Confluence), Linear, and monday.com. Any MCP server in the right category works — the skills never hard-code a product.

## Without connectors

The plugin degrades gracefully:

- **No email connector?** Paste threads; the assistant triages and drafts replies you copy back.
- **No calendar connector?** Paste your agenda; it preps meetings and proposes times.
- **No task connector?** Tasks live in `TASKS.md`. Memory lives in `memory/`. Both are plain files you own.

When a connector a skill wants is missing, the skill skips that step and notes the gap rather than failing.
