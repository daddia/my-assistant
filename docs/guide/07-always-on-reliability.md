# Always-on reliability

My Assistant runs recurring jobs on your machine (Cowork scheduled tasks), in Claude Code (cloud schedules), or on Anthropic's infrastructure (managed agents). This chapter explains how to choose, what breaks when your laptop sleeps, and how missed runs surface in chat.

**Canonical job list:** `scheduled/schedules.yaml`  
**Setup command:** `/assistant:schedules`  
**Health ledger:** `{working-folder}/scheduled/{job_id}.yaml`

## Two surfaces, one source

Local Cowork prompts, Claude Code cloud schedules, and managed-agent cookbooks share the same skills and packaged prompts. The catalog is the join key — do not fork prompts elsewhere.

| Surface | Platform | Laptop can sleep? |
| ------- | -------- | ----------------- |
| `local` | Cowork `/schedule` (desktop) | No — machine must be awake |
| `cloud-code` | Claude Code at claude.ai/code/scheduled | Yes |
| `managed` | Managed-agent cookbooks in `managed-agents/` | Yes |

**Cursor users:** if you do not have Cowork desktop, use `cloud-code` or `managed` for jobs that must not miss.

## Decision tree

Walk this during `/assistant:schedules` or when a job keeps missing.

1. **Default to `local`.** Cowork scheduled tasks are free aside from quota, keep data on your machine, and work well when your laptop is open weekday mornings.

2. **Ask:** "Does any job need to run while your laptop sleeps?"

3. **If no** — stay on `local` for all jobs. Accept the machine-awake caveat.

4. **If yes** — upgrade **only the jobs that need it**, not your whole setup:

   | Job | `job_id` | Reliability upgrade |
   | --- | -------- | ------------------- |
   | Morning briefing | `morning-briefing` | **Critical** — recommend `managed` (`managed-agents/morning-briefing/agent.yaml`) or `cloud-code` |
   | Inbox triage (08:00) | `inbox-triage-am` | `managed` (`managed-agents/inbox-triage/agent.yaml`) or `cloud-code` |
   | Inbox sweep (12:00/16:00) | `inbox-sweep` | `managed` (`managed-agents/inbox-triage/agent.yaml`) or `cloud-code` |
   | Follow-up watcher | `follow-up-watcher` | `managed` (`managed-agents/follow-up-watcher/agent.yaml`) or `cloud-code` |
   | Meeting-prep watcher | `meeting-prep-watcher` | `cloud-code` only (no managed cookbook yet) |
   | Weekly review | `weekly-review` | `cloud-code` only (no managed cookbook yet) |

5. **Managed cost caveat** (from `managed-agents/README.md`):
   - Runtime ~$0.08 per session-hour before tokens.
   - Burst schedules (a few runs a day) are cheap.
   - True 24/7 always-on ≈ ~$58/mo runtime before tokens — prefer burst schedules, not continuous polling.

6. My Assistant does **not** host your schedules. You create Cowork tasks, Claude Code schedules, or deploy managed-agent cookbooks yourself.

## Health ledger

After setup, `/assistant:schedules` creates one YAML file per job under `scheduled/` in your **working folder** (never inside the plugin directory).

Each scheduled run writes a heartbeat: last run time, success/partial/failed status, and whether expected artefacts (e.g. `brief-YYYY-MM-DD.md`) exist.

Skills invoke **`scripts/update_ledger.py`** deterministically at run end — do not hand-edit ledger files. If `last_run_at` is null but a matching dated artefact exists, health checks and the morning brief flag **ledger out of sync** and use the artefact timestamp as an implied last run.

## Miss detection

When you run `/assistant:brief` interactively on a weekday after the expected window (8:00am + 90 minutes on local surface), and today's brief file is missing, the assistant appends a **Schedule health** block:

```markdown
### Schedule health
- **Missed:** Morning briefing (expected ~08:00 weekdays on *local* surface)
- **Last success:** 2026-07-07 — `brief-2026-07-07.md`
- **Suggestion:** If this happens more than once a week, move this job to the managed-agent cookbook (`managed-agents/morning-briefing/agent.yaml`) or a Claude Code cloud schedule. Run `/assistant:schedules` to walk the decision tree.
```

- Miss detection runs on **interactive** runs only — not on the scheduled run itself (to avoid duplicate noise when the schedule is the recovery).
- The assistant does **not** auto-run a catch-up brief without you asking.
- After two misses in seven days on a critical local job, an escalation line recommends moving **only that job** to managed or cloud-code.

Weekly review has an optional Friday miss hint with the same format, suggesting `cloud-code`.

## Escalation triggers

| Signal | What happens |
| ------ | ------------ |
| One miss on local morning brief | Health block with managed/cloud suggestion |
| `miss_count_7d >= 2` on critical local job | Bold escalation — move only this job |
| No health ledger yet | Suggest `/assistant:schedules`; do not assume misses |
| Corrupt health ledger | Note unreadable; suggest re-running setup |
| User on managed/cloud surface | Skip local miss logic for that job |

## Starter recommendation

Minimal setup: **morning briefing** + **inbox sweep** on `local`. Add meeting-prep, follow-up watcher, and weekly review once those prove useful.

## Related

- [`skills/schedule-setup/SKILL.md`](../../skills/schedule-setup/SKILL.md) — setup workflow and packaged prompts
- [`managed-agents/README.md`](../../managed-agents/README.md) — managed-agent cookbooks and credentials
- [`scheduled/schedules.yaml`](../../scheduled/schedules.yaml) — machine-readable job definitions
- [`scheduled/schedules.schema.yaml`](../../scheduled/schedules.schema.yaml) — health ledger contract
