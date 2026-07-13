---
name: assistant-setup
description: Onboarding for the assistant plugin. Activate when the user says
  "/assistant:setup", "set me up", "configure my assistant", "help me get started",
  or when no profile exists per rules/paths.md.
  Writes profile, policies, memory (AGENTS.md hot cache + memory/ tree), and install config.
user-invocable: false
---

# Setup

A 10-minute conversation that produces **profile**, **policies**, and **memory** — what makes every other skill sound like the user and decode their shorthand. Skipping this is the number-one cause of generic output, so lead with it.

Invoked via `/assistant:setup` — the user-facing entry point is the command, not this skill file.

## Path resolution

Follow `rules/paths.md` for all reads and writes. **Write once** — never duplicate the profile across legacy and workspace paths.

## Step 0 — Working folder (before profile content)

Before identity, voice, or starters, establish where the assistant lives:

1. **Suggest the default:** `~/MyAssistant` (expand to the user's home directory in paths you write).
2. **Ask:** "Use `~/MyAssistant`, or a different folder?"
3. **Confirm the absolute path** — create the directory tree (see **Working-folder deliverables** below). Idempotent — safe if the folder already exists.
4. Record `assistantPath`, `configPath` (`{assistantPath}/config`), and `policiesPath` (`{assistantPath}/policies`) for all writes in this session.

All user-owned files go under `{assistantPath}`:

| Path | Purpose |
| ---- | ------- |
| `{assistantPath}/config/profile.md` | Identity, voice, anti-style, working rules, goals |
| `{assistantPath}/policies/*.policy.md` | VIP tiers, email rules, calendar rules, action extraction rules |
| `{assistantPath}/config/my-assistant.json` | Machine-readable install config (selective) |
| `{assistantPath}/AGENTS.md` | Memory hot cache — People, Terms, Projects, Preferences (~50–80 lines) |
| `{assistantPath}/CLAUDE.md` | Compatibility shim: `@AGENTS.md` (Claude Code / Cowork auto-load) |
| `{assistantPath}/memory/` | Deep memory — `glossary.md`, `people/`, `projects/`, `context/` |
| `{assistantPath}/TASKS.md`, `drafts/`, `scheduled/`, `review-queue/` | Tasks, output, schedules, approvals |
| `{assistantPath}/dashboard.html` | Visual task + memory editor (copied from plugin) |

**Do not** also write `~/.claude/plugins/config/my-assistant/profile.md` or a loose `profile.md` at the workspace root unless the user explicitly asks to migrate an existing legacy copy (then move, don't duplicate).

## Where files go

- **Profile:** `{assistantPath}/config/profile.md` — base on `config/profile.template.md` (sections 1–5 only; no VIP, email, or calendar content).
- **Policies:** `{assistantPath}/policies/` — one file per domain, named `<name>.policy.md`. Base on the plugin's master templates in `policies/` (repo root): `email.policy.md`, `calendar.policy.md`, `actions.policy.md`. **Do not** create per-starter or per-persona policy copies in the plugin — there is only one master template set.

> This is the only skill that writes the full profile and policies without a diff prompt. Every other skill proposes changes and asks first.

## Install config — `my-assistant.json`

After writing the profile and policies, write `{assistantPath}/config/my-assistant.json` per `config/my-assistant.schema.yaml`.

**Include (selective, machine-readable only):**

- `version`: `"1"`
- `assistantPath`, `configPath`, `policiesPath` — absolute paths
- `scope`: `"personal"`, `"work"`, or `"both"` (from working rules)
- `platform`: best-effort `cowork`, `cursor`, `claude-code`, or `unknown`
- `setupAt`: ISO-8601 timestamp — set on **first** write; preserve on later updates
- `lastUpdated`: ISO-8601 timestamp — set on every write (initial setup and profile/config updates)

**Do not include** voice, VIP tiers, email/calendar policy, autonomy prose, or goals — those belong in `profile.md` and `{assistantPath}/policies/*.policy.md` only.

## Three paths — offer when no profile exists

When **no profile exists** (per `rules/paths.md`, or the user asks to "start from template"), read `config/starter-profiles/manifest.yaml` and present:

| Option | What happens |
|--------|----------------|
| **Starter persona** (five choices) | Copy a vertical ICP profile (identity + voice only), optional quick customize, fill policies from master templates |
| **Blank template (full interview)** | Full interview below — profile + policies + memory |
| **Quick-start (2 min)** | Identity + voice one-liner + autonomy tier; policy templates with placeholders |

### Starter selection table

Present all five starters with ICP one-liner from the manifest:

| ID | Title | ICP |
|----|-------|-----|
| `founder` | Founder | Early-stage CEO or co-founder |
| `consultant` | Consultant | Independent advisor |
| `sales-lead` | Sales lead | Account executive |
| `operator` | Operator | Chief of staff / ops lead |
| `investor` | Investor | Angel / micro-VC |

### Starter flow

1. User picks a starter id (or blank / quick-start).
2. **Unknown id** — list valid ids from manifest; offer blank interview. Do not write a partial profile.
3. **Missing starter file** — say "Starter unavailable — use blank template" and link to the repo issue tracker. Do not write an empty profile.
4. Read `config/starter-profiles/{id}.md` for profile sections only.
5. Offer **Quick customize** (name, company, timezone) OR **Keep as-is for demo**.
6. **Do not write** until the user confirms customize-or-keep (match interview pacing — no half-written profiles if they abort).
7. Write `{assistantPath}/config/profile.md`, `{assistantPath}/policies/email.policy.md`, `{assistantPath}/policies/calendar.policy.md`, `{assistantPath}/policies/actions.policy.md`, and `my-assistant.json`.
8. Run **Working-folder deliverables** and **Memory bootstrap** (below).
9. For starter demo mode, pre-fill policies with sensible defaults for that persona during customize — still using the master `policies/` templates as the base shape.
10. Summarize: `Profile: {Title} starter (customized|as-is) · Assistant folder: {assistantPath} · Memory: X people seeded`.
11. Point to `examples/README.md` and `examples/workflows/setup-with-starter.md`; suggest thread `01-vip-board-update` for a first paste demo.

If user picks **blank** or **quick-start**, continue with the paths below.

## Two paths — when blank or profile exists

- **Quick-start (2 min):** identity + voice one-liner + autonomy tier. Policy files get template placeholders — enough to be useful today.
- **Full interview (10 min):** all sections below. Recommend this when not using a starter.

Ask which they'd like (when not using a starter), then proceed.

## The interview — profile and policies

Ask conversationally, one section at a time. Confirm and write after each. Don't dump all questions at once.

**Profile (`profile.md`):**

1. **Identity** — name, preferred name, role/company (skip for purely personal use), location, timezone, working hours, **key people** (partner, kids, co-founder, EA, top clients). For each key person, ask **what you call them** in messages (nicknames matter for decoding).
2. **Voice** — one-line description of their writing voice; locale/spelling; date/number formats; how they structure messages; default length; sign-offs by relationship (client vs colleague vs friend); openers. Then **show a two-sentence sample in that voice and ask if it sounds right.** Adjust until it does. Invite them to paste 2–3 real sent emails into `{assistantPath}/voice/` (or `{configPath}/voice/`).
3. **Anti-style** — show the banned-tells list (openers, AI words, corporate-speak, em-dash/hedging/rule-of-three patterns). Ask which bother them most and what to add. Collect one "sounds like me" and one "sounds like AI" example.
4. **Working rules & autonomy** — pick an autonomy tier (default **Tier 1 — Draft**; explain the four tiers from `rules/core-behaviour.md`); scope (personal only? work + personal? → maps to `scope` in `my-assistant.json`); money threshold; anything off-limits.
5. **Goals** (optional) — this quarter's top objectives and deadlines to watch.

**Policies (`policies/`):**

6. **VIP tiers** → `email.policy.md` — who must surface first and never be auto-touched (Tier 1); who to draft fastest for (Tier 2).
7. **Email policy** → `email.policy.md` — reply threshold (which categories to draft for vs summarise vs archive); exact-sender auto-archive list (start conservative); labels they use.
8. **Calendar policy** → `calendar.policy.md` — working hours; meeting-length defaults and buffers; focus-time defence level; **0–3 habit blocks** (day, start time, duration, title — e.g. Mon–Fri 08:00 "Morning review"); what may be auto-proposed vs must-always-ask.
9. **Actions policy** → `actions.policy.md` — optional at setup; copy the template. Non-reply actions (calendar holds, tasks, forms) are added as the user confirms rules during triage.

## Writing the files

Fill the profile template (sections 1–5) and policy templates from their answers. Leave clear placeholders for anything skipped. Keep profile + policies under ~2,000 words combined.

Then write or update `{assistantPath}/config/my-assistant.json` with `assistantPath`, `configPath`, `policiesPath`, `scope`, `platform`, `setupAt`, and `lastUpdated`. On updates to an existing install, preserve `setupAt`, refresh `lastUpdated`, and add `policiesPath` if missing from older installs.

**Always** run **Working-folder deliverables** and **Memory bootstrap** after the initial profile write (starter, quick-start, or full interview). On profile **updates** only, offer to refresh memory seed from changed key people — don't overwrite populated tables without confirmation.

## Working-folder deliverables

Create the full working folder on every **initial** setup. Prefer the scaffold script when available; otherwise create the same tree inline.

**Option A — scaffold script (maintainers / when shell is available):**

```bash
skills/assistant-setup/scripts/scaffold-working-folder.sh {assistantPath} --full --plugin-root {pluginRoot}
```

`{pluginRoot}` is the plugin install directory (contains `skills/dashboard.html`). In Cowork/Cursor, resolve from the plugin path or `${CLAUDE_PLUGIN_ROOT}` when set.

**Option B — inline (always valid):**

1. Create directories: `config/`, `policies/`, `memory/people/`, `memory/projects/`, `memory/context/`, `drafts/`, `scheduled/`, `review-queue/`.
2. Copy templates from `skills/assistant-setup/assets/` when files are missing:
   - `TASKS.template.md` → `TASKS.md`
   - `glossary.template.md` → `memory/glossary.md`
   - `context-personal.template.md` → `memory/context/personal.md` when `scope` is `personal` or `both`; else `context-company.template.md` → `memory/context/company.md`
   - `AGENTS.template.md` → `AGENTS.md` (then populate in bootstrap — don't leave placeholders)
   - `CLAUDE.template.md` → `CLAUDE.md`
3. Copy `skills/dashboard.html` → `{assistantPath}/dashboard.html` when missing. **Do not** use `open` or `xdg-open` — tell the user to open `dashboard.html` from their file browser (Chrome or Edge).

Never skip `TASKS.md`, `memory/glossary.md`, `AGENTS.md`, `CLAUDE.md`, or `dashboard.html` on initial setup.

## Memory bootstrap (first-class deliverable)

After profile and policies are written, **populate memory** — don't leave empty placeholders.

### 1. Seed from profile key people

For each person in profile §1 **Key people**:

1. Add a row to **`AGENTS.md` → People** table: `| **{nickname}** | {full name}, {relationship} |`
2. Add a row to **`memory/glossary.md` → Nicknames → full names**
3. Create **`memory/people/{slug}.md`** from `assets/people.template.md` (slug: lowercase, hyphens — e.g. `amelia-daddia.md`)

Use the nickname the user actually uses ("Millie", not only "Amelia").

### 2. Seed VIPs from email policy

For each VIP in `policies/email.policy.md`, ensure they appear in **People** (and glossary nicknames if applicable). Merge with key people — no duplicate rows.

### 3. Fill AGENTS.md header sections

- **Me** — preferred name + one-line role/scope from profile §1 and §4. Link to `config/profile.md`.
- **Preferences** — 2–3 bullets from voice/working rules (e.g. Australian English, sign-off style). **Do not** paste full anti-style or autonomy prose — link to profile and policies.
- Leave **Terms** and **Projects** tables empty with header rows unless bootstrap finds entries.

### 4. Optional — decode from tasks (productivity-style)

Ask:

> "Where do you keep todos? Paste a list, point at `TASKS.md`, or skip — I'll decode shorthand from whatever you share."

For each task line, decode unknown people, projects, acronyms interactively using the ✓ / ? checklist in `skills/memory-management/SKILL.md`. Group proposals by confidence tier. Add confirmed entries to `AGENTS.md`, `memory/glossary.md`, and `memory/people/` or `memory/projects/` as appropriate.

### 5. Optional — comprehensive scan

After task decode (or if skipped), offer:

> "Want a deeper scan of chat, email, or docs for people and projects? Run `/assistant:update --all` when connectors are ready — or skip for now."

Do not block setup on connectors. Use confidence-tiered memory proposals from `memory-management` when scanning.

### 6. Report memory deliverables

```
Memory ready:
- Hot cache: AGENTS.md ({N} people, {N} terms, {N} projects)
- Deep memory: memory/glossary.md, memory/people/ ({N} files)
- Compat: CLAUDE.md → @AGENTS.md
- Dashboard: dashboard.html (open in Chrome/Edge, select this folder)
```

## Migrating legacy monolithic profiles

If `profile.md` still contains VIP tiers, email policy, or calendar policy sections:

1. Offer a one-time **split** — extract into `{assistantPath}/policies/email.policy.md` and `calendar.policy.md`.
2. Trim those sections from `profile.md`.
3. Show the diff before writing.

If an older install has **`CLAUDE.md` as the hot cache** (not a shim):

1. Offer a one-time **migrate** — move hot-cache content into `AGENTS.md`, replace `CLAUDE.md` with `@AGENTS.md`.
2. Show the diff before writing.

## Post-setup status check

After the **initial** profile write (starter, quick-start, or full interview — not when updating an existing profile), run the status check **subset**:

1. Read and follow `commands/health.md` with `checks: [profile, policies, working-folder]` only.
2. Render a compact **Setup status** block (≤8 lines): summary counts (`pass` / `warn` / `fail` / `skip`) plus the top fails or warns with `fix_ref` links.
3. Do **not** block the wedge on warnings — always continue to the handoff below.
4. Chat-only — do not auto-save `status-report-*.md` after setup.

Then summarise what's captured and point them at the wedge:

> "You're set up at `{assistantPath}`. Open that folder in Cowork or Cursor. Open `dashboard.html` in Chrome or Edge for tasks and memory. Try `/assistant:inbox triage` to sort your mail, or `/assistant:brief` for a morning briefing. Run `/assistant:health` anytime for a full install check. New here? `/assistant:start` is the fast tasks-only path. Browse [`examples/README.md`](../../examples/README.md) for persona demos. Re-run `/assistant:setup` anytime to adjust."

## Notes

- Never store passwords, PINs, 2FA codes, or full account numbers.
- If a profile already exists, don't overwrite blindly — ask whether to update specific sections and show the diff.
- If a legacy profile exists at `~/.claude/plugins/config/my-assistant/profile.md` but not under `{assistantPath}/config/`, offer a one-time **move** (not copy) after confirming the working folder.
- Everything works standalone; connectors just make it sharper. Don't block setup on OAuth.
- The working-folder **`AGENTS.md`** is user data — not the plugin repo's orchestration `AGENTS.md`.

## Approval frame

Follow [`rules/approval-frame.md`](../../rules/approval-frame.md) when proposing post-setup profile or policy changes.

**Queue writing:**

- The **initial full profile, policy, and memory write** during setup is **exempt** from `profile-diff` / `memory-suggestion` queue items — the user is actively answering interview questions.
- **Post-setup change proposals** use queue types `profile-diff` and `memory-suggestion` via the standard diff flow.

Use the four-part frame when showing profile, policy, or memory diffs after setup.
