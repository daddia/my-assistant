# Connectors

## How tool references work

Skills use `~~category` as a placeholder for whatever tool the user has connected in that category. `~~email` might mean Gmail or Microsoft 365; `~~chat` might mean Slack or Teams.

Every skill is **standalone-first**: it works with content you paste in, and gets *supercharged* when a connector is present. Nothing here requires OAuth to be useful on day one.

## Connectors for this plugin

| Category | Placeholder | Default | Alternatives |
|----------|-------------|---------|--------------|
| Email | `~~email` | Gmail | Microsoft 365 |
| Calendar | `~~calendar` | Google Calendar | Microsoft 365 |
| Drive | `~~drive` | Google Drive | Microsoft 365 (OneDrive) |
| Chat | `~~chat` | Slack | Microsoft Teams, Discord |
| Notes / knowledge | `~~notes` | Notion | Confluence, Guru |
| Tasks / work | `~~tasks` | GitHub | Jira, Linear, monday.com, Asana, ClickUp |

## Native integrations (no MCP install needed)

Gmail, Google Calendar, and Google Drive are native Cowork connectors. Connect them in **Cowork → Settings → Connectors**.

**Gmail is draft-only.** Claude can read mail and create drafts, but cannot send. This plugin is built around that: it drafts, you send.

## MCP connectors (bundled suggestions)

`.mcp.json` pre-configures one default MCP server per category:

| Category | Server | Endpoint |
|----------|--------|----------|
| Email | Gmail | `https://gmailmcp.googleapis.com/mcp/v1` |
| Calendar | Google Calendar | `https://calendarmcp.googleapis.com/mcp/v1` |
| Drive | Google Drive | `https://drivemcp.googleapis.com/mcp/v1` |
| Chat | Slack | `https://mcp.slack.com/mcp` |
| Notes | Notion | `https://mcp.notion.com/mcp` |
| Tasks | GitHub | `https://api.githubcopilot.com/mcp/` |

Any MCP server in the right category works — the skills never hard-code a product. OAuth is handled when you connect; no credentials are bundled in the repo.

## Without connectors

The plugin degrades gracefully:

- **No email connector?** Paste threads; the assistant triages and drafts replies you copy back.
- **No calendar connector?** Paste your agenda; it preps meetings and proposes times.
- **No task connector?** Tasks live in `TASKS.md`. Memory lives in `memory/`. Both are plain files you own.

When a connector a skill wants is missing, the skill skips that step and notes the gap rather than failing.

## How to verify

Prove each category without live OAuth:

1. Run the structural check: `LANG=en_US.UTF-8 ./evals/scripts/validate-fixtures.sh`
2. Follow [docs/guide/connector-smoke-tests.md](docs/guide/connector-smoke-tests.md) — paste `evals/connectors/fixtures/conn-{category}-paste.md`, run the smoke command from [`config/connector-categories.yaml`](config/connector-categories.yaml), score against the golden file.

**Smoke subset:** email, calendar, chat — highest-traffic categories. Live OAuth steps are optional appendix only; standalone paste is authoritative.

Category manifest: [`config/connector-categories.yaml`](config/connector-categories.yaml) · Maintainer corpus: [`evals/connectors/README.md`](evals/connectors/README.md)
