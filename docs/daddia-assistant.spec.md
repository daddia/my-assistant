# daddia-assistant: Canonical Cowork Project Structure

## Design decisions — answered directly

**Should config live in a Git repo?**
Yes. Everything except runtime state is versioned. The repo is the source of truth. A `make install` step wires it into the locations Cowork actually reads.

**Can Cowork use a `.claude/` directory in the working folder?**
Yes — it reads `<workspace>/.claude/CLAUDE.md` and `<workspace>/.claude/skills/` automatically. The root-level `.claude/` in this repo is only relevant when Claude Code is run from the repo root. Cowork is pointed at the workspace subdirectory, so it sees the workspace-level `.claude/` only.

**How do shared skills reach the workspace?**
`make install` creates symlinks: `workspace/.claude/skills/<name>` → `../../shared/skills/<name>`. Each workspace gets the full shared skill library plus any workspace-specific overrides it defines locally.

**Can tasks be defined in files?**
Partially. Cowork creates scheduled tasks through the UI or the `/schedule` command inside a session — there is no file that Cowork reads to auto-create them. The `tasks/` directory solves this by storing a `.task.md` per schedule: human-readable spec, verbatim prompt to paste into Cowork, and enough metadata for a `make tasks` command to print a rebuild checklist. When you reinstall on a new machine, open each `.task.md` and recreate the task.

**Can schedules be defined in code?**
Not natively. Workaround for reliable scheduling: host a cron job (GitHub Actions, server, Render cron) that calls the Claude API with the task prompt directly. The `tasks/` directory is the shared source of truth for both the Cowork UI approach and any automation layer.

**What is the difference between Global Instructions, CLAUDE.md, and context files?**
Three distinct layers:
- **Global Instructions** (Settings → Cowork → Global Instructions): short, universal, cross-workspace behavioral rules. Fires before every session regardless of folder. Keep under 20 lines.
- **CLAUDE.md**: workspace-specific. Tools, file paths, inline triggers, confirmation policy. What makes *this* workspace different from others.
- **context/ files**: reference content Claude reads when relevant. Identity, voice, working rules. Long-form. Referenced by CLAUDE.md and skills, not loaded in full every session.

---

## Full directory tree

