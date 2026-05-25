# Building an Executive Assistant in Claude Cowork: A Practitioner's Guide (May 2026)

## TL;DR

- **The setup is the product.** Out-of-the-box Cowork is mediocre; the value comes from a ~30–60 minute one-time config: a global instructions block, a CLAUDE.md, a small set of context files (about-me, voice, anti-AI-writing), and 3–5 EA skills installed in dependency order. Practitioners are unanimous: the gap between disappointment and "this saves me an hour a day" is config, not prompting.
- **The reference EA architecture has converged on a specific shape.** A working folder containing `CLAUDE.md` + `MEMORY.md` + a `context/` directory of identity files; an `~/.claude-assistant/config/` directory holding policy files (email-policy.md, triage-config.md, calendar-policy.md, goals.yaml); skills installed at `~/.claude/skills/<skill>/SKILL.md`; plugins (skills + connectors + slash commands bundled) distributed via a private GitHub marketplace. Chris Blattman's executive-assistant toolkit and the `anthropics/knowledge-work-plugins` repo are the canonical references.
- **The biggest practical constraints are unsexy.** Scheduled tasks only fire while Claude Desktop is open and the machine is awake; in some macOS builds the Cowork view also has to be focused. Connectors only bind one account per service (one Gmail, one Calendar) — a major pain point for anyone with both personal and work inboxes. Memory only persists inside Cowork *Projects*, not standalone sessions. Plan around these or invest in workarounds (an always-on Mac with caffeinate, Dispatch to phone, secondary Chrome-driven account).

---

## Key Findings

1. **CLAUDE.md in Cowork is the same file as in Claude Code** — markdown, project-root, auto-loaded — but is used differently. In Code it documents codebase conventions; in Cowork it describes *you* (role, tools, file locations, communication style) plus inline triggers ("Use send-email.py — the MCP can only draft"). The community consensus on length: start under 200 lines, target 80–150 once mature, and offload anything detailed into modular rule files under `~/.claude/rules/` that the main file references.

2. **Two distinct "context" layers exist and matter.** *Global Instructions* (Settings → Cowork → Global Instructions) is a short behavioral preamble ("never delete files without confirmation", "always read context/HOW-I-WORK.md before acting"). *Context/identity files* in your working folder (about-me.md, voice-profile.md, anti-AI-writing-style.md, my-company.md) are reference knowledge Claude pulls from when relevant. Rules vs. knowledge. Keep them split.

3. **Skills are folders with a SKILL.md file** (YAML frontmatter + markdown body) stored at `~/.claude/skills/<name>/SKILL.md` (personal, global) or inside a Cowork project folder (project-scoped). The format is the same as Claude Code skills and works across both surfaces. Anthropic recommends keeping the SKILL.md body under 500 lines and offloading deeper detail into `references/`, `scripts/`, and `assets/` subdirectories — loaded only when needed via progressive disclosure.

4. **Plugins are the team-distribution unit.** A plugin = `.claude-plugin/plugin.json` (manifest) + `.mcp.json` (connectors) + `commands/` (explicit slash commands) + `skills/` (auto-loaded domain knowledge). Marketplaces are GitHub repos containing a `.claude-plugin/marketplace.json`. Enterprise admins distribute via Organization Settings → Plugins (private GitHub sync). Solo practitioners run a personal private marketplace as one GitHub repo and install it once across all machines.

5. **The Blattman executive-assistant pattern is now the de facto reference.** Currently 20 skills (per the live skill library page on claudeblattman.com), including `/triage-inbox`, `/morning-brief`, `/checkin`, `/schedule-query`, `/done`, `/todo-add`, `/todo-review`, `/todo-queue`, `/goals-review`, `/pre-meeting-brief`, `/post-meeting`, with explicit config-file dependencies (email-policy.md, triage-config.md, calendar-policy.md, goals.yaml). It's open-source, MIT-licensed, and downloadable via curl from `chrisblattman/claudeblattman` on GitHub. Blattman (political economist at the Harris School of Public Policy, University of Chicago) documented the result on his about page: "A day and a half with Claude Code and it was under control — 5,000 unread emails down to 6."

6. **Anthropic's own `knowledge-work-plugins` repo is the canonical source of plugin examples** — 11+ role-based plugins (productivity, sales, customer-support, product-management, marketing, legal, finance, data, enterprise-search, bio-research, cowork-plugin-management). The repo carried ~11.2k stars and 1.3k forks as of late May 2026. Fork it, edit `.mcp.json` to swap connectors, edit skill files to inject company terminology, push to a private marketplace. The `productivity` plugin is the closest official starting point for a general EA setup.

