# AI Assistant ADK — Product strategy & architecture

The **AI Assistant ADK** (Agent Development Kit) is a provider-agnostic toolkit for building AI-powered personal and team assistants. You version skills, rules, workspace layout, and context in Git; each **workspace** is a separate assistant project (personal, work, side project, etc.) that any supported agent runtime can load.

This document is the product and architecture source of truth. For practitioner patterns and research notes, see [research.md](./research.md). For end-user setup, see the [user guide](../guide/00-introduction.md) and [README](../../README.md).

---

## Product vision

**What we are building**

- Not a single shipped assistant product, but a **kit** others fork and adapt.
- **Portable artifacts** — workspaces, `context/`, skills (`SKILL.md`), `rules/`, config examples, task specs — that work across runtimes where possible.
- **Provider adapters** — runtime-specific setup (folder picker, global instructions, scheduling UI, connector wiring).

**Who it is for**

- Builders who want a structured starting point for Cowork-, Claude Code-, or Cursor-style agents.
- People who care about privacy (local files, gitignored personal workspaces) and repeatable behaviour (skills + rules in version control).

**Reference implementation (v0)**

- **Template workspace:** [`workspaces/my-assistant/`](../../workspaces/my-assistant/) — publishable, fictional/generic context; safe to commit.
- **Bundled plugins:** [`skills/assistant/`](../../skills/assistant/) (install, setup, memory) and [`skills/productivity/`](../../skills/productivity/) (start, update, tasks, memory sync).
- **Primary runtime today:** [Claude Cowork](https://claude.com/product/cowork) and Claude Code (install prompt in README). Additional providers are planned, not fully documented yet.

**Naming**

- **ADK** — Agent Development Kit.
- **AI Assistant ADK** — the repo and toolkit brand (ADK focused on assistant/agent workflows).
- **my-assistant** — the default template workspace and GitHub repo name (`daddia/my-assistant`); users copy it to `personal-assistant` or other workspace names locally.

---

## Portable vs provider-specific

| Portable (ADK core) | Provider-specific (adapter) |
|-----------------------|-----------------------------|
| `workspaces/<name>/CLAUDE.md`, `context/*.md` | Cowork: Settings → folder; Global Instructions |
| `skills/*/skills/<name>/SKILL.md` (canonical source) | Cowork: `.claude/skills/` copies in each workspace |
| `rules/*.md` | Cursor: `.cursor/rules` or project rules (TBD) |
| `config/*.example.*` | Connector install via Cowork UI / MCP |
| `tasks/*.task.md` (prompt + metadata) | Cowork `/schedule` or UI to create schedules |
| `TASKS.md`, `MEMORY.md`, `memory/`, `output/` | Managed Agents / Cloud Agents APIs (TBD) |

**Design goal:** keep skill instructions and connector references **category-based** (chat, email, calendar) so the same skill text survives provider changes. See [`skills/productivity/CONNECTORS.md`](../../skills/productivity/CONNECTORS.md).

**Honest scope (v0):** install and setup flows are documented for Claude Code + Cowork. Other providers should reuse the same files where their runtimes read Markdown skills and project instructions; adapter docs will grow over time.

---

## Design decisions

**Should config live in Git?**  
Yes. Skills, rules, templates, workspace structure, and *example* policy files are versioned. Runtime state (`MEMORY.md`, `TASKS.md`, `output/`, `inbox/`, etc.) is not. Policy files with real VIPs, label IDs, and goals are instantiated locally from `*.example` templates.

**How do skills reach a workspace?**  
Canonical skills live under `skills/assistant/skills/` and `skills/productivity/skills/`. On install, they are **copied** into `workspaces/<name>/.claude/skills/` (see [Installation](#installation)). The publishable template [`workspaces/my-assistant/.claude/skills/`](../../workspaces/my-assistant/.claude/skills/) also includes optional session skills (`/done`, `/standup`, `/weekly-review`, etc.) for continuity workflows. When you change a canonical skill, sync the template workspace copy before release (see [CONTRIBUTING.md](../../CONTRIBUTING.md)).

**Can Cowork use a `.claude/` directory in the working folder?**  
Yes (Cowork adapter). Cowork reads `<workspace>/.claude/skills/` when pointed at a workspace subdirectory. The repo-root [`AGENTS.md`](../../AGENTS.md) / [`CLAUDE.md`](../../CLAUDE.md) applies when Claude Code or Cursor agents run from the repo root, not when Cowork is pointed at a workspace folder.

**Can tasks be defined in files?**  
Partially. Cowork does not auto-import `tasks/*.task.md`. Each file is a human-readable spec, verbatim prompt, and rebuild checklist. After cloning on a new machine, recreate schedules in Cowork or use external automation (see [`.task.md` format](#taskmd-format)).

**Can schedules be defined in code?**  
Not natively in Cowork. For reliable scheduling, use external cron (GitHub Actions, server, etc.) with the task prompt. The `tasks/` directory remains the source of truth.

**Global Instructions vs CLAUDE.md vs context files** (Cowork adapter)

| Layer | Location | Purpose |
|-------|----------|---------|
| **Global Instructions** | Settings → Cowork → Global Instructions | Short, universal rules across all workspaces. Under ~20 lines. |
| **CLAUDE.md** | `workspaces/<name>/CLAUDE.md` | Workspace-specific: role, tools, paths, confirmation policy, commands. |
| **context/** | `workspaces/<name>/context/*.md` | Identity, voice, rules. Long-form reference; loaded when relevant. |

---

## Directory tree

Current canonical layout (target state for contributors):

```
assistant/                              # git repo root (AI Assistant ADK)
│
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── AGENTS.md                           # repo-root agent instructions
│
├── skills/
│   ├── assistant/                      # install, setup, memory plugin
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/
│   │       ├── install/SKILL.md
│   │       ├── setup/SKILL.md
│   │       └── memory/SKILL.md
│   └── productivity/                   # tasks, memory sync plugin
│       ├── .claude-plugin/plugin.json
│       ├── .mcp.json
│       ├── CONNECTORS.md
│       └── skills/
│           ├── start/SKILL.md
│           ├── update/SKILL.md
│           ├── task-management/SKILL.md
│           └── memory-management/SKILL.md
│
├── rules/                              # shared behaviour (referenced from CLAUDE.md)
│   ├── core-behavior.md
│   ├── file-safety.md
│   └── tone.md
│
├── config/                             # example templates only in Git
│   ├── email-policy.example.md
│   ├── triage-config.example.md
│   ├── calendar-policy.example.md
│   └── goals.example.yaml
│
├── docs/
│   ├── guide/                          # end-user documentation
│   └── product/
│       ├── strategy.md                 # this file
│       └── research.md
│
└── workspaces/
    ├── my-assistant/                   # publishable template (committed)
    │   ├── CLAUDE.md
    │   ├── context/                    # generic placeholders
    │   ├── .claude/skills/             # shipped skill copies + session skills
    │   ├── tasks/
    │   └── templates/
    │
    ├── example/                        # optional legacy demo (if present)
    └── personal-assistant/             # local only — gitignored
```

**Runtime directories** (created at install, gitignored for personal workspaces):

```
workspaces/<name>/
├── MEMORY.md                           # cross-session continuity
├── TASKS.md                            # markdown task list (productivity plugin)
├── memory/                             # extended memory store
├── inbox/
├── output/
│   ├── daily/
│   ├── weekly/
│   └── drafts/
├── projects/
└── .claude/skills/                     # copies from skills/* (and optional extras)
```

**Legacy `shared/`:** an older layout (`shared/skills/`, `shared/rules/`, `shared/templates/`) may still exist in the repo during migration. New work should use `skills/`, `rules/`, and workspace `templates/` — not add new content under `shared/` unless explicitly consolidating.

---

## Publication and privacy

Designed for **public distribution**. Nothing committed under `workspaces/my-assistant/` or `config/*.example.*` should contain real names, contact details, financial data, or other private information.

**Safe to commit**

- `skills/`, `rules/`, `docs/`, root `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`
- `config/*.example.*` — placeholders only
- `workspaces/my-assistant/` — template context and demo content only

**Never commit**

- `workspaces/personal-assistant/` or any filled-in personal workspace (enforced via `.gitignore`)
- Populated `config/` without `.example` in the filename
- Real `MEMORY.md`, `output/`, `inbox/`, `projects/` from your personal machine
- `.env`, secrets, `*.local.md`

**Current `.gitignore` pattern:**

```gitignore
workspaces/*
!workspaces/my-assistant/

config/
!config/*example.*
```

**Personal use:** copy `workspaces/my-assistant/` → `workspaces/personal-assistant/`, run install (below), run `/setup` in Cowork, replace `context/` with your real details. Keep the personal workspace gitignored.

---

## Installation

### Agentic install (recommended)

Paste the README install prompt into **Claude Code** (or any agent with repo access). It follows [`skills/assistant/skills/install/SKILL.md`](../../skills/assistant/skills/install/SKILL.md):

1. Clone `https://github.com/daddia/my-assistant`
2. Copy `workspaces/my-assistant/` → `workspaces/personal-assistant/` (or another name)
3. Create runtime dirs (`output/`, `inbox/`, `projects/`, `memory/`, `MEMORY.md`, `TASKS.md`)
4. Copy plugin skills into `workspaces/<name>/.claude/skills/`

### Manual install

```bash
REPO=~/my-assistant
WS=$REPO/workspaces/personal-assistant

cp -R $REPO/workspaces/my-assistant $WS
mkdir -p $WS/output/{daily,weekly,drafts} $WS/inbox $WS/projects $WS/memory
touch $WS/MEMORY.md $WS/TASKS.md

ASSISTANT=$REPO/skills/assistant/skills
PRODUCTIVITY=$REPO/skills/productivity/skills
DEST=$WS/.claude/skills
mkdir -p "$DEST"
cp -R "$ASSISTANT"/* "$DEST"/
cp -R "$PRODUCTIVITY"/* "$DEST"/
```

### Point the runtime at the workspace

- **Cowork:** Settings → folder → `workspaces/personal-assistant/` (not repo root).
- **Claude Code at repo root:** uses `AGENTS.md` for install/setup skills; workspace work happens inside the workspace folder when Cowork or a subagent is pointed there.

Then run **`/setup`** in Cowork to populate `context/` through conversation.

---

## Cowork adapter

### Global Instructions

Paste into **Settings → Cowork → Global Instructions**. Applies to every Cowork session.

```
Before every task, read these files from the working folder if they exist:
  context/about-me.md
  context/working-rules.md
  context/voice-and-style.md
  context/anti-ai-writing-style.md
  MEMORY.md (if it has content)

Output rules:
  Write all finished artefacts to output/{daily,weekly,drafts}/ only.
  Never write to context/, tasks/, templates/, or the workspace root except TASKS.md and MEMORY.md as defined by skills.

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

Adjust if a workspace does not use email or calendar connectors.

### Recreating scheduled tasks

See [`.task.md` format](#taskmd-format). Cowork does not read these files automatically; use them as specs when rebuilding schedules on a new machine.

---

## Workspace CLAUDE.md

Each workspace has a root `CLAUDE.md` (not only under `.claude/`). It defines scope, role, which `context/` files to load, slash commands, and output paths.

See [`workspaces/my-assistant/CLAUDE.md`](../../workspaces/my-assistant/CLAUDE.md) for the reference template. Reference shared rules from the repo:

```markdown
## Behavioural rules
Read and apply (from repo root when path is known):
  rules/core-behavior.md
  rules/file-safety.md
```

If `@` imports are unavailable, the agent should read those files explicitly before the first task.

---

## Context files

The **my-assistant** template uses four files (populated by `/setup`):

| File | Contents |
|------|----------|
| `about-me.md` | Identity, household, priorities, what you want help with |
| `working-rules.md` | Scope, privacy, acting on your behalf, safety |
| `voice-and-style.md` | How to write to you and as you |
| `anti-ai-writing-style.md` | Banned phrases and patterns |

Keep `about-me.md` focused (~2,000 words max). Session-specific state belongs in `MEMORY.md` and `memory/`.

Older workspaces may use `rules.md` / `style.md`; new templates should prefer the four-file model above.

---

## SKILL.md format

Canonical skills live in:

- `skills/assistant/skills/<name>/SKILL.md`
- `skills/productivity/skills/<name>/SKILL.md`

Folder name maps to slash command where the runtime supports it: `setup/` → `/setup`.

```markdown
---
name: weekly-review
description: Run a structured weekly review. Use when the user says "weekly review"
  or "wrap up the week".
---

# Weekly review

## When to activate
...

## What this skill does NOT do
Does not send email or edit context/ without confirmation.
```

**Conventions**

- Descriptions must be explicit — Cowork under-triggers on weak descriptions.
- Keep `SKILL.md` under ~300 lines; use `references/` for depth.
- One skill, one job. Chain via documentation, not duplicated logic.
- Prefer connector **categories** over product names in skill text.

**Bundled commands (reference workspace)**

| Command | Plugin | Purpose |
|---------|--------|---------|
| `/setup` | assistant | Guided context configuration |
| `/start` | productivity | Initialise tasks and memory |
| `/update` | productivity | Triage tasks, memory gaps |
| `/done`, `/standup`, `/weekly-review` | template extras | Session continuity (in template `.claude/skills/`) |

---

## .task.md format

Each scheduled task can have one file under `workspaces/<name>/tasks/`. YAML frontmatter supports rebuild checklists; the body is the verbatim prompt.

```markdown
---
name: weekly-review
description: Friday afternoon review
schedule: "0 16 * * 5"
skill: /weekly-review
enabled: true
output: output/weekly/{{date}}-review.md
---

## Scheduled task prompt

Run /weekly-review. Save output to output/weekly/YYYY-MM-DD-review.md.

## How to recreate in Cowork

/schedule "Every Friday at 4pm: run /weekly-review and save to output/weekly/YYYY-MM-DD-review.md"
```

---

## Multi-workspace patterns

Each folder under `workspaces/` is a separate assistant project (separate Cowork folder, separate context).

| Workspace | Use case |
|-----------|----------|
| **my-assistant** | Published template; fork for new assistants |
| **personal-assistant** | Local personal life (gitignored) |
| **work** (optional) | Professional context, separate policies |
| **example** (optional) | Legacy demo persona if retained |

**Skill updates:** edit canonical files under `skills/`, then copy into each workspace's `.claude/skills/` (or re-run install steps). The template `workspaces/my-assistant/.claude/skills/` must stay in sync for releases.

**Local overrides:** place a skill only in `workspaces/<name>/.claude/skills/<skill-name>/` to override the copied version for that workspace.

**Policy files:** instantiate `config/*.example.*` locally; reference the right policy from each workspace `CLAUDE.md` when email/calendar skills are enabled.

---

## Plugins vs skills

| Use case | Solution |
|----------|----------|
| Core ADK flows (install, setup, tasks) | `skills/assistant/`, `skills/productivity/` |
| Workspace-specific override | `workspaces/<name>/.claude/skills/<name>/` |
| Bundle skills + MCP for distribution | `.claude-plugin/plugin.json` + `.mcp.json` per plugin |
| Anthropic marketplace | Install via Cowork UI (optional) |

This repo ships **local plugins** (Markdown skills, no black-box install). Convert or publish to a marketplace when distributing to a team. See [research.md](./research.md).

---

## Governance

**Primary safety rule:** agents write finished work to `output/` only unless a skill explicitly allows `TASKS.md` / `MEMORY.md` updates. Encoded in Cowork Global Instructions and [`rules/file-safety.md`](../../rules/file-safety.md).

**Graduated autonomy**

1. Week 1 — approve every external action.
2. Week 2 — auto-approve labels and drafts; confirm sends.
3. Week 3+ — auto-approve `output/` writes; never auto-approve sends, deletes, or calendar mutations.

**MEMORY.md** — append-only where skills define it; prune periodically; promote stable facts into `context/about-me.md` or `working-rules.md`.

**Audit trail** — dated files under `output/daily/` and `output/weekly/`.

**CHANGELOG.md** — record user-visible releases at repo root; use this file's changelog for major architecture shifts.

---

## Roadmap (product)

Phased delivery (**Now → Next → Future**) is maintained in [roadmap.md](./roadmap.md). Summary:

| Phase | Focus |
|-------|--------|
| **Now** | Desktop Cowork, my-assistant template, install/setup plugins, security & privacy baseline |
| **Next** | Cloud running, additional providers, more example assistants, enhanced security & privacy |
| **Future** | Template gallery, scheduling abstraction, team plugin distribution |

Product definition: [product.md](./product.md).

---

## Getting started (quick path)

1. Clone the repo (or use the README prompt in Claude Code).
2. Run install → `workspaces/personal-assistant/` with skills copied.
3. Optional: paste [Global Instructions](#global-instructions) into Cowork.
4. Open Cowork → folder → your workspace.
5. Run `/setup`, then `/start`.
6. Copy and fill `config/*.example.*` locally when adding email/calendar skills.

For scheduling caveats and connector limits, see [research.md](./research.md).

---

## Changelog (architecture)

```markdown
## 2026-05-27
- Repositioned as AI Assistant ADK (provider-agnostic toolkit)
- Canonical layout: skills/assistant, skills/productivity, rules/, workspaces/my-assistant
- Agentic install via install skill; scripts/install.sh deprecated
- Context model: four files (about-me, working-rules, voice-and-style, anti-ai-writing-style)
- Cowork-specific guidance labeled as adapter

## 2026-05-25
- Initial spec (Claude Cowork multi-agent workspace; shared/, workspaces/example)
```
