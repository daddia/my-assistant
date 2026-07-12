# Paths — working folder, config, profile, and policies

Every skill and command resolves the user's **working folder**, **config directory**, **profile**, and **policies** the same way. Setup writes once; nothing duplicates across legacy and workspace paths.

## Layout

After `/assistant:setup`, the user owns one directory (default `~/MyAssistant`):

```text
{assistantPath}/                 # working folder — tasks, memory, drafts, schedules
  AGENTS.md                      # memory hot cache (People, Terms, Projects, Preferences)
  CLAUDE.md                      # @AGENTS.md — Claude Code / Cowork compat shim
  dashboard.html                 # visual task + memory editor (copied from plugin at setup)
  config/
    my-assistant.json            # machine-readable install config (selective fields)
    profile.md                   # identity, voice, anti-style, working rules, goals
  policies/
    email.policy.md              # VIP tiers, reply threshold, auto-archive, labels
    calendar.policy.md           # scheduling, buffers, focus-time defence
  TASKS.md
  memory/
    glossary.md                  # full decoder ring
    people/                      # individual profiles
    projects/                    # project detail
    context/                     # personal.md or company.md
  scheduled/
  review-queue/
  drafts/
```

Policy **templates** ship in the plugin's `policies/` directory (repo root). Setup copies and fills them into the user's `{assistantPath}/policies/`.

**Directory scaffold:** `skills/assistant-setup/SKILL.md` creates the full tree on initial setup (inline or via `skills/assistant-setup/scripts/scaffold-working-folder.sh --full --plugin-root {pluginRoot}`). The script does not write profile, policies, populated `AGENTS.md`, or `my-assistant.json`.

The plugin directory (`skills/`, `commands/`, …) is **read-only**. User data lives under `{assistantPath}` only.

## Machine config — `config/my-assistant.json`

Selective JSON for paths and non-prose settings. **Do not** duplicate profile or policy content (voice, VIP tiers, email/calendar rules, etc.) — those stay in `profile.md` and `{assistantPath}/policies/*.policy.md`.

| Field | Type | Purpose |
| ----- | ---- | ------- |
| `version` | string | Schema version (currently `"1"`) |
| `assistantPath` | string | Absolute path to the working folder |
| `configPath` | string | Absolute path to `{assistantPath}/config` |
| `policiesPath` | string | Absolute path to `{assistantPath}/policies` |
| `scope` | `"personal"` \| `"work"` \| `"both"` | From `/assistant:setup` working rules |
| `platform` | `"cowork"` \| `"cursor"` \| `"claude-code"` \| `"unknown"` | Host at setup time |
| `setupAt` | ISO-8601 datetime | When setup first created this file |
| `lastUpdated` | ISO-8601 datetime | When this file was last written |

Shape: `config/my-assistant.schema.yaml`.

## Resolution order

### 1. Find `my-assistant.json`

1. `{open workspace}/config/my-assistant.json`
2. `~/MyAssistant/config/my-assistant.json` (default assistant path)
3. `~/.claude/plugins/config/my-assistant/my-assistant.json` (legacy — migration only)

When found, use `assistantPath`, `configPath`, and `policiesPath` from the file. Profile path is `{configPath}/profile.md`. Policies directory is `{policiesPath}/` (default `{assistantPath}/policies/`).

### 2. Profile (when no JSON, or JSON missing `configPath`)

1. `{open workspace}/config/profile.md`
2. `{open workspace}/profile.md`
3. `~/MyAssistant/config/profile.md`
4. `~/.claude/plugins/config/my-assistant/profile.md` (legacy)

### 3. Policies

When `{policiesPath}/` exists (or `{assistantPath}/policies/` when `policiesPath` is absent from older installs), read all `*.policy.md` files (at minimum `email.policy.md` and `calendar.policy.md`). Skills load policies alongside the profile.

**Legacy installs:** If policies live at `{configPath}/policies/` (older setup), still read them — but setup and health check will recommend moving to `{assistantPath}/policies/`.

If VIP tiers, email policy, or calendar policy still live inside `profile.md`, skills should still read them — but setup and health check will recommend splitting into `{assistantPath}/policies/`.

### 4. Working folder

1. `assistantPath` from `my-assistant.json` when present
2. Parent of resolved `config/profile.md` when profile is under a `config/` subdirectory
3. User-stated path in chat
4. Open workspace / current working directory (warn if ambiguous — health check `working-folder-identified`)

### 5. Memory hot cache

1. `{assistantPath}/AGENTS.md` — primary hot cache for decoding shorthand
2. `{assistantPath}/CLAUDE.md` — if it contains only `@AGENTS.md`, resolve to `AGENTS.md`; if it holds legacy hot-cache content, read it but offer migration to `AGENTS.md`

## Setup writes once

`/assistant:setup` (`skills/assistant-setup/SKILL.md`):

1. Ask for **working folder** — suggest `~/MyAssistant`, accept an alternate path.
2. Create the **full working-folder tree** — memory subdirs, templates, `AGENTS.md`, `CLAUDE.md` shim, `TASKS.md`, `dashboard.html`.
3. Write `{assistantPath}/config/profile.md` (from template or starter — identity, voice, rules, goals only).
4. Write `{assistantPath}/policies/email.policy.md` and `calendar.policy.md` from the plugin's master templates in `policies/`.
5. Write `{assistantPath}/config/my-assistant.json` with `assistantPath`, `configPath`, `policiesPath`, `scope`, `platform`, `setupAt`, and `lastUpdated`.
6. **Bootstrap memory** — seed `AGENTS.md` and `memory/people/` from profile key people and VIPs; optional task decode pass.

**Do not** also write `~/.claude/plugins/config/my-assistant/profile.md` or a second workspace copy. One assistant path, one profile, one policies directory.

## SessionStart hook

`hooks/load-profile.sh` loads `{configPath}/profile.md` and all `{policiesPath}/*.policy.md` (from `my-assistant.json` when present) using the resolution order above. Legacy `{configPath}/policies/` remains supported for existing installs.

## Migration

If a profile exists only at `~/.claude/plugins/config/my-assistant/profile.md`:

- Health check may **warn** on `config-exists` / suggest re-running setup or moving files into `{assistantPath}/config/`.
- Do not auto-migrate without user confirmation.

If policies exist at `{configPath}/policies/` instead of `{assistantPath}/policies/`:

- Offer a one-time **move** to `{assistantPath}/policies/` (show diff if files differ).
- Do not auto-migrate without user confirmation.

If policy sections (VIP tiers, email policy, calendar policy) still live inside `profile.md`:

- Offer a one-time **split**: extract sections into `{assistantPath}/policies/email.policy.md` and `calendar.policy.md`, then trim the profile.
- Show the diff before writing.

If `CLAUDE.md` holds hot-cache content instead of `@AGENTS.md`:

- Offer a one-time **migrate**: move tables into `AGENTS.md`, replace `CLAUDE.md` with the shim.
- Show the diff before writing.
