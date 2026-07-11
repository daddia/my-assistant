---
name: schedule-setup
description: Walk the user through creating the packaged Cowork scheduled tasks
  (morning briefing, inbox sweep, meeting-prep watcher, follow-up watcher, weekly
  review). Activate on "/assistant:schedules", "set up my scheduled tasks",
  "automate my briefing", or "run this every morning".
---

# Schedule setup

Turn the plugin's recurring jobs into scheduled tasks. The canonical job list lives in `scheduled/schedules.yaml` — five jobs, stable `job_id` slugs, shared prompts across local Cowork schedules, Claude Code cloud schedules, and managed-agent cookbooks.

Walk the user through the decision tree, then help them create each job they want.

## How to create a scheduled task in Cowork

Type `/schedule` (or use the Scheduled sidebar), paste the prompt, pick the cadence. Each run is a full Cowork session with access to files, connectors, plugins, skills, and the web.

**Platform note:** `local` surface requires Claude Cowork desktop (`/schedule`). Cursor plugin users without Cowork should use `cloud-code` (Claude Code at claude.ai/code/scheduled) or `managed` cookbooks for always-on jobs.

## Read this to the user before they start

Three honest caveats — say them up front:

1. **The machine must be awake.** Scheduled tasks on the `local` surface run on the desktop: Claude Desktop must be open and the computer not asleep. Missed runs fire when the machine wakes — there's no cloud catch-up. If a job is mission-critical (the 8am brief must land), consider `cloud-code` or the managed-agent version in `managed-agents/` which runs on Anthropic's infra.
2. **Pre-approve the tools.** So a run doesn't stall on a permission wall while unattended, approve the tools it needs ahead of time (e.g. Gmail draft creation, calendar read, file write).
3. **Each run uses quota.** Batch related work into one task rather than many small ones. After the first run, Cowork may rewrite the prompt from what it learned — expected.

## Decision tree

Read `scheduled/schedules.yaml` and walk the user through surface selection **per job**. Default is always `local` — managed agents are opt-in when reliability outweighs local-first.

1. **Ask:** "Does any job need to run while your laptop sleeps?"
2. If **no** — recommend `local` (Cowork scheduled tasks) for all chosen jobs. State the machine-awake caveat once.
3. If **yes** — for each job they want always-on:
   - **`reliability_tier: critical`** (`morning-briefing`): explicitly recommend `managed` (`managed-agents/morning-briefing/agent.yaml`) or `cloud-code` when sleep is common. Do not imply the whole setup must move — only this job.
   - **Jobs with a managed cookbook** (`inbox-sweep`, `follow-up-watcher`): offer `managed` or `cloud-code` as the reliability upgrade.
   - **Jobs without a managed cookbook** (`meeting-prep-watcher`, `weekly-review`): recommend `cloud-code` (Claude Code scheduled tasks at claude.ai/code/scheduled) — same packaged prompt, Anthropic infra, no new cookbook required.
4. When recommending `managed`, include the cost caveat from `managed-agents/README.md` (~$0.08/session-hour runtime; burst schedules are cheap; 24/7 polling is not).
5. Never imply My Assistant hosts schedules — the user deploys Cowork, Claude Code, or managed-agent cookbooks themselves.

Record the user's chosen `surface` per `job_id` — you will write it to the health ledger below.

Full user-facing copy of this tree: `docs/guide/07-always-on-reliability.md`.

## Initialize schedule health ledger

After the user picks jobs and surfaces, create or update one file per job at `{working-folder}/scheduled/{job_id}.yaml`:

```yaml
version: "0.1"
job_id: <job_id>
updated_at: <ISO-8601 now>
surface: local | cloud-code | managed   # user's choice
cadence: "<cron from catalog>"
last_run_at: null
last_run_status: missed
expected_artifact: null                 # or resolved path pattern for dated artefacts
artifact_present: false
miss_count_7d: 0
notes: null
```

- Create `scheduled/` on first write in the **working folder only** — never under the plugin directory.
- Write one YAML file per configured job; filename must match `job_id` (e.g. `morning-briefing.yaml`).
- Include only jobs the user actually set up.
- If a job file already exists, merge updates; do not wipe existing heartbeat history.

## The packaged tasks

Prompts below match `scheduled/schedules.yaml`. Anchor headings are stable `packaged_prompt_ref` targets.

### Morning briefing {#morning-briefing}

Weekdays 8:00am · `job_id: morning-briefing` · `reliability_tier: critical`

```
Each weekday at 8am, give me a short, scannable briefing: today's
calendar with attendees, important unread emails or messages, follow-ups
going cold, and anything needing my attention before noon. Read my
profile per rules/paths.md first. Run
/assistant:brief. Keep it under 400 words. Save it as brief-YYYY-MM-DD.md.
```
Cron: `0 8 * * 1-5`

### Inbox sweep {#inbox-sweep}

Weekdays 8:00am, 12:00pm, 4:00pm · `job_id: inbox-sweep`

```
Triage new mail since the last sweep into needs-reply / FYI / marketing /
VIP using /assistant:inbox sweep and my profile. Summarise long threads.
List what you propose archiving.
```
Cron: `0 8,12,16 * * 1-5`

### Meeting-prep watcher {#meeting-prep-watcher}

Weekdays 7:00am · `job_id: meeting-prep-watcher` · no managed cookbook — `cloud-code` fallback

```
For each meeting today with an external attendee, run /assistant:meeting prep:
who they are, what they do, our last contact, and what I should prepare.
Read my profile and memory first.
```
Cron: `0 7 * * 1-5`

### Follow-up watcher {#follow-up-watcher}

Daily 5:00pm · `job_id: follow-up-watcher`

```
Check mail I sent that's awaiting a reply using /assistant:email review.
For anything silent 3+ business days, draft a polite nudge (do not send)
in my voice and list it. Cross-check the Waiting On section of TASKS.md.
```
Cron: `0 17 * * *`

### Weekly review {#weekly-review}

Friday 4:00pm · `job_id: weekly-review` · no managed cookbook — `cloud-code` fallback

```
Run /assistant:review: summarise the week — what closed, open loops,
stale tasks (untouched 14+ days), and what to line up for Monday. Update
TASKS.md and prune stale memory with my confirmation. Save as
review-YYYY-MM-DD.md. Keep it scannable.
```
Cron: `0 16 * * 5`

## Suggested starter set

If the user wants a minimal setup, recommend just two: **Morning briefing** and **Inbox sweep**. Add the others once those prove useful.

## Health recording on scheduled runs

When a scheduled run completes (any surface), the target skill updates `scheduled/{job_id}.yaml` for its job:

- Set `last_run_at` to now (ISO-8601).
- Set `last_run_status` to `success` only when required artefacts exist or the skill's completion criteria are met; otherwise `partial` or `failed`.
- Set `expected_artifact` and `artifact_present` when the catalog defines a dated file.
- Update `updated_at` on the job file.

Interactive runs do not reset `miss_count_7d` unless they complete the scheduled job's artefact contract.

## Handoff

Point the user to `docs/guide/07-always-on-reliability.md` for the full reliability story, escalation triggers, and cost caveats.

## Approval frame

Follow [`rules/approval-frame.md`](../../rules/approval-frame.md) when a scheduled run surfaces reviewable work.

**Queue mappings:**

- Cron configuration alone does **not** create queue items.
- Inbox sweep runs that propose archives write `archive-proposal` items (one batched item per sweep) per `inbox-triage` conventions.

Append the observability footer when queue items are written.