```
daddia-assistant/                        # git repo root
│
├── .gitignore
├── Makefile
├── README.md
├── CHANGELOG.md                          # track config changes over time
│
├── shared/                               # versioned; shared across all workspaces
│   │                                     # symlinked into workspace .claude/skills/
│   ├── skills/
│   │   ├── session/
│   │   │   ├── done/
│   │   │   │   └── SKILL.md              # /done — write decisions + open loops to MEMORY.md
│   │   │   └── standup/
│   │   │       └── SKILL.md              # /standup — read MEMORY.md, surface continuity
│   │   ├── communications/
│   │   │   ├── triage-inbox/SKILL.md
│   │   │   ├── morning-brief/SKILL.md
│   │   │   ├── pre-meeting-brief/SKILL.md
│   │   │   └── post-meeting/SKILL.md
│   │   ├── planning/
│   │   │   ├── checkin/SKILL.md
│   │   │   ├── weekly-review/SKILL.md
│   │   │   └── goals-review/SKILL.md
│   │   └── productivity/
│   │       ├── todo-add/SKILL.md
│   │       └── todo-review/SKILL.md
│   │
│   ├── rules/                            # modular behavior files; referenced from CLAUDE.md
│   │   ├── core-behavior.md              # confirmation model, output path enforcement
│   │   ├── file-safety.md                # what Claude can/cannot touch
│   │   └── tone.md                       # communication defaults
│   │
│   └── templates/                        # output structure; referenced by path in skills
│       ├── morning-brief.md
│       ├── meeting-notes.md
│       ├── weekly-review.md
│       └── daily-summary.md
│
├── config/                               # installed to ~/.claude-assistant/config/
│   ├── email-policy.md                   # VIP tiers, auto-archive senders, label IDs
│   ├── triage-config.md                  # Gmail label IDs, classification thresholds
│   ├── calendar-policy.md                # working hours, buffers, reply-tone templates
│   └── goals.yaml                        # quarterly objectives, weighted OKRs
│
├── plugins/                              # optional: custom plugins for team distribution
│   └── personal-ea/
│       ├── .claude-plugin/
│       │   └── plugin.json               # plugin manifest
│       ├── .mcp.json                     # connector wiring for this plugin
│       ├── skills/                       # plugin-scoped skills (not in shared/)
│       └── commands/                     # explicit slash commands
│
└── workspaces/
    ├── personal/                         # ← point Cowork at this folder
    │   ├── .claude/
    │   │   └── skills/                   # symlinks to shared/skills/* (make install)
    │   │                                 # add workspace-specific skills here directly
    │   ├── CLAUDE.md                     # workspace instructions (see template below)
    │   ├── MEMORY.md                     # .gitignored — cross-session continuity state
    │   ├── context/                      # versioned identity files
    │   │   ├── about-me.md
    │   │   ├── voice-and-style.md
    │   │   ├── anti-ai-writing-style.md
    │   │   └── working-rules.md
    │   ├── inbox/                        # .gitignored — raw input drop zone
    │   ├── outputs/                      # .gitignored — Claude writes here ONLY
    │   │   ├── daily/
    │   │   ├── weekly/
    │   │   └── drafts/
    │   ├── projects/                     # .gitignored — active project work
    │   ├── tasks/                        # versioned task definitions
    │   │   ├── README.md
    │   │   ├── morning-brief.task.md
    │   │   ├── inbox-triage.task.md
    │   │   └── weekly-review.task.md
    │   ├── templates/                    # workspace overrides; falls back to shared/templates/
    │   └── second-brain/                 # .gitignored — Obsidian or freeform notes
    │
    └── work/                             # separate workspace for work context
        └── ... (same structure)
```

---

## .gitignore

```gitignore
# Runtime state — never version these
workspaces/*/MEMORY.md
workspaces/*/outputs/
workspaces/*/inbox/
workspaces/*/projects/
workspaces/*/second-brain/

# Symlinks created by make install — regenerated, not versioned
workspaces/*/.claude/skills/

# Secrets
.env
.env.local
*.local.md

# OS
.DS_Store
Thumbs.db
```

---

## Makefile

```makefile
.PHONY: install validate tasks status

WORKSPACES := $(wildcard workspaces/*)

install:
	@echo "→ Installing policy config to ~/.claude-assistant/config/"
	@mkdir -p ~/.claude-assistant/config
	@cp config/*.md config/*.yaml ~/.claude-assistant/config/

	@echo "→ Linking shared skills into workspace .claude/skills/"
	@for ws in $(WORKSPACES); do \
		mkdir -p $$ws/.claude/skills; \
		for skill_dir in shared/skills/*/; do \
			name=$$(basename $$skill_dir); \
			target=$$ws/.claude/skills/$$name; \
			if [ ! -e "$$target" ]; then \
				ln -sf $$(pwd)/$$skill_dir $$target; \
				echo "   linked $$name → $$ws/.claude/skills/"; \
			fi; \
		done; \
	done

	@echo "→ Creating gitignored runtime directories"
	@for ws in $(WORKSPACES); do \
		mkdir -p $$ws/inbox \
		         $$ws/outputs/daily \
		         $$ws/outputs/weekly \
		         $$ws/outputs/drafts \
		         $$ws/projects \
		         $$ws/second-brain; \
		touch $$ws/MEMORY.md; \
	done

	@echo "Done. Point Cowork at workspaces/<name>/"

validate:
	@echo "→ Checking task skill references..."
	@fail=0; \
	for task in workspaces/*/tasks/*.task.md; do \
		skill=$$(grep '^skill:' $$task | awk '{print $$2}' | sed 's|^/||'); \
		if [ -n "$$skill" ] && [ ! -d "shared/skills/$$skill" ]; then \
			echo "  WARN $$task: references unknown skill /$$skill"; \
			fail=1; \
		fi; \
	done; \
	[ $$fail -eq 0 ] && echo "  All skill references valid."

tasks:
	@echo "Scheduled tasks — reinstall checklist:"
	@echo ""
	@for task in workspaces/*/tasks/*.task.md; do \
		ws=$$(echo $$task | cut -d/ -f2); \
		name=$$(grep '^name:' $$task | awk '{print $$2}'); \
		sched=$$(grep '^schedule:' $$task | awk '{print $$2}'); \
		skill=$$(grep '^skill:' $$task | awk '{print $$2}'); \
		enabled=$$(grep '^enabled:' $$task | awk '{print $$2}'); \
		echo "  [$$ws] $$name"; \
		echo "    skill: $$skill  schedule: $$sched  enabled: $$enabled"; \
		echo ""; \
	done

status:
	@echo "Workspaces:"
	@for ws in $(WORKSPACES); do \
		skills=$$(ls $$ws/.claude/skills 2>/dev/null | wc -l | tr -d ' '); \
		tasks=$$(ls $$ws/tasks/*.task.md 2>/dev/null | wc -l); \
		echo "  $$ws: $$skills skills, $$tasks task definitions"; \
	done
```

---

## Global Instructions

Paste this into Settings → Cowork → Global Instructions. It applies to every session in every workspace.

```
Before every task, read these files from the working folder:
  context/about-me.md
  context/voice-and-style.md
  context/anti-ai-writing-style.md
  MEMORY.md (if it exists and has content)

Output rules:
  Write all outputs to outputs/{daily,weekly,drafts}/ only.
  Never write to context/, tasks/, templates/, or the root of the working folder.

Confirmation required before:
  Sending any email or message
  Deleting any file
  Creating or modifying a calendar event
  Submitting any form or making any purchase

No confirmation needed for:
  Applying Gmail labels
  Creating draft replies (shown, not sent)
  Reading any file in the working folder
  Writing to outputs/

After I approve a plan, execute it fully without further check-ins.
```

---

## workspace CLAUDE.md template

```markdown
# CLAUDE.md — [workspace name]

## Identity
[Name], [role] at [company].
Primary tools: Gmail, Google Calendar, Slack, Notion.

## Role
Executive assistant. Manage inbox, calendar, meeting prep and follow-up,
task tracking, and weekly reviews.
Proactively surface things I should know before I ask.

## Context files
Read these at the start of every session:
  context/about-me.md       — priorities, key relationships, current projects
  context/voice-and-style.md — how I write; mirror this in all drafts
  context/anti-ai-writing-style.md — patterns to never use

## Behavioral rules
Read and apply shared/rules/core-behavior.md.
Read and apply shared/rules/file-safety.md.

Note: if @ imports do not work in this environment, read those files explicitly
before the first task and apply their contents.

## File locations
Working folder: [absolute path, e.g. ~/daddia-assistant/workspaces/personal]
Policy files:   ~/.claude-assistant/config/
Templates:      templates/ (fall back to ../../shared/templates/ if not overridden)
Output:         ALWAYS write to outputs/{daily,weekly,drafts}/

## Inline triggers
Email send:        use the send-email skill — the Gmail MCP connector can only draft
Meeting transcripts: pull from Granola, save to projects/<name>/transcripts/
Reminders:         Apple Reminders via osascript (macOS)

## Style
Lead with the recommendation, then the reasoning.
Tables over paragraphs for anything comparing two or more things.
Flag assumptions explicitly: "I'm assuming X — confirm before I proceed."
Never use: em-dashes, "delve", "leverage", "robust", "streamline", "synergy".
```

---

## .task.md format

Each scheduled task gets its own file. The YAML frontmatter is machine-readable (used by `make tasks`). The body is the verbatim prompt to paste into Cowork when creating or recreating the scheduled task.

