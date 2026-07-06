# Managed agents (advanced, optional)

Cookbooks for deploying my-assistant's always-on jobs as **Claude Managed Agents** (beta, `managed-agents-2026-04-01`) — the headless surface that runs on Anthropic's infrastructure instead of a desktop, so a sleeping laptop never causes a missed 8am briefing or a dropped follow-up.

Each cookbook is an `agent.yaml` (model, system prompt, tools, MCP servers, skills reused from this plugin). Same prompts and skills as the desktop `agents/` — two surfaces, one source.

## When to use these

Start with desktop scheduled tasks (`/my-assistant:schedules`). Move a job here when it misses because the machine was asleep more than about once a week, or when reliability genuinely matters (a briefing you plan the day around).

## Cost (rough, from early-adopter reporting — not a price sheet)

- Runtime ~$0.08 per session-hour, before tokens.
- Burst schedules (a few runs a day) are cheap.
- A true 24/7 always-on agent ≈ ~$58/mo runtime before tokens — **prefer burst schedules, not continuous polling.**
- Not currently ZDR/HIPAA-eligible.

## Credentials

Connect `~~email` / `~~chat` via MCP servers using vault-stored OAuth credentials in your managed-agent environment — never hard-code secrets in these files.

## The three cookbooks

| Cookbook | Cadence | Job |
|----------|---------|-----|
| `inbox-triage/agent.yaml` | burst (8/12/16 wkdays) | Bucket mail, draft replies, post a digest |
| `follow-up-watcher/agent.yaml` | daily 5pm | Draft nudges for cold threads, escalate VIP silences |
| `morning-briefing/agent.yaml` | weekday 8am | Assemble and deliver the daily brief |

All three are **draft-only**: they never send, book, or spend.
