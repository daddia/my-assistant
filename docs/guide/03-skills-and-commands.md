# Skills and commands

My Assistant ships as one plugin with skills in `skills/`, commands in `commands/`, and packaged agents in `agents/`. Skills fire automatically when your request matches; commands are explicit entry points you type.

## Commands (you type these)

### Workflow commands — curated rituals

| Command | Does |
|---------|------|
| `/assistant:setup` | Onboarding interview → writes your profile |
| `/assistant:brief` | Morning briefing |
| `/assistant:prep` | Pre-meeting briefs |
| `/assistant:update` | Sync tasks + memory + follow-ups (`--comprehensive` scans connectors) |
| `/assistant:review` | Weekly review |
| `/assistant:schedules` | Set up scheduled tasks |

### Domain commands — noun + verb arguments

| Command | Verbs | Does |
|---------|-------|------|
| `/assistant:inbox` | `triage` (default) · `sweep` | Full triage + drafts, or lighter bucket-and-archive pass |
| `/assistant:email` | `draft` (default) · `review` | Draft one reply, or review what's awaiting a response |
| `/assistant:tasks` | `add` · `review` (default) · `sync` | Capture, review, or sync tasks in `TASKS.md` |
| `/assistant:memory` | `add` (default) · `prune` | Remember people/projects/terms, or prune stale hot-cache entries |
| `/assistant:calendar` | `protect` (default) · `schedule` | Scan for buffer/prep/follow-up gaps and draft block proposals, or find meeting times |
| `/assistant:meeting` | `follow-up` (default) | Import notetaker export or notes → extraction, recap drafts, queue items |

Examples: `/assistant:inbox triage`, `/assistant:email draft`, `/assistant:calendar protect`, `/assistant:meeting follow-up`, `/assistant:tasks add`, `/assistant:memory prune`.

## Skills (fire on their own)

Skills follow `{domain}-{job}`. They compose behind commands — no 1:1 command-per-skill explosion.

- **inbox-triage** + **email-drafting** — bucket mail, draft in your voice
- **follow-up-tracking** — drafts nudges for threads gone cold
- **calendar-scheduling** — proposes times, checks conflicts, drafts invites; **protect mode** scans for buffer/prep/follow-up gaps and drafts calendar block proposals (user creates events manually)
- **meeting-prep** — who / what / last contact / what to prepare
- **meeting-follow-up** — imports Granola/Fireflies/Otter/Google Meet exports (or hand-typed notes) into structured extraction, recap drafts, and queue items. **Does not join calls** — paste what your notetaker captured.
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
4. **Review tab** — browse `review-queue/index.yaml` pending items grouped by type; open `source_path` files (read-only — approve in Gmail/chat/calendar).

The assistant and the dashboard share the same files, so edits in either place stay in sync.

### Review queue and approval frame

Skills that produce reviewable work use a four-part **approval frame** in chat: *What I found · What I drafted · What I recommend · What needs your approval* (`rules/approval-frame.md`). Pending items are written to `review-queue/index.yaml` in your working folder — browse them in the dashboard **Review** tab or approve in chat.

## Everything drafts, nothing sends

No skill sends email, books a meeting, or spends money. They prepare; you act. This is set in `rules/core-behaviour.md` and enforced by your autonomy tier.

## Extending it

The plugin's skills live in `skills/<name>/SKILL.md` — plain markdown. Fork the repo to add your own, or ask the assistant to draft a new skill. Don't edit installed plugin files directly; they're replaced on plugin update. Your data belongs in the profile or your working folder.

## Next

[Connect email, calendar, and chat →](04-connect-tools.md)
