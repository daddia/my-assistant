# Paths — working folder, config, and profile

Every skill and command resolves the user's **working folder**, **config directory**, and **profile** the same way. Setup writes once; nothing duplicates across legacy and workspace paths.

## Layout

After `/assistant:setup`, the user owns one directory (default `~/MyAssistant`):

```text
{assistantPath}/                 # working folder — TASKS, memory, drafts, schedules
  config/
    my-assistant.json            # machine-readable install config (selective fields)
    profile.md                   # human-readable personalisation (voice, VIP, policy)
  TASKS.md
  CLAUDE.md
  memory/
  scheduled/
  review-queue/
  drafts/
```

The plugin directory (`skills/`, `commands/`, …) is **read-only**. User data lives under `{assistantPath}` only.

## Machine config — `config/my-assistant.json`

Selective JSON for paths and non-prose settings. **Do not** duplicate profile content (voice, VIP tiers, email policy, etc.) — those stay in `profile.md`.

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

When found, use `assistantPath` and `configPath` from the file. Profile path is `{configPath}/profile.md`.

### 2. Profile (when no JSON, or JSON missing `configPath`)

1. `{open workspace}/config/profile.md`
2. `{open workspace}/profile.md`
3. `~/MyAssistant/config/profile.md`
4. `~/.claude/plugins/config/my-assistant/profile.md` (legacy)

### 3. Working folder

1. `assistantPath` from `my-assistant.json` when present
2. Parent of resolved `config/profile.md` when profile is under a `config/` subdirectory
3. User-stated path in chat
4. Open workspace / current working directory (warn if ambiguous — health check `working-folder-identified`)

## Setup writes once

`/assistant:setup` (`skills/setup-interview/SKILL.md`):

1. Ask for **working folder** — suggest `~/MyAssistant`, accept an alternate path.
2. Create `{assistantPath}/config/` if needed.
3. Write `{assistantPath}/config/profile.md` (from template or starter).
4. Write `{assistantPath}/config/my-assistant.json` with paths, `scope`, `platform`, `setupAt`, and `lastUpdated`.
5. Offer to scaffold `TASKS.md`, `memory/`, and `CLAUDE.md` in `{assistantPath}`.

**Do not** also write `~/.claude/plugins/config/my-assistant/profile.md` or a second workspace copy. One assistant path, one profile.

## SessionStart hook

`hooks/load-profile.sh` loads `{configPath}/profile.md` using the resolution order above. Legacy paths remain supported for existing installs.

## Migration

If a profile exists only at `~/.claude/plugins/config/my-assistant/profile.md`:

- Health check may **warn** on `config-exists` / suggest re-running setup or moving files into `{assistantPath}/config/`.
- Do not auto-migrate without user confirmation.
