---
name: schedule-setup
description: Walk the user through creating the packaged Cowork scheduled tasks
  (morning briefing, inbox sweep, meeting-prep watcher, follow-up watcher, weekly
  review). Activate on "/my-assistant:schedules", "set up my scheduled tasks",
  "automate my briefing", or "run this every morning".
---

# Schedule setup

Turn the plugin's recurring jobs into Cowork scheduled tasks. Each block below is copy-paste ready. Walk the user through picking which they want, then help them create each one.

## How to create a scheduled task in Cowork

Type `/schedule` (or use the Scheduled sidebar), paste the prompt, pick the cadence. Each run is a full Cowork session with access to files, connectors, plugins, skills, and the web.

## Read this to the user before they start

Three honest caveats — say them up front:

1. **The machine must be awake.** Scheduled tasks run locally: Claude Desktop must be open and the computer not asleep. Missed runs fire when the machine wakes — there's no cloud catch-up. If a job is mission-critical (the 8am brief must land), consider the managed-agent version in `managed-agents/` which runs on Anthropic's infra.
2. **Pre-approve the tools.** So a run doesn't stall on a permission wall while unattended, approve the tools it needs ahead of time (e.g. Gmail draft creation, calendar read, file write).
3. **Each run uses quota.** Batch related work into one task rather than many small ones. After the first run, Cowork may rewrite the prompt from what it learned — expected.

## The packaged tasks

### Morning briefing — weekdays 8:00am
```
Each weekday at 8am, give me a short, scannable briefing: today's
calendar with attendees, important unread emails or messages, follow-ups
going cold, and anything needing my attention before noon. Read my
profile at ~/.claude/plugins/config/my-assistant/profile.md first. Use
the my-assistant daily-brief skill. Keep it under 400 words. Save it as
brief-YYYY-MM-DD.md.
```
Cron: `0 8 * * 1-5`

### Inbox sweep — weekdays 8:00am, 12:00pm, 4:00pm
```
Triage new mail since the last sweep into needs-reply / FYI / marketing /
VIP using the my-assistant inbox-triage skill and my profile. Draft
replies (do not send) for needs-reply and VIP in my voice. Summarise long
threads. List what you drafted and what you propose archiving.
```
Cron: `0 8,12,16 * * 1-5`

### Meeting-prep watcher — weekdays 7:00am
```
For each meeting today with an external attendee, produce a one-paragraph
prep brief using the my-assistant meeting-prep skill: who they are, what
they do, our last contact, and what I should prepare. Read my profile and
memory first.
```
Cron: `0 7 * * 1-5`

### Follow-up watcher — daily 5:00pm
```
Check mail I sent that's awaiting a reply using the my-assistant
follow-up-tracking skill. For anything silent 3+ business days, draft a
polite nudge (do not send) in my voice and list it. Cross-check the
Waiting On section of TASKS.md.
```
Cron: `0 17 * * *`

### Weekly review — Friday 4:00pm
```
Run the my-assistant weekly-review skill: summarise the week — what
closed, open loops, stale tasks (untouched 14+ days), and what to line up
for Monday. Update TASKS.md and prune stale memory with my confirmation.
Save as review-YYYY-MM-DD.md. Keep it scannable.
```
Cron: `0 16 * * 5`

## Suggested starter set

If the user wants a minimal setup, recommend just two: **Morning briefing** and **Inbox sweep**. Add the others once those prove useful.

## Cloud alternative

Claude Code cloud scheduled tasks (claude.ai/code/scheduled) run on Anthropic's infrastructure and don't need the laptop awake — a good fit for the morning briefing. The managed-agent cookbooks in `managed-agents/` are the always-on route for the critical jobs.
