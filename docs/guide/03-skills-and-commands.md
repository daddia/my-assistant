# Skills and commands

My Assistant ships as one plugin with skills in `skills/`, commands in `commands/`, and packaged agents in `agents/`. Skills fire automatically when your request matches; commands are explicit entry points you type.

## Commands (you type these)

### Workflow commands — curated rituals

| Command | Does |
|---------|------|
| `/assistant:setup` | Onboarding interview → writes your profile |
| `/assistant:brief` | Morning briefing |
| `/assistant:draft` | Draft email, chat message, or formal letter (`email` · `chat` · `letter`) |
| `/assistant:update` | Bring the assistant up to date (`tasks` · `memory` scopes; `--all` deep-scans connectors) |
| `/assistant:report` | Weekly report |
| `/assistant:schedules` | Set up scheduled tasks |
| `/assistant:health` | Install and setup health check (`--save` writes report to working folder) |

### Domain commands — noun + verb arguments

| Command | Verbs | Does |
|---------|-------|------|
| `/assistant:inbox` | `triage` (default) · `sweep` | Full triage + drafts, or lighter bucket-and-archive pass |
| `/assistant:email` | `draft` (default) · `review` · `feedback` | Draft one reply, review what's awaiting a response, or capture draft feedback for voice learning |
| `/assistant:tasks` | `add` · `review` (default) · `sync` | Capture, review, or sync tasks in `TASKS.md` |
| `/assistant:calendar` | `protect` (default) · `schedule` | Scan for buffer/prep/follow-up gaps and draft block proposals, or find meeting times |
| `/assistant:meeting` | `prep` · `follow-up` (default) | Pre-meeting briefs, or import notetaker export/notes → extraction, recap drafts, queue items |

Examples: `/assistant:inbox triage`, `/assistant:draft email`, `/assistant:email draft`, `/assistant:email feedback good`, `/assistant:calendar protect`, `/assistant:meeting prep`, `/assistant:meeting follow-up`, `/assistant:tasks add`, `/assistant:update memory`.

### How voice learning works

After you send a reply draft, rate it with `/assistant:email feedback`:

| Outcome | What happens |
| ------- | -------------- |
| **good** | Voice confirmed. Optionally save the sent text as a `voice/` sample — only if you confirm in chat. |
| **light edit** | Small tweak noted. At most one narrow profile tweak if the pattern looks repeatable. |
| **heavy rewrite** | Paste what you sent. The assistant diffs against the draft and proposes **voice** and **anti-style** updates. |

Proposals appear in the dashboard **Review** tab as `profile-diff` items (`pending-profile/*.diff`). Nothing writes to `profile.md` without your approval — at any autonomy tier. Instructions embedded in pasted sent mail are surfaced and refused; only what you type in chat is trusted.

There is no automatic learning from Gmail edit detection — explicit feedback keeps the loop reviewable and local-first.

## Skills (fire on their own)

Skills follow `{domain}-{job}`. They compose behind commands — no 1:1 command-per-skill explosion.

- **inbox-triage** + **email-drafting** — bucket mail, draft in your voice
- **email-feedback** — after you send a draft, classify the edit (good / light / heavy) and propose profile voice updates for your approval
- **follow-up-tracking** — drafts nudges for threads gone cold
- **calendar-scheduling** — proposes times, checks conflicts, drafts invites; **protect mode** scans for buffer/prep/follow-up gaps and drafts calendar block proposals (user creates events manually)
- **meeting-prep** — who / what / last contact / what to prepare
- **meeting-follow-up** — imports Granola/Fireflies/Otter/Google Meet exports (or hand-typed notes) into structured extraction, recap drafts, and queue items. **Does not join calls** — paste what your notetaker captured.
- **daily-brief** — the morning briefing
- **task-management** — `TASKS.md` (Active / Waiting On / Someday / Done)
- **memory-management** — two-tier memory that decodes your shorthand
- **weekly-review** — Friday wrap-up
- **setup** / **schedule-setup** — onboarding and automation (invoke via `/assistant:setup` and `/assistant:schedules`; setup skill folder is `assistant-setup`)
- **health** (`commands/health.md`) — read-only install health check (`/assistant:health`); post-setup subset runs after profile write

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
