# Admin & deployment

For power users, maintainers, and anyone deploying managed agents — not enterprise IT or SOC 2 procurement.

## Who this is for

You need to know **where files live**, **which runtime to pick**, and **how always-on jobs deploy** without reading the full security corpus. End-user privacy basics: [Protect your privacy](05-protect-privacy.md). Deep security: [security/README.md](../../security/README.md).

## Runtimes

My Assistant installs as one plugin on three hosts:

| Runtime | Install path | Notes |
| ------- | ------------ | ----- |
| **Claude Cowork** | Customize → Plugins → marketplace from [GitHub URL](https://github.com/daddia/my-assistant) | Install **My Assistant**; connect MCP servers per category in host settings |
| **Claude Code** | Same marketplace; works in terminal and claude.ai/code | Cloud schedules for always-on jobs |
| **Cursor** | Settings → Plugins → add repo URL | Bundled MCP: Slack, Notion, GitHub; paste-first for email/calendar |

Step-by-step install: [Get started](01-getting-started.md).

**Platform caveats**

- Email, calendar, and drive categories need an MCP provider in your host or paste-first content — the plugin bundles Slack, Notion, and GitHub MCP suggestions only.
- Cursor users without always-on desktop should use `cloud-code` or `managed` surfaces for jobs that must not miss — see [Always-on reliability](07-always-on-reliability.md).

## Profile and config location

Personalisation lives **outside** the plugin so `/plugin update` never overwrites it.

| Host | Default layout |
| ---- | -------------- |
| Cowork / Claude Code / Cursor | `~/MyAssistant/config/profile.md` + `my-assistant.json` |
| Legacy installs | `~/.claude/plugins/config/my-assistant/profile.md` still supported |

Created by `/assistant:setup` from `config/profile.template.md`. Resolution order: `rules/paths.md`. Never commit real profiles to git.

## Working folder

User-owned directory the assistant reads and writes during sessions:

| Path | Purpose |
| ---- | ------- |
| `TASKS.md` | Task board (Active / Waiting On / Someday / Done) |
| `AGENTS.md` + `memory/` | Two-tier memory |
| `drafts/` | Email, calendar, and follow-up drafts |
| `brief-YYYY-MM-DD.md` | Morning briefings |
| `review-queue/` | Pending approvals (`index.yaml` per review-queue schema) |
| `scheduled/` | Scheduled job heartbeats (one `{job_id}.yaml` per job) |

The plugin directory (`skills/`, `rules/`, …) is **read-only** — skills never write there.

## Connectors

Skills use category placeholders (`~~email`, `~~calendar`, …) — not product brands. See [Connect tools](04-connect-tools.md) and [`CONNECTORS.md`](../../CONNECTORS.md).

**Verify connectors work:** [Connector smoke tests](connector-smoke-tests.md) — standalone paste fixtures pass without OAuth.

## Always-on deployment

| Option | Guide |
| ------ | ----- |
| Local Cowork schedules | [Always-on reliability](07-always-on-reliability.md) · `/assistant:schedules` |
| Claude Code cloud schedules | Same chapter — `cloud-code` surface |
| Managed agents | [`managed-agents/`](../../managed-agents/) cookbooks on Anthropic infrastructure |

Canonical job list: `scheduled/schedules.yaml`. Health ledger: `{working-folder}/scheduled/{job_id}.yaml`.

## Managed agents

Advanced optional path — same skills, headless deployment:

1. Choose a cookbook under [`managed-agents/`](../../managed-agents/) (e.g. `morning-briefing/agent.yaml`).
2. Deploy per Anthropic managed-agent docs; connect OAuth via platform vault.
3. **Cost caveat:** burst schedules are cheap; continuous 24/7 polling is not. See `managed-agents/README.md`.

My Assistant does not host your agents or store connector tokens.

## Maintainer local install

For plugin development:

1. Clone this repo.
2. Add as a **local marketplace** (Cowork/Code) or point Cursor at the clone.
3. Run structural validation:

   ```bash
   LANG=en_US.UTF-8 ./evals/scripts/validate-fixtures.sh
   ```

4. No build step — skills are markdown; dashboard is static HTML.

Proof harness: [`evals/README.md`](../../evals/README.md).

## Upgrade safety

| Action | Safe? |
| ------ | ----- |
| `/plugin update` or marketplace pull | ✅ Updates plugin only |
| Profile overwrite | 🚫 Never — profile is outside plugin dir |
| Working folder overwrite | 🚫 Never — user-owned paths |
| Connector credentials in repo | 🚫 Never — OAuth at connect time |

## Next

[Connector smoke tests →](connector-smoke-tests.md) · [Protect your privacy →](05-protect-privacy.md)
