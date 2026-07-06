# Skills and commands

My Assistant ships as one plugin with **12 skills**, **7 commands**, and packaged agents. Skills fire automatically when your request matches; commands are explicit entry points you type.

## Commands (you type these)

| Command | Does |
|---------|------|
| `/my-assistant:setup` | Onboarding interview → writes your profile |
| `/my-assistant:inbox` | Triage mail + draft replies |
| `/my-assistant:brief` | Morning briefing |
| `/my-assistant:prep` | Pre-meeting briefs |
| `/my-assistant:update` | Sync tasks + memory (`--comprehensive` scans connectors) |
| `/my-assistant:review` | Weekly review |
| `/my-assistant:schedules` | Set up scheduled tasks |

## Skills (fire on their own)

- **inbox-triage** + **reply-drafting** — bucket mail, draft in your voice
- **follow-up-tracker** — drafts nudges for threads gone cold
- **calendar-manager** — proposes times, checks conflicts, drafts invites
- **meeting-prep** — who / what / last contact / what to prepare
- **meeting-follow-up** — turns pasted notes or a transcript into a summary, actions, and follow-up drafts
- **daily-brief** — the morning briefing
- **task-management** — `TASKS.md` (Active / Waiting On / Someday / Done)
- **memory** — two-tier memory that decodes your shorthand
- **weekly-review** — Friday wrap-up
- **setup-interview** / **schedules** — onboarding and automation

Every skill is **standalone-first**: paste content and it works; connect a tool and it works directly against your accounts.

## Everything drafts, nothing sends

No skill sends email, books a meeting, or spends money. They prepare; you act. This is set in `rules/core-behaviour.md` and enforced by your autonomy tier.

## Extending it

The plugin's skills live in `skills/<name>/SKILL.md` — plain markdown. Fork the repo to add your own, or ask the assistant to draft a new skill. Don't edit installed plugin files directly; they're replaced on plugin update. Your data belongs in the profile or your working folder.

## Next

[Connect email, calendar, and chat →](04-connect-tools.md)