7. **Scheduled tasks use natural language or 5-field cron syntax**, are created with `/schedule` inside Cowork, and the cron has 1-minute granularity. The single most important caveat: the desktop app must be open and the machine awake — and there is an open bug where on macOS the Cowork *view* must be focused for tasks to fire (anthropics/claude-code #36131). Practitioners run a dedicated always-on Mac with `caffeinate`, or accept that scheduled tasks are best-effort.

8. **Memory is only durable inside Cowork Projects (released March 2026).** Outside of Projects, every session starts fresh. The community-standard workaround is a `MEMORY.md` file in the working folder plus a `/done` or `/session-audit` skill at end-of-session that appends decisions/preferences to it. Inside Projects, Claude writes a `memory.md` directly and reads it on every session.

9. **MCP and connectors can be configured by file, not just UI.** Standard Cowork connectors (Gmail, Google Calendar, Slack, Notion, etc.) are configured in Settings. For custom MCP, Claude Desktop's `claude_desktop_config.json` is bridged into the Cowork VM ("type: sdk" servers). Plugin-scoped MCP servers go in a `.mcp.json` file at the plugin root. On Bedrock/Vertex (third-party platforms), MCP servers are distributed by MDM via a `managedMcpServers` key.

10. **The biggest practitioner complaints are predictable and worth budgeting for:** (a) one Gmail/Calendar account per connector — multi-account users fall back to Chrome browser automation; (b) scheduled tasks silently skip if the laptop sleeps; (c) Cowork burns through usage limits 5–10x faster than chat (a Pro user running daily briefings will need Max); (d) skills under-trigger if descriptions aren't "pushy" enough; (e) memory in standalone sessions is non-existent without Projects.

---

## Details

### 1. Configuration & Context Architecture

**The canonical EA folder layout.** Distilled from Blattman, Sid Bharath, the Atlas `colin-atlas/claude-personal-os` repo, Ruben Hassid, and Jeff Su, every published EA setup is a variation on:

```
~/Claude-Workspace/                       # the folder you point Cowork at
├── CLAUDE.md                             # auto-loaded root instructions
├── MEMORY.md                              # cross-session state Cowork writes/reads
├── context/                               # identity files Claude reads at session start
│   ├── about-me.md
│   ├── voice-and-style.md
│   ├── anti-ai-writing-style.md
│   ├── working-rules.md
│   └── my-company.md
├── inbox/                                 # drop zone for raw inputs
├── outputs/                               # the ONLY place Claude writes finished work
│   ├── daily/
│   ├── weekly/
│   └── drafts/
├── projects/                              # one subfolder per active project
├── templates/                             # reusable structure (meeting notes, weekly review)
└── second-brain/                          # optional PARA-style notes (Obsidian-readable)
```

In parallel, a separate config tree lives outside the working folder:

```
~/.claude/                                # global, multi-project
├── CLAUDE.md                             # symlinked from ~/Dropbox/Claude/Settings/ for sync
├── settings.json
├── skills/                               # personal skills, e.g. ~/.claude/skills/triage-inbox/SKILL.md
└── rules/                                # modular instruction files referenced by CLAUDE.md
    ├── core-voice.md
    ├── email-voice.md
    └── project-management.md

~/.claude-assistant/config/               # Blattman EA toolkit policy files
├── email-policy.md
├── triage-config.md
├── calendar-policy.md
└── goals.yaml
```

**CLAUDE.md in Cowork vs Claude Code.** The file format is identical and both surfaces read from `~/.claude/CLAUDE.md` (and from project-level `CLAUDE.md` or `.claude/CLAUDE.md` in the working folder). The content differs because the audience differs: Code's CLAUDE.md documents the codebase and Cowork's documents the *person and their toolkit*. Same loading semantics, completely different content. Skills work identically across both. Karo Zieminski's "chunked skills" insight applies symmetrically: don't write one giant CLAUDE.md, split into modular `rules/*.md` files referenced from a slim main file.

**Length rules that actually hold up.** Anthropic's Claude Code best practices say "under 200 lines"; Blattman's production CLAUDE.md is 150+ lines but only because he factored 800 lines of detail into six modular rule files. Jeff Su uses a 300-line ceiling for root CLAUDE.md. The principle is the same: CLAUDE.md is always in context, so every word costs tokens on every session. Detail goes into separate files referenced by the main one, loaded on demand via progressive disclosure.

**Identity files — about-me, voice, anti-AI-writing.** Ruben Hassid's pattern (which influenced most of the practitioner community) is three files:
- `about-me.md` — your role, current priorities, key tools (~2,000 tokens trimmed; Hassid started at 22,000 words from a 100-question interview and cut hard)
- `anti-ai-writing-style.md` — banned phrases, sentence-length rules, "never write like this" examples
- `voice-and-style.md` — positive style guide with writing samples

These are stored in the working folder (often a `context/` or `ABOUT ME/` subfolder), and global instructions force Claude to read them before every task. Hassid distributes his templates free at ruben.substack.com.

**Should config live in Git?** Yes. The clearest pattern (Obie Fernandez, Alex McFarland, Blattman): keep everything in a private GitHub repo. Blattman keeps Settings in `~/Dropbox/Claude/Settings/` and symlinks `~/.claude/CLAUDE.md` to it; that gives sync across machines without giving up Git. Version control the CLAUDE.md, skills, plugin marketplace, config templates, voice profiles — but *not* MEMORY.md (it's session state, not config) and definitely not actual personal data files. The single-line install commands in Blattman's repo (`curl -o ~/.claude-assistant/config/email-policy.md https://raw.githubusercontent.com/.../email-policy-template.md`) are the model: templates in Git, instantiated locally.

### 2. Skills — Format, Storage, and Cowork-Specific Nuance

**The SKILL.md spec is open and identical across Cowork, Code, Codex, and Cursor.** Two required frontmatter fields, a markdown body, optional `scripts/`, `references/`, `assets/` subdirectories. The format is governed by agentskills.io as an open standard.

Minimal valid skill:

```markdown
---
name: triage-inbox
description: Scan inbox for emails to auto-label and archive — newsletters, announcements, receipts, low-priority notifications. Use whenever the user says "triage my inbox", "clean up email", or asks about email at the start of the day.
---

# Triage Inbox

## When to activate
- User asks to triage, clean up, or process email
- User mentions inbox overload, unread count, or morning email review

## Step 1 — Read policy files
Read ~/.claude-assistant/config/email-policy.md (VIPs, auto-archive senders).
Read ~/.claude-assistant/config/triage-config.md (label IDs, classification thresholds).

## Step 2 — Fetch
Call mcp__google_workspace__list_messages for the last 24 hours, unread only.

## Step 3 — Classify
[...]

## Step 4 — Apply
Show proposed actions, apply only on confirmation. Never mark VIPs read.
```

**The Cowork-specific tweak that matters.** Karo Zieminski's biggest insight: "Skills in Chat were useful. Skills in Cowork are *operational*. They shape autonomous work." A Cowork skill governs every file Claude creates, not just one reply. So make descriptions "pushy" (Claude under-triggers by default), chunk into single-purpose skills rather than one giant one (Zieminski runs three writing skills: voice / corporate / newsletter), and explicitly state what the skill does *NOT* do.

**Slash commands vs skills — they merged.** A skill at `.claude/skills/triage-inbox/SKILL.md` and a slash command at `.claude/commands/triage-inbox.md` both create `/triage-inbox`. Practitioners now write everything as skills and only use the `commands/` folder when bundling explicit-invocation actions inside a plugin (e.g. `/sales:call-prep`).

**Where to find skills, practical sources in priority order:**
1. **`anthropics/knowledge-work-plugins`** (GitHub, ~11.2k stars / 1.3k forks as of late May 2026) — official, 11 role plugins, Apache 2.0. The `productivity` plugin is the closest EA starting point.
2. **`chrisblattman/claudeblattman`** — the most production-tested EA skill set (currently 20 skills, per the skill library page) all installable via curl.
3. **`EAIconsulting/cowork-skills-library`** — 21 skills explicitly tiered as a learning progression (`/cowork-setup-wizard`, `/teach-claude-your-voice`, `/meeting-machine`, `/weekly-business-pulse`).
4. **`colin-atlas/claude-personal-os`** — fuller "personal OS" template with PARA folders.
5. **`helgejo/cowork-template`** — production workspace template with layered memory.
6. **`gyoung55/cowork-session-skills`** — `/standup` and `/conclude` for the session-memory pattern.
7. **Cross-tool marketplaces** — skills.sh, agentskill.sh, skillsbento.com, LobeHub, ClawHub.

**Forking and customizing.** Skills are markdown files in a folder. Fork the repo, edit the SKILL.md (swap company terminology, adjust thresholds), push to your private marketplace. Inside Cowork the install flow is Customize → Skills → "+" or via the Skill-Creator skill ("Package what we just did into a skill"). One real workflow loop: run the task manually a few times, then ask Claude `"Package what we just did into a skill"` — the built-in skill-creator captures steps, templates, and source locations into a SKILL.md you can refine.

**Skills can chain.** Blattman's `/checkin` explicitly depends on `/triage-inbox` having run; `/morning-brief` reads goals.yaml that `/goals-review` owns. Dependencies are documented in skill bodies, not enforced by the runtime — convention, not code.

### 3. Plugins — Bundling and Distribution

**Anatomy of a plugin** (verbatim from `anthropics/knowledge-work-plugins`):

```
plugin-name/
├── .claude-plugin/plugin.json   # Manifest (name, version, description)
├── .mcp.json                    # MCP server / connector wiring
├── commands/                    # Slash commands (explicit invocation)
│   └── call-prep.md
└── skills/                      # Auto-loaded domain knowledge
    └── pipeline-review/
        └── SKILL.md
```

A plugin = a packaged opinion about how a role works. Skills give Claude knowledge; connectors give it hands; commands give the user a verb. Plugins put all three under one install.

**Marketplaces** are GitHub repos with `.claude-plugin/marketplace.json` listing the plugins inside (or referenced externally by URL). The two public marketplaces shipped with Cowork:
- `anthropics/claude-plugins-official` — curated by Anthropic, auto-available
- `anthropics/claude-community` — community-submitted, install with `/plugin marketplace add anthropics/claude-plugins-community`

**Private marketplace setup** (most useful for EA-class personal workflows and teams):
1. Create a GitHub repo: `your-org/claude-cowork-plugins`
2. Add `.claude-plugin/marketplace.json` listing your plugins
3. Each plugin sits in its own subdirectory with the structure above
4. **Solo / personal:** `/plugin marketplace add owner/repo` in Cowork, install via Customize → Plugins → Browse → Add from GitHub. Works with public repos out-of-box; private repos require auth.
5. **Team:** Organization Settings → Plugins → "Add plugins" → "GitHub" → connect the Claude GitHub App. Auto-syncs on merge. Syncs take up to 30 minutes; failed syncs temporarily remove plugins, so keep your install preferences documented.

Alex McFarland's "private plugin marketplace" pattern (one GitHub repo as source-of-truth for all your skills across all machines and accounts) is the most consistent recommendation for anyone running Cowork on more than one machine.

**Best marketplace plugins for an EA setup (May 2026):**
- **`productivity` (Anthropic)** — task/calendar/daily-workflow scaffolding. Connectors: Slack, Notion, Asana, Linear, Jira, Monday, ClickUp, Microsoft 365.
- **`ericporres/email-triage-plugin`** — three-tier classification, alias-aware routing, reply drafting, archive management. Built from a real 300-alias daily setup.
- **`enterprise-search` (Anthropic)** — cross-system fuzzy search across Slack/Notion/Guru/Jira/Asana/Microsoft 365.
- **Blattman's executive-assistant skills** — installed directly into `~/.claude/skills/`, not via a marketplace, but the simplest path to working EA functionality.
- For team distribution: the `cowork-plugin-management` plugin (from Anthropic) — a meta-plugin that walks you through customizing other plugins for your org via Q&A.

### 4. Tasks vs Scheduled Tasks vs Skills

The vocabulary is muddled because Cowork uses three overlapping concepts:

- **A *task*** in Cowork-speak is just a session — the thing you start when you hit "New task". Configurable only through the UI; there's no schema file for ad-hoc tasks.
- **A *scheduled task*** is a recurring prompt with a cron expression and a saved description, created via `/schedule`. These can be defined in natural language ("every weekday at 8am") or 5-field cron syntax (1-minute granularity, no seconds). Storage is in Cowork's local config; not directly file-defined, though you can ask Claude to list/create/delete them.
- **A *skill*** is the reusable how-to. The community consensus: define the *how* as a skill, and let scheduled tasks invoke the skill. So your 8am scheduled task literally just says "Run /morning-brief" — the work is in the skill.

This is the right division of labor: skills version-controlled in Git, scheduled tasks configured per-machine via UI.

**Scheduled task limitations practitioners actually hit:**
- Computer must be awake; Claude Desktop must be open; **on macOS there's an open bug (anthropics/claude-code #36131) where the Cowork view must be focused, not just the app running**.
- 1-minute minimum granularity, no sub-minute polling.
- Tasks run in their own sessions; you debug via the execution log in Settings.
- Missed runs do not queue or backfill.
- High-frequency tasks queue and execute sequentially if they overlap.

**Workarounds:** dedicated always-on Mac with `caffeinate -dimsu`; Pro users may need Max because scheduled tasks consume usage; for truly mission-critical schedules, push the job to GitHub Actions or cron-on-your-server that calls the Claude API directly (or MindStudio's managed scheduling).

**The most valuable EA scheduled tasks (consensus across Sid Bharath, fourhourfreedom, Blattman, Ruben Hassid):**
- 7:00–7:30am weekday: `/morning-brief` — calendar + inbox highlights + reminders + goal alignment, saved to `outputs/daily/YYYY-MM-DD-brief.md`.
- 8:00am Monday: weekly metrics pull (HubSpot / Stripe / Shopify) into `outputs/weekly/YYYY-MM-DD-metrics.xlsx`.
- 4:00pm Friday: weekly summary from session logs + project folders.
- Sunday evening: 12-Week-Year style weekly review (fourhourfreedom).
- 30 minutes before external meetings: pre-meeting brief.

### 5. Connectors and MCP

**For an EA setup, prioritize in this order:** Gmail, Google Calendar, Google Drive (Workspace MCP gives all three), Slack, Notion, then tool-specific (HubSpot for sales-adjacent EAs, TickTick/Apple Reminders for personal task systems, Granola or Fireflies for meeting transcripts). Anthropic's official Gmail/Google Workspace connector landed in the February 2026 enterprise release.

**Hard limitation:** one account per connector. Multi-Gmail users (personal + work) fall back to Claude in Chrome for the second account — significantly slower and more brittle (see anthropics/claude-code #27567). The pragmatic answer: choose the higher-volume inbox for MCP, route the other through filters or browser automation.

**Custom MCP — three configuration surfaces:**
1. **Claude Desktop's `claude_desktop_config.json`** (local stdio servers). Anything configured here is bridged into the Cowork VM via the SDK layer as `"type": "sdk"` — no extra wiring needed. This is the path-of-least-resistance for running local MCP servers like Apple Reminders bridges, file-system wrappers, or custom workspace tools.
2. **Plugin-scoped `.mcp.json`** at the plugin root. Format mirrors the `managedMcpServers` schema. Distributed automatically when the plugin is installed.
3. **Managed MCP via MDM** on Bedrock/Vertex/Azure-AI-Foundry deployments. Use the `managedMcpServers` key in MDM-pushed config. Each entry needs a unique name and an HTTPS URL; optional fields include transport, headers, OAuth config, and tool-level policies. The "Cowork on 3P" pattern doesn't have a centralized marketplace or admin UI — everything is MDM and filesystem mount.

For remote MCP servers that aren't in Claude Desktop's config, practitioners use `supergateway` + `pm2` to convert stdio MCP servers into HTTP endpoints, which Cowork then connects to as remote servers — gets you to ~18 working MCP servers in a single Cowork session (documented by DEV user murat-a-a).

**Community MCP servers useful for EA workflows:**
- The Rube MCP (used by Obie Fernandez in his CTO-OS setup) — meta-connector that unifies Calendar/Slack/Gmail
- `gws` (Google Workspace CLI) — launched March 2, 2026; trended on Hacker News at 427 points and hit 4,900 GitHub stars in three days per byteiota.com, then reached ~17k stars within a week (awesomeagents.ai) and roughly 20.8k by mid-March (toolworthy.ai). Install with `npm install -g @googleworkspace/cli` then `gws mcp -s drive,gmail,calendar,sheets`
- TickTick MCP (fourhourfreedom)
- Granola MCP for meeting transcripts
- Apple Reminders bridge via macOS `osascript`

### 6. Templates

The pattern is consistent across the community: templates live in a `templates/` folder in the working directory, and skills/global-instructions reference them by path. A skill says "use the structure from templates/weekly-review.md but generate fresh content"; Claude reads the template structure at runtime.

A minimal `templates/weekly-review.md`:

```markdown
# Weekly Review — Week of {{date}}

## Wins
- [bullet per win, with metric or evidence]

## Misses
- [bullet per miss, with cause]

## Decisions Made
- [date] [decision] [rationale]

## Open Loops
- [waiting for X from Y, since Z]

## Next Week's Three Priorities
1.
2.
3.
```

Same model for `templates/meeting-notes.md`, `templates/morning-brief.md`, `templates/daily-summary.md`. Don't make templates clever — they're structural anchors, not generation prompts.

### 7. The Reference EA Setup — End-to-End

A concrete walkthrough using the Blattman pattern (the most production-tested), with the option to swap in Anthropic's `productivity` plugin instead.

**Day 1 setup (~60 min):**

```bash
# Install Claude Desktop, sign in to Pro/Max, open Cowork tab.

# Create the working folder
mkdir -p ~/Claude-Workspace/{context,inbox,outputs/{daily,weekly,drafts},projects,templates}

# Pull Blattman's config templates
mkdir -p ~/.claude-assistant/config
for f in email-policy triage-config calendar-policy; do
  curl -o ~/.claude-assistant/config/$f.md \
    https://raw.githubusercontent.com/chrisblattman/claudeblattman/main/templates/$f-template.md
done
curl -o ~/.claude-assistant/config/goals.yaml \
  https://raw.githubusercontent.com/chrisblattman/claudeblattman/main/templates/goals-yaml-template.yaml

# Pull a starter CLAUDE.md and the EA skills
mkdir -p ~/.claude/skills
# (edit ~/.claude/CLAUDE.md by hand from Blattman's template)

# Open ~/.claude-assistant/config/email-policy.md, replace placeholders with your VIPs.
# Open ~/.claude-assistant/config/triage-config.md, fill in Gmail label IDs.
# Open ~/.claude-assistant/config/calendar-policy.md, set working hours/timezone.
```

**What Blattman's policy files actually look like inside.** From the verbatim content in the templates:

- **`email-policy.md`** declares VIP tiers ("Tier 1 — Never Touch: immediate family, critical institutional"; "Tier 2 — High Priority: collaborators, team") and Auto-Archive in two stages: high-confidence exact-sender matches (`noreply@github.com → Archive + mark read`) and medium-confidence domain patterns (`*@notifications.example.com → Archive + mark read`). Required Gmail labels: `@ToRead`, `@Announcements`, `@School`, `@Family`, `Expenses/Expenses-Pending`, `Auto-Archive`. Default guidance: *"Start conservative. Add senders after you see them repeatedly in triage reports."*
- **`triage-config.md`** is the "brain" of the triage system — maps Gmail label *names* to internal *IDs* (discoverable by calling `mcp__google_workspace__list_gmail_labels`) and defines classification rules. Includes newsletter platform domains (`substack.com, beehiiv.com, convertkit.com, mailchimp.com, buttondown.email`), expense vendor domains (`uber.com, lyft.com, amazon.com, paypal.com, square.com, stripe.com`), and a score-threshold table: newsletter platform → `@ToRead (immediate)`; receipt/notification from noreply → `Auto-Archive`; score 0 → SKIP. Tiebreaking priority: VIP → Expenses → @ToRead → @School → @Announcements → Auto-Archive.
- **`calendar-policy.md`** sets working hours (9:00 AM–5:30 PM Mon–Fri), buffers (15 min between meetings, 30 min before deep work), and a `push_level` enum (`gentle | moderate | assertive`) that controls how aggressively the assistant protects deep-work blocks. Includes reply-tone templates: Tier 2 colleague ("Hi [Name], I'm free at these times: …Let me know what works and I'll send a calendar invite") and Tier 1 formal ("Hi [Name], I'd be happy to meet. I have availability at the following times: …Please let me know which works best for you. Best, [Your name]").
- **`goals.yaml`** is weighted-OKR format with progress scores from 0.0 to 1.0. Schema includes `meta.quarter`, `meta.push_level`, `objectives[].weight` (summing to 1.0), `objectives[].status` (`active | paused | dormant`), `objectives[].key_results[].progress`, and `upcoming_deadlines`. Recommended: 3–5 objectives.

**A minimal working CLAUDE.md for an EA setup** (under ~80 lines, distilled from Blattman, Jeff Su, Sid Bharath):

```markdown
# CLAUDE.md — Personal EA Configuration

## Who I am
[Your name], [role] at [company]. Primary tools: Gmail, Google Calendar, Slack, Notion.

## Claude's role
Act as my executive assistant. Manage inbox triage, calendar, meeting prep, and follow-ups.
Be proactive: surface things I should know before I ask. Be concise. Use tables for structured info.

## Read these every session
- context/about-me.md (priorities, working style)
- context/voice-and-style.md (how I write)
- context/anti-ai-writing-style.md (what to never sound like)

## Confirmation guidelines
- ASK before: sending emails, deleting files, modifying shared docs, marking emails as read.
- DO NOT ask: applying Gmail labels, drafting replies (shown not sent), reading files,
  creating files in outputs/.
- After I approve a plan: execute without further prompts.

## File locations
- Working folder: ~/Claude-Workspace
- Outputs ALWAYS land in outputs/{daily,weekly,drafts}
- Policies in ~/.claude-assistant/config/

## Inline triggers (override defaults)
- Email send: use /send-email skill (Gmail MCP can only draft)
- Meeting transcripts: pull from Granola, save to projects/<name>/transcripts/
- Reminders: macOS Apple Reminders via osascript

## Communication style
- Lead with the recommendation, then the reasoning.
- Tables over paragraphs for anything comparing more than two things.
- Flag uncertainty explicitly: "I'm assuming X — confirm?"
- Never use em-dashes, "delve", "leverage", "robust", "synergy", or marketing-speak.
```

**Week 1 — install three skills, build the habit:**
1. `/done` (session capture) — runs at end of every session; appends decisions + open loops to MEMORY.md.
2. `/triage-inbox` — runs once per day for the first week; review every classification; tune `triage-config.md`.
3. `/checkin` — replaces the morning Slack-and-inbox-scroll. 10–15 min interactive session.

**Week 2 — add scheduling and meeting prep:**
4. `/schedule-query` — drafts scheduling replies with specific time proposals based on `calendar-policy.md`.
5. `/pre-meeting-brief` — surfaces decisions required + open loops + prep needs before external meetings.

**Week 3 — add briefings and goals:**
6. `/morning-brief` (scheduled 7:30am weekdays) — calendar + email highlights + goal alignment.
7. `/goals-review` (Friday afternoons) — quarterly objectives, progress scores, stalled-goal alerts.

**Week 4 — add automation and write-back:**
8. `/post-meeting` — extract decisions/actions from transcript, draft follow-up email. Has a "hollow transcript check" gate that hard-stops if Granola captured only AI notes but no verbatim transcript ("Drafting a follow-up email off bare AI notes produces confident-sounding summaries of things nobody said").
9. `/todo-queue` — batch-convert labeled emails to Apple Reminders.

**The Blattman config-file pattern is the load-bearing part.** Skills are stateless; configs hold state and policy. `email-policy.md` defines VIPs, auto-archive senders, and skip-inbox labels. `triage-config.md` holds Gmail label IDs and classification score thresholds. `calendar-policy.md` declares working hours, deep-work protection, and reply-tone templates. `goals.yaml` holds quarterly objectives with weighted progress scores. Every skill that touches email reads the first two; every calendar skill reads the third; `/checkin` and `/morning-brief` read all four. The architectural rule from Blattman's patterns page: *"Every non-trivial skill reads config/policy files before doing anything … Config is the source of truth; the skill body describes workflow, not data … No skill blocks if one source is unavailable."*

**Skill ↔ config dependency map:**

```
                              ┌────────────────────┐
                              │ CLAUDE.md (global) │  (always loads)
                              └────────────────────┘

Config templates (~/.claude-assistant/config/):
  email-policy.md ──────────┐
  triage-config.md ─────────┤── read by → /triage-inbox  (foundation)
                            │             /morning-brief
                            │             /checkin
  calendar-policy.md ───────┤── read by → /schedule-query
                            │             /morning-brief
                            │             /checkin
  goals.yaml ───────────────┴── read by → /goals-review (owner)
                                          /checkin (alignment + writing-hours)
                                          /morning-brief (alignment + research nudges)
```

**What progresses week-over-week.** Week 1 wins are immediate but shallow — inbox triage saves an hour. Week 4 compounding is structural: the system knows your VIPs, your meeting cadence, your goals, your voice. The bottleneck shifts from "Claude doesn't know me" to "I don't know what to delegate next". Practitioner consensus from Blattman, fourhourfreedom (Simon Theakston, working four-hour days after a stroke), Obie Fernandez (CTO of ZAR), and Mike Murchison (Claude Chief of Staff): the value isn't time saved on any one task. It's that nothing gets lost. The chaotic inbox stress disappears; meetings are prepped without thinking about it; commitments don't fall through.

**What disappoints in practice:**
- **Calendar scheduling across multiple participants** is still painful. Cowork can propose times; it cannot reliably do back-and-forth scheduling without a human assistant.
- **Voice tone takes weeks to dial in.** First drafts in your voice are usually 80% right, not 100%. Anti-AI-writing files help but aren't magic.
- **Email sending is intentionally restricted** to drafts in most setups. Practitioners agree: never let Claude send autonomously. The policy file should say so explicitly.
- **Granola/Fireflies hallucination** — `/post-meeting` only works on real transcripts. AI meeting notes alone produce confident-sounding hallucinations of things nobody said.
- **Usage limits.** A Pro user running daily briefings + 2–3 EA sessions will hit caps. Max ($100/mo) is effectively required for serious daily use.

### 8. Governance & Practical Policy

**Folder hygiene rules practitioners actually enforce:**
- Cowork only ever has access to the working folder and its subfolders — not your home directory, not `~/.ssh`, not credential stores. This is the primary security boundary, configured in Settings → Cowork → Folder Permissions.
- Output goes in `outputs/`. Inputs go in `inbox/`. Templates and identity files are read-only by convention (skill body declarations enforce this).
- A `what-changed.md` or `change-log.md` at the working-folder root logs every non-trivial action.

**Team distribution without leaking personal context.** The split is: company-wide skills/plugins go in the private GitHub marketplace; identity files (about-me, voice-profile) stay local to each user's working folder. Plugin files are sanitized — they reference "the user's voice profile at context/voice-and-style.md" rather than embedding content. Anthropic's enterprise "Customize" panel (released February 2026) lets admins distribute plugins per-role without seeing individual users' context files.

**Reviewing what scheduled tasks actually did.** The Scheduled sidebar in Cowork shows task history and execution logs. Common failures (per claudelab.net): app not open, cron syntax wrong, prompt unclear, file permissions missing, API tokens expired. Practitioners append a `/done`-style log to MEMORY.md from inside the scheduled task itself so there's a write-only audit trail even when no human is watching.

**The "graduated autonomy" pattern** (consensus best practice from Mike Murchison's Chief of Staff, Dex by Dave Killeen, LangChain's EAIA, and Blattman):
1. Start read-only — Claude proposes actions but does nothing.
2. Graduate to low-risk writes — apply labels, draft replies, create reminders. Still no sends, no deletes.
3. Only after weeks of trust: medium-risk writes — actual sends, calendar event creation. Still gated by per-item confirmation for anything VIP-tagged.

This is what Blattman calls the "propose → approve → execute" trust model. It emerged independently in nearly every serious EA implementation. Codify it in your email-policy.md before installing any skill.

---

## Recommendations

**If you're starting today, do exactly this:**

1. **Hour 1 — Foundation.** Install Claude Desktop, upgrade to Max ($100/mo) — Pro caps will frustrate you. Create the working folder skeleton above. Connect Gmail and Google Calendar via Settings → Cowork → Connectors. Write a 60-line CLAUDE.md (template above). Write a short `context/about-me.md` (use Hassid's 20-question interview prompt — keep the final file under 2,000 tokens).

2. **Hour 2 — Policy and triage.** Pull Blattman's four config templates into `~/.claude-assistant/config/`. Spend 30 minutes filling in VIPs, label IDs, working hours. Install `/triage-inbox` and `/done`. Run `/triage-inbox` once with planning mode on; verify it doesn't auto-archive anything important.

3. **Days 2–7 — Habit.** Run `/checkin` every morning. Give explicit feedback at end-of-session (`/done`). Tune `email-policy.md` based on what got mis-triaged. Don't add skills yet — get this loop solid first.

4. **Week 2 — Schedule.** Add `/morning-brief` as a scheduled task at 7:30am weekdays. Add `/schedule-query` and `/pre-meeting-brief` for meeting flow. Buy a cheap always-on Mac Mini if your laptop closes nightly.

5. **Week 3+ — Compound.** Add `/post-meeting`, `/goals-review`, `/weekly-review`. Move your config + skills into a private GitHub repo. If you have teammates who want the same setup, convert your skills into a plugin and host a private marketplace.

**Benchmarks that should change your plan:**
- If `/triage-inbox` mislabels a VIP email even once in week 1 → stop, tighten `email-policy.md`, do not add more skills.
- If you're hitting Pro usage caps before lunch → upgrade to Max immediately; the lost time isn't worth the saved $80.
- If scheduled tasks are firing inconsistently → check (a) machine sleep, (b) Cowork view focus on macOS, (c) consider moving the schedule to cron-on-server calling the API.
- If after 4 weeks the system isn't saving real time → the bottleneck is almost always either weak identity files (Claude doesn't know your voice/priorities) or missing connectors (Claude can't see the data). Iterate on those before adding more skills.

**Don't bother with (in early 2026):**
- Computer Use mode for daily EA work. Anthropic reports Sonnet 4.5+ scoring 72.5% on OSWorld-Verified for computer use; independent reviewer aitoolbriefing.com pegged real-world reliability for structured workflows at 65–75% in March 2026 — too brittle to base daily EA tasks on.
- Building plugins from scratch before you've used skills for a month. The plugin envelope adds work without value until you're sharing across machines or teammates.
- Trying to make Cowork do meeting scheduling end-to-end with external participants. Use it to propose times; let a human (or a dedicated AI scheduler like Cal.com/Reclaim/Motion) handle the back-and-forth.

---

## Caveats

**Vocabulary is unstable.** "Cowork", "CoWork", "co-work" all appear in practitioner posts. Anthropic's official name is "Cowork" (one word, capitalized). Some sources conflate "Cowork" with Claude Code or with the broader "agent" capability — read carefully.

**This space moves weekly.** Cowork launched January 12, 2026 in research preview (per VentureBeat: "Anthropic released Cowork on Monday, a new AI agent capability that extends the power of its wildly successful Claude Code tool to non-technical users"). The open-source plugin system and 11 official plugins shipped January 30, 2026 in the `anthropics/knowledge-work-plugins` repo. The "Customize" admin panel, private marketplaces, and 12 additional plugins landed February 24, 2026. Cowork Projects (persistent memory) launched March 20, 2026. Anything specific to "what's in the UI" may be out of date by the time you read this. The CLAUDE.md / SKILL.md file formats and the EA architecture pattern have been stable since February.

**Some sources are vendor-adjacent.** MindStudio, Composio, Fastio, ClaudePluginHub, FindSkill, agentskill.sh — useful sources but each has a commercial interest. Their pattern recommendations are sound; their tool recommendations should be taken with that lens.

**The "always-on machine" requirement is the biggest friction.** Anthropic has hinted at cloud-based scheduling but as of May 2026 has not shipped it. Plan around this constraint.

**Compliance gap.** Anthropic explicitly states Cowork activity is *not* captured in the Compliance API or Audit Logs (only OpenTelemetry on enterprise plans). This guide assumes individual or small-team use; regulated workloads need additional governance Cowork doesn't provide out-of-box.

**Models and pricing shift.** Sonnet 4.6 is the daily-driver for most EA work in May 2026; Opus 4.6 for complex strategy; Haiku for the briefing/triage scheduled tasks where speed matters more than depth. Most practitioner guides recommend Sonnet 80% of the time. This will change.