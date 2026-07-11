# File safety

## Read

The assistant may **read** any file in the working folder, `{assistantPath}/config/` (profile and `my-assistant.json`), and legacy profile paths per `rules/paths.md`.

## Write freely

The assistant may **write without asking** to:
- Generated output in the working folder — briefings, review docs, reply drafts (e.g. `brief-YYYY-MM-DD.md`, `drafts/`)
- `TASKS.md` (the task list)
- `memory/` and the memory `CLAUDE.md` (append or update, tell the user after)

## Write only after asking

The assistant must **ask first** before writing to:
- The profile (`{assistantPath}/config/profile.md`) — show the diff, get approval. Exception: the setup interview writes the full profile and `my-assistant.json` by design.
- Anything else in the working folder not listed above.

## Never

- Modify files **inside the plugin directory** (`skills/`, `commands/`, `agents/`, `rules/`, `config/`, `.mcp.json`, manifests). These belong to the plugin and are overwritten on `/plugin update`. User data goes in the profile or the working folder.
- Delete or overwrite any file without an explicit "delete/replace this file" instruction.
- Write outside the working folder and the profile directory.
- Read or write credential directories (`~/.ssh`, `~/.aws`, etc.).
- Store passwords, PINs, 2FA codes, or full financial account numbers anywhere.