```markdown
---
name: morning-brief
description: Daily morning briefing — calendar, inbox highlights, goal alignment
schedule: "30 7 * * 1-5"
skill: /morning-brief
enabled: true
output: outputs/daily/{{date}}-brief.md
connectors:
  - gmail
  - google-calendar
---

## Scheduled task prompt

Run /morning-brief. Save output to outputs/daily/YYYY-MM-DD-brief.md.

## How to recreate in Cowork

Open a Cowork session pointed at this workspace and run:

  /schedule "Every weekday at 7:30am: run /morning-brief and save
  the output to outputs/daily/YYYY-MM-DD-brief.md"

Or paste the 5-field cron directly: 30 7 * * 1-5

## Prerequisites
- Gmail and Google Calendar connectors connected
- ~/.claude-assistant/config/calendar-policy.md populated
- ~/.claude-assistant/config/goals.yaml populated
- Machine must be awake; Claude Desktop must be open and Cowork view focused (macOS bug)

## Known issues
Misses when laptop sleeps. Workaround: run on a dedicated always-on machine
with `caffeinate -dimsu` in Login Items, or move to cron-on-server calling the API.
```

---

## SKILL.md format and conventions

Skills live in `shared/skills/<category>/<skill-name>/SKILL.md`. Each skill is a folder so it can include `scripts/`, `references/`, and `assets/` subdirectories loaded on demand.

Minimal complete skill:

```markdown
---
name: triage-inbox
description: Classify, label, and archive low-value email. Invoke when the user
  says "triage my inbox", "clean up email", "morning email", or asks about
  unread count. Run before /morning-brief and /checkin.
---

# Triage inbox

## When to activate
User asks to triage, clean up, or process email. User mentions inbox overload.
User starts a morning session.

## Step 1 — Read policy
Read ~/.claude-assistant/config/email-policy.md (VIP tiers, auto-archive list).
Read ~/.claude-assistant/config/triage-config.md (label IDs, score thresholds).

## Step 2 — Fetch
Call mcp__google_workspace__list_messages: unread, last 24 hours.

## Step 3 — Classify
For each message, score against policy file thresholds.
Tier 1 VIP → never touch, surface in summary.
Newsletter platform domain → @ToRead label.
noreply/receipt sender → Auto-Archive.
Score 0 (ambiguous) → SKIP, leave in inbox, flag in summary.

## Step 4 — Propose and confirm
Show proposed actions as a table before applying any.
Apply only on explicit confirmation.
Never mark a Tier 1 VIP as read without separate confirmation.

## Step 5 — Summary
Return: count actioned, count skipped, count in inbox remaining.
List anything flagged as potentially important despite archiving.

## What this skill does NOT do
Does not send, reply to, or delete any email.
Does not access emails older than 48 hours unless explicitly asked.
```

**Skill naming rules:**
- Folder name = slash command name: `triage-inbox/` → `/triage-inbox`
- Description must be "pushy" — Claude under-triggers on weak descriptions. Include trigger phrases explicitly.
- Keep SKILL.md under 300 lines. Deeper reference goes in `references/` subdirectory.
- Single-purpose. One skill, one job. `/checkin` calls `/triage-inbox` — it does not replicate triage logic.

**Skill dependency pattern (convention, not enforced):**
```
/morning-brief  reads  calendar-policy.md, goals.yaml
/triage-inbox   reads  email-policy.md, triage-config.md
/checkin        calls  /triage-inbox + /morning-brief outputs
/post-meeting   reads  projects/<name>/transcripts/latest.md
/done           writes MEMORY.md (append, never overwrite)
/standup        reads  MEMORY.md, surfaces continuity
```

---

## Plugins vs skills — when to use each

| Use case | Solution |
|---|---|
| Personal workflow, single user | Skill in `shared/skills/` |
| Workspace-specific override | Skill in `workspace/.claude/skills/` |
| Bundle skills + connectors + slash commands for team | Plugin in `plugins/` |
| Distribute to colleagues via private marketplace | Plugin in `plugins/`, host marketplace on GitHub |
| Anthropic marketplace plugin, use as-is | Install via Cowork UI, no repo needed |
| Fork a marketplace plugin and customise | Copy into `plugins/`, edit SKILL.md and `.mcp.json` |

**Plugin structure (`plugins/personal-ea/`):**

