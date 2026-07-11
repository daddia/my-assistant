# Paths — working folder, config, profile, and policies

Every skill and command resolves the user's **working folder**, **config directory**, **profile**, and **policies** the same way. Setup writes once; nothing duplicates across legacy and workspace paths.

## Layout

After `/assistant:setup`, the user owns one directory (default `~/MyAssistant`):

```text
{assistantPath}/                 # working folder — TASKS, memory, drafts, schedules
  config/
    my-assistant.json            # machine-readable install config (selective fields)
    profile.md                   # identity, voice, anti-style, working rules, goals
  policies/
    email.policy.md              # VIP tiers, reply threshold, auto-archive, labels
    calendar.policy.md           # scheduling, buffers, focus-time defence
  TASKS.md
  CLAUDE.md
  memory/
  scheduled/
  review-queue/
  drafts/
```

Policy **templates** ship in the plugin's `policies/` directory (repo root). Setup copies and fills them into the user's `{assistantPath}/policies/`.

The plugin directory (`skills/`, `commands/`, …) is **read-only**. User data lives under `{assistantPath}` only.

## Machine config — `config/my-assistant.json`

Selective JSON for paths and non-prose settings. **Do not** duplicate profile or policy content (voice, VIP tiers, email/calendar rules, etc.) — those stay in `profile.md` and `{assistantPath}/policies/*.policy.md`.

| Field | Type | Purpose |
| ----- | ---- | ------- |
| `version` | string | Schema version (currently `"1"`) |
| `assistantPath` | string | Absolute path to the working folder |
| `configPath` | string | Absolute path to `{assistantPath}/config` |
| `scope` | `"personal"` \| `"work"` \| `"both"` | From setup interview working rules |
| `platform` | `"cowork"` \| `"cursor"` \| `"claude-code"` \| `"unknown"` | Host at setup time |
| `setupAt` | ISO-8601 datetime | When setup first created this file |
| `lastUpdated` | ISO-8601 datetime | When this file was last written |

Shape: `config/my-assistant.schema.yaml`.

## Resolution order

### 1. Find `my-assistant.json`

Check in order; stop at the first file that exists and parses:

1. `{open workspace}/config/my-assistant.json`
2. `~/MyAssistant/config/my-assistant.json` (default assistant path)
3. `~/.claude/plugins/config/my-assistant/my-assistant.json` (legacy — migration only)

When found, use `assistantPath` and `configPath` from the file. Profile path is `{configPath}/profile.md`. Policies directory is `{assistantPath}/policies/`.

### 2. Profile (when no JSON, or JSON missing `configPath`)

1. `{open workspace}/config/profile.md`
2. `{open workspace}/profile.md`
3. `~/MyAssistant/config/profile.md`
4. `~/.claude/plugins/config/my-assistant/profile.md` (legacy)

### 3. Policies

When `{assistantPath}/policies/` exists, read all `*.policy.md` files (at minimum `email.policy.md` and `calendar.policy.md`). Skills load policies alongside the profile.

**Legacy installs:** If policies live at `{configPath}/policies/` (older setup), still read them — but setup and health check will recommend moving to `{assistantPath}/policies/`.

If VIP tiers, email policy, or calendar policy still live inside `profile.md`, skills should still read them — but setup and health check will recommend splitting into `{assistantPath}/policies/`.

### 4. Working folder

1. `assistantPath` from `my-assistant.json` when present
2. Parent of resolved `config/profile.md` when profile is under a `config/` subdirectory
3. User-stated path in chat
4. Open workspace / current working directory (warn if ambiguous — health check `working-folder-identified`)

## Setup writes once

`/assistant:setup` (`skills/setup-interview/SKILL.md`):

1. Ask for **working folder** — suggest `~/MyAssistant`, accept an alternate path.
2. Create `{assistantPath}/policies/` if needed.
3. Write `{assistantPath}/config/profile.md` (from template or starter — identity, voice, rules, goals only).
4. Write `{assistantPath}/policies/email.policy.md` and `calendar.policy.md` from the plugin's master templates in `policies/`.
5. Write `{assistantPath}/config/my-assistant.json` with paths, `scope`, `platform`, `setupAt`, and `lastUpdated`.
6. Offer to scaffold `TASKS.md`, `memory/`, and `CLAUDE.md` in `{assistantPath}`.

**Do not** also write `~/.claude/plugins/config/my-assistant/profile.md` or a second workspace copy. One assistant path, one profile, one policies directory.

## SessionStart hook

`hooks/load-profile.sh` loads `{configPath}/profile.md` and all `{assistantPath}/policies/*.policy.md` using the resolution order above. Legacy `{configPath}/policies/` remains supported for existing installs.

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
