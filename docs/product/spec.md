# Claude Cowork Multi-Agent Workspace — Specification

A version-controlled layout for running multiple **Claude Cowork** assistants from one Git repo. Each workspace is an independent Cowork project (personal, work, side project, etc.) with shared skills, rules, and templates.

This spec is designed for **public distribution**. Nothing in `shared/`, `config/*.example`, or `workspaces/example/` should contain real names, contact details, financial data, or other private information. Personal workspaces live locally and stay out of Git (see [Publication and privacy](#publication-and-privacy)).

For background and practitioner patterns, see [research.md](./research.md).

---

## Design decisions

**Should config live in Git?**  
Yes. Skills, rules, templates, workspace structure, and *example* policy files are versioned. Runtime state (`MEMORY.md`, `output/`, `inbox/`, etc.) is not. Policy files with real VIPs, label IDs, and goals are instantiated locally from `*.example` templates.

**Can Cowork use a `.claude/` directory in the working folder?**  
Yes. Cowork reads `<workspace>/.claude/CLAUDE.md` and `<workspace>/.claude/skills/` when pointed at a workspace subdirectory. The repo-root `CLAUDE.md` applies only when Claude Code is run from the repo root.

**How do shared skills reach a workspace?**  
Run `scripts/install.sh` (or follow the manual steps in [Installation](#installation)). It symlinks `shared/skills/<category>/<name>/` into each workspace's `.claude/skills/<name>/`. Workspace-specific skill overrides go directly in `workspaces/<name>/.claude/skills/`.

**Can tasks be defined in files?**  
Partially. Cowork creates scheduled tasks via the UI or `/schedule` inside a session — there is no file Cowork reads to auto-create them. The `tasks/` directory stores a `.task.md` per schedule: human-readable spec, verbatim prompt to paste into Cowork, and metadata for rebuild checklists. After cloning on a new machine, open each `.task.md` and recreate the task in Cowork.

**Can schedules be defined in code?**  
Not natively. For reliable scheduling, use external cron (GitHub Actions, server, Render) calling the Claude API with the task prompt. The `tasks/` directory is the source of truth for both Cowork UI schedules and any automation layer.

**Global Instructions vs CLAUDE.md vs context files**

| Layer | Location | Purpose |
|-------|----------|---------|
| **Global Instructions** | Settings → Cowork → Global Instructions | Short, universal rules across all workspaces. Under ~20 lines. |
| **CLAUDE.md** | `workspaces/<name>/CLAUDE.md` | Workspace-specific: role, tools, paths, confirmation policy, inline triggers. |
| **context/** | `workspaces/<name>/context/*.md` | Identity, voice, rules. Long-form reference; loaded when relevant, not every token. |

---

## Directory tree

```
assistant/                              # git repo root
│
├── .gitignore
├── README.md
├── CHANGELOG.md
│
├── scripts/
│   └── install.sh                      # symlink skills, create runtime dirs, copy config templates
│
├── shared/                               # versioned; shared across all workspaces
│   ├── skills/
│   │   ├── session/
│   │   │   ├── done/SKILL.md             # /done — append decisions + open loops to MEMORY.md
│   │   │   └── standup/SKILL.md          # /standup — read MEMORY.md, surface continuity
│   │   ├── planning/
│   │   │   └── weekly-review/SKILL.md
│   │   └── productivity/
│   │       ├── todo-add/SKILL.md
│   │       └── todo-review/SKILL.md
│   │
│   ├── rules/                            # modular behaviour; referenced from CLAUDE.md
│   │   ├── core-behavior.md
│   │   ├── file-safety.md
│   │   └── tone.md
│   │
│   └── templates/                        # output structure; referenced by path in skills
│       ├── morning-brief.md
│       ├── weekly-review.md
│       └── daily-summary.md
│
├── config/                               # example templates → ~/.claude-assistant/config/
│   ├── email-policy.example.md
│   ├── triage-config.example.md
│   ├── calendar-policy.example.md
│   └── goals.example.yaml
│
└── workspaces/
    ├── example/                          # publishable demo workspace (fictional persona)
    │   ├── CLAUDE.md
    │   ├── context/
    │   │   ├── about-me.md               # fictional — safe to commit
    │   │   ├── rules.md
    │   │   └── style.md
    │   ├── tasks/
    │   │   ├── README.md
    │   │   └── weekly-review.task.md
    │   └── templates/
    │
    └── personal-assistant/               # local only — gitignored; your real workspace
        └── ... (same structure; fill with your own context)
```

**Runtime directories** (created by `install.sh`, gitignored):

```
workspaces/<name>/
├── MEMORY.md                             # cross-session continuity (append-only)
├── inbox/                                # raw input drop zone
├── output/                               # Claude writes finished artefacts here ONLY
│   ├── daily/
│   ├── weekly/
│   └── drafts/
├── projects/                             # active project work
└── .claude/skills/                       # symlinks to shared/skills (regenerated)
```

---

## Publication and privacy

**Safe to commit (public repo):**

- `shared/` — generic skills, rules, templates
- `config/*.example.*` — placeholders only
- `workspaces/example/` — fictional persona and demo content
- `docs/`, `scripts/`, root `README.md`, `CHANGELOG.md`

**Never commit:**

- Real identity files (`about-me.md`, voice profiles) with your name, family, addresses, phone, email
- Populated policy files (`email-policy.md`, `goals.yaml`) with VIPs, label IDs, objectives
- `MEMORY.md`, `output/`, `inbox/`, `projects/` — runtime state
- Any workspace other than `example/` (enforced via `.gitignore`)

**Recommended `.gitignore` pattern:**

```gitignore
# All workspaces except the publishable example
workspaces/*
!workspaces/example/

# Runtime state inside the example workspace (if you run it locally)
workspaces/example/MEMORY.md
workspaces/example/output/
workspaces/example/inbox/
workspaces/example/projects/
workspaces/example/.claude/skills/

# Local config (instantiated from *.example)
config/email-policy.md
config/triage-config.md
config/calendar-policy.md
config/goals.yaml

# Secrets
.env
.env.local
*.local.md
```

**Forking for personal use:** copy `workspaces/example/` to `workspaces/personal-assistant/`, replace `context/` with your files, run `scripts/install.sh`, copy `config/*.example.*` to `~/.claude-assistant/config/` without the `.example` suffix, and fill in real values locally.

---

## Installation

Point Cowork at `workspaces/<name>/` (the workspace folder, not the repo root).

```bash
# From repo root
./scripts/install.sh

# Optional: install only one workspace
./scripts/install.sh workspaces/example
```

The script:

1. Symlinks `shared/skills/*` into each workspace's `.claude/skills/`
2. Creates gitignored runtime directories (`output/`, `inbox/`, `projects/`, `MEMORY.md`)
3. Copies `config/*.example.*` to `~/.claude-assistant/config/` if not already present

**Manual install** (if you prefer not to run the script):

```bash
WS=workspaces/example
mkdir -p "$WS/.claude/skills" "$WS/output/daily" "$WS/output/weekly" "$WS/output/drafts" "$WS/inbox" "$WS/projects"
touch "$WS/MEMORY.md"
for skill in shared/skills/*/*/; do
  name=$(basename "$skill")
  ln -sf "$(pwd)/$skill" "$WS/.claude/skills/$name"
done
mkdir -p ~/.claude-assistant/config
cp config/*.example.* ~/.claude-assistant/config/  # then rename and edit locally
```

---

## Global Instructions

Paste into **Settings → Cowork → Global Instructions**. Applies to every session in every workspace.

```
Before every task, read these files from the working folder if they exist:
  context/about-me.md
  context/rules.md
  context/style.md
  MEMORY.md (if it has content)

Output rules:
  Write all finished artefacts to output/{daily,weekly,drafts}/ only.
  Never write to context/, tasks/, templates/, or the workspace root.

Confirmation required before:
  Sending any email or message
  Deleting any file
  Creating or modifying a calendar event
  Submitting any form or making any purchase

No confirmation needed for:
  Applying Gmail labels (if connected)
  Creating draft replies (shown, not sent)
  Reading any file in the working folder
  Writing to output/

After I approve a plan, execute it fully without further check-ins.
```

Adjust for workspaces that don't use Gmail or calendar connectors.

---

## Workspace CLAUDE.md template

```markdown
# CLAUDE.md — [workspace name]

## Scope
[One line: e.g. "Personal life only — family, home, hobbies. Not work."]

## Role
[What this assistant does. Be specific about proactive vs on-demand.]

## Context files
Read at session start:
  context/about-me.md   — who I am, priorities, current focus
  context/rules.md      — operating rules and guardrails
  context/style.md      — how to write to me and as me

## Behavioural rules
Read and apply:
  ../../shared/rules/core-behavior.md
  ../../shared/rules/file-safety.md

If @ imports do not work, read those files explicitly before the first task.

## File locations
Working folder: [absolute path to this workspace]
Policy files:   ~/.claude-assistant/config/ (if using email/calendar skills)
Templates:      templates/ (fall back to ../../shared/templates/)
Output:         ALWAYS write to output/{daily,weekly,drafts}/

## Inline triggers
[Workspace-specific overrides, e.g. reminders via Apple Reminders, transcript paths]

## Style
Lead with the recommendation, then brief reasoning.
Lists and tables over long paragraphs for operational content.
Flag assumptions: "I'm assuming X — confirm before I proceed."
```

See `workspaces/example/CLAUDE.md` for a filled-in reference.

---

## Context files

Three files in `context/` cover most personal-assistant setups:

| File | Contents |
|------|----------|
| `about-me.md` | Name, location, timezone, family summary (as much as you're comfortable storing), priorities, what you want help with, what to exclude |
| `rules.md` | Scope, privacy, acting on your behalf, money/health/safety, output discipline |
| `style.md` | Voice, spelling/locale, structure, banned phrases, examples of good vs bad |

Keep `about-me.md` under ~2,000 tokens. Detail that rarely changes belongs here; session-specific state belongs in `MEMORY.md`.

For team or public repos: commit `about-me.md.example` with placeholders; keep the real file local or gitignored.

---

## .task.md format

Each scheduled task gets one file. YAML frontmatter supports rebuild checklists; the body is the verbatim prompt for Cowork.

```markdown
---
name: weekly-review
description: Friday afternoon review — wins, misses, open loops, next week priorities
schedule: "0 16 * * 5"
skill: /weekly-review
enabled: true
output: output/weekly/{{date}}-review.md
connectors: []
---

## Scheduled task prompt

Run /weekly-review. Save output to output/weekly/YYYY-MM-DD-review.md.

## How to recreate in Cowork

Open a Cowork session pointed at this workspace and run:

  /schedule "Every Friday at 4pm: run /weekly-review and save
  the output to output/weekly/YYYY-MM-DD-review.md"

Or paste cron: 0 16 * * 5

## Prerequisites
- Machine awake; Claude Desktop open (Cowork view focused on macOS)

## Known issues
Scheduled tasks do not fire when the laptop sleeps. See research.md for workarounds.
```

---

## SKILL.md format

Skills live in `shared/skills/<category>/<skill-name>/SKILL.md`. Folder name = slash command: `weekly-review/` → `/weekly-review`.

```markdown
---
name: weekly-review
description: Run a structured weekly review — wins, misses, decisions, open loops,
  next week's priorities. Use when the user says "weekly review", "wrap up the week",
  or on Friday afternoon.
---

# Weekly review

## When to activate
User asks for a weekly review or end-of-week wrap-up.

## Step 1 — Gather
Read MEMORY.md for recent session notes.
List files in output/daily/ from the past 7 days.
Read context/about-me.md for current priorities.

## Step 2 — Structure
Use shared/templates/weekly-review.md as the outline.

## Step 3 — Write
Save to output/weekly/YYYY-MM-DD-review.md.
Propose capturing any durable context changes to context/ — ask before editing.

## What this skill does NOT do
Does not send email, modify calendar, or edit context/ without confirmation.
```

**Conventions:**

- Descriptions must be explicit ("pushy") — Cowork under-triggers on weak descriptions.
- Keep `SKILL.md` under ~300 lines; use `references/` for depth.
- One skill, one job. Chain via documentation, not duplicated logic.

**Starter dependency map:**

```
/standup        reads  MEMORY.md
/done           appends MEMORY.md
/weekly-review  reads  MEMORY.md, output/daily/, shared/templates/weekly-review.md
/todo-add       writes output/drafts/ or user's task system (document in skill)
```

Extend with communications skills (`/morning-brief`, `/triage-inbox`) when Gmail and calendar connectors are configured; those skills read `~/.claude-assistant/config/` policy files (see `config/*.example.*`).

---

## Multi-workspace patterns

Each folder under `workspaces/` is a separate Cowork project.

| Pattern | Use case |
|---------|----------|
| **personal-assistant** | Home, family, hobbies, personal admin |
| **work** | Professional context, separate `about-me.md` and calendar policy |
| **example** | Demo / onboarding; safe to publish |

**Shared skills:** editing `shared/skills/` updates all workspaces via symlinks. No reinstall needed.

**Local overrides:** place a skill at `workspaces/<name>/.claude/skills/<skill-name>/` to override the shared version for that workspace only.

**Separate policy files:** use `personal.email-policy.md` and `work.email-policy.md` under `~/.claude-assistant/config/`; reference the correct file from each workspace's `CLAUDE.md`.

**Scope boundaries:** encode "personal only" or "work only" in `context/rules.md` and `CLAUDE.md`. When a request crosses scope, flag it and ask before proceeding.

---

## Plugins vs skills

| Use case | Solution |
|----------|----------|
| Personal workflow, single user | Skill in `shared/skills/` |
| Workspace-specific override | Skill in `workspace/.claude/skills/` |
| Bundle skills + connectors for a team | Plugin with `.claude-plugin/plugin.json` + `.mcp.json` |
| Anthropic marketplace plugin | Install via Cowork UI |

This repo starts with **skills only**. Convert to a plugin when distributing to teammates via a private GitHub marketplace. See [research.md](./research.md) § Plugins.

---

## Governance

**Primary safety rule:** Claude writes finished work to `output/` only. Everything else is read-only unless you explicitly ask. Encoded in Global Instructions and `shared/rules/file-safety.md`.

**Graduated autonomy:**

1. Week 1 — approve every action; learn what Claude proposes.
2. Week 2 — auto-approve labels and drafts; confirm sends.
3. Week 3+ — auto-approve `output/` writes; never auto-approve sends, deletes, or calendar mutations.

**MEMORY.md** — append-only via `/done`. Prune monthly; promote stable facts into `context/about-me.md` or `context/rules.md`.

**Audit trail** — dated files in `output/daily/` and `output/weekly/` show what ran. Scheduled tasks should always save output to a dated path.

**CHANGELOG.md** — record meaningful config changes so regressions are traceable.

---

## Getting started (quick path)

1. Clone the repo. Run `./scripts/install.sh workspaces/example`.
2. Paste Global Instructions (above) into Cowork settings.
3. Open Cowork, select folder `workspaces/example/`.
4. Run `/standup` then `/weekly-review` in a test session.
5. Fork: copy `example` → `personal-assistant`, replace `context/` with your files, keep the workspace gitignored.
6. Add connectors (Gmail, Calendar) when ready; copy and fill `config/*.example.*` locally.

For the full practitioner playbook (Blattman EA pattern, scheduling caveats, connector limits), see [research.md](./research.md).

---

## Changelog

Record changes here when skills, rules, or workspace structure change meaningfully.

```markdown
## 2026-05-25
- Initial public spec
- Added workspaces/example with fictional persona
- Shared skills: /done, /standup, /weekly-review, /todo-add, /todo-review
```
