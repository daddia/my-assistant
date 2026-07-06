# Skills and commands

My Assistant ships as one plugin with skills in `skills/`, commands in `commands/`, and packaged agents in `agents/`. Skills fire automatically when your request matches; commands are explicit entry points you type.

## Commands (you type these)

| Command | Does |
|---------|------|
| `/my-assistant:setup` | Onboarding interview → writes your profile |
| `/my-assistant:inbox` | Triage mail + draft replies |
| `/my-assistant:email` | Draft a reply or review what's awaiting a response |
| `/my-assistant:brief` | Morning briefing |
| `/my-assistant:prep` | Pre-meeting briefs |
| `/my-assistant:update` | Sync tasks + memory (`--comprehensive` scans connectors) |
| `/my-assistant:review` | Weekly review |
| `/my-assistant:schedules` | Set up scheduled tasks |

## Skills (fire on their own)

- **inbox-triage** + **email-drafting** — bucket mail, draft in your voice
- **follow-up-tracking** — drafts nudges for threads gone cold
- **calendar-scheduling** — proposes times, checks conflicts, drafts invites
- **meeting-prep** — who / what / last contact / what to prepare
- **meeting-follow-up** — turns pasted notes or a transcript into a summary, actions, and follow-up drafts
- **daily-brief** — the morning briefing
- **task-management** — `TASKS.md` (Active / Waiting On / Someday / Done)
- **memory-management** — two-tier memory that decodes your shorthand
- **weekly-review** — Friday wrap-up
- **setup-interview** / **schedule-setup** — onboarding and automation

Every skill is **standalone-first**: paste content and it works; connect a tool and it works directly against your accounts.

## Visual dashboard

[`skills/dashboard.html`](../../skills/dashboard.html) is a browser UI for your working-folder files — no slash command needed.

1. Open the file in **Chrome or Edge** (uses the File System Access API).
2. **Tasks tab** — open `TASKS.md` for a kanban board or list view; drag tasks between Active / Waiting On / Someday / Done; auto-saves.
3. **Memory tab** — open your working folder to browse and edit `CLAUDE.md` and files under `memory/`.

The assistant and the dashboard share the same files, so edits in either place stay in sync.

## Everything drafts, nothing sends

No skill sends email, books a meeting, or spends money. They prepare; you act. This is set in `rules/core-behaviour.md` and enforced by your autonomy tier.

## Extending it

The plugin's skills live in `skills/<name>/SKILL.md` — plain markdown. Fork the repo to add your own, or ask the assistant to draft a new skill. Don't edit installed plugin files directly; they're replaced on plugin update. Your data belongs in the profile or your working folder.

## Next

[Connect email, calendar, and chat →](04-connect-tools.md)