```
personal-ea/
├── .claude-plugin/
│   └── plugin.json          # manifest
├── .mcp.json                # connector wiring
├── skills/
│   └── triage-inbox/        # override of shared/ version
│       └── SKILL.md
└── commands/
    └── brief.md             # /ea:brief explicit command
```

`plugin.json` minimal:
```json
{
  "name": "personal-ea",
  "version": "1.0.0",
  "description": "Personal executive assistant: inbox, calendar, briefings",
  "skills": ["skills/triage-inbox"],
  "commands": ["commands/brief.md"]
}
```

To host a private marketplace: create a GitHub repo, add `.claude-plugin/marketplace.json` listing your plugins, then run `/plugin marketplace add your-org/your-repo` inside Cowork.

---

## Multi-workspace guidance

Each workspace in `workspaces/` is an independent Cowork environment. Common patterns:

**personal/ vs work/** — different context files (separate `about-me.md`, `calendar-policy.md`), same shared skills. Install creates symlinks in both. Policy files under `config/` can have `personal.email-policy.md` and `work.email-policy.md` variations; `make install` copies both and CLAUDE.md references the right one by name.

**Keeping shared skills current** — if you edit a skill in `shared/skills/`, the symlink means all workspaces immediately see the change. No re-install needed. If you override a skill locally in `workspace/.claude/skills/`, the local version takes precedence (directory takes priority over symlinked directory at same path — test this; if symlinks cause ambiguity, copy instead of symlink and re-run `make install` explicitly).

**Team distribution** — teammates fork the repo, fill in their own `context/` files, run `make install`. Skills, rules, and templates are shared; identity files are personal. Never commit `context/about-me.md` with real personal content — keep a `context/about-me.md.example` in the repo and add the real file to `.gitignore`.

Add to `.gitignore` for team use:
```gitignore
workspaces/*/context/about-me.md
workspaces/*/context/voice-and-style.md
workspaces/*/context/anti-ai-writing-style.md
config/email-policy.md
config/goals.yaml
```
And add `*.example` versions of each for teammates to copy and fill in.

---

## Governance

**The one rule that prevents most accidents:** Claude writes to `outputs/` only. Everything else is read-only unless explicitly prompted. Encode this in both Global Instructions and `shared/rules/file-safety.md`.

`shared/rules/file-safety.md`:
```markdown
# File safety rules

Claude may READ any file in the working folder.

Claude may WRITE only to:
  outputs/daily/
  outputs/weekly/
  outputs/drafts/
  MEMORY.md (append only, via /done skill)

Claude must ASK before writing anywhere else.

Claude must NEVER:
  Modify context/, tasks/, templates/, shared/, config/
  Delete files without explicit "delete this file" instruction
  Write to any path outside the working folder
  Access ~/.ssh, ~/.aws, ~/.claude, or any credential directory
```

**Reviewing what ran** — the `outputs/` directory is the audit trail. Every scheduled task should save its output there with a dated filename. `/done` appends a session log to `MEMORY.md`. Review `outputs/daily/` each morning to see what ran overnight.

**MEMORY.md discipline** — `MEMORY.md` is append-only by convention. Skills never overwrite it, only append. This gives you a linear history. Prune it manually when it gets long (monthly is typical) by extracting anything that's become permanent context into `context/working-rules.md`.

**Graduated autonomy** — don't grant write permissions broadly from day one:
1. Week 1: approve every action. Learn what Claude proposes.
2. Week 2: auto-approve label-application and draft creation. Confirm sends.
3. Week 3+: auto-approve outputs that go to `outputs/` without human review needed. Never auto-approve sends, deletes, or calendar mutations.

**CHANGELOG.md** — record meaningful config changes:
```markdown
## 2026-05-25
- Added work/ workspace
- Split email-policy.md into personal and work variants
- Disabled Computer Use on personal workspace

## 2026-05-10
- Upgraded /triage-inbox to v2 (added expense categorisation)
- Added goals.yaml with Q2 objectives
```

This matters when something breaks. "When did the triage start behaving differently?" is answerable.