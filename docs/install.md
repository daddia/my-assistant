# Install reference

Technical reference for `install.sh` and manual setup steps.

For the non-technical quick start (curl), see [README.md](../README.md).

---

## What install.sh does

1. **Symlinks shared skills** — `shared/skills/<category>/<name>/` → `workspaces/<name>/.claude/skills/<name>/`
2. **Creates runtime directories** — `output/daily`, `output/weekly`, `output/drafts`, `inbox/`, `projects/`
3. **Touches MEMORY.md** — so skills don't error on first read
4. **Copies config templates** — `config/*.example.*` → `~/.claude-assistant/config/` (only if not already present)

## Usage

```bash
# Install all workspaces
./install.sh

# Install one workspace
./install.sh workspaces/personal-assistant

# Install multiple
./install.sh workspaces/personal-assistant workspaces/work
```

## Manual equivalent

```bash
WS=workspaces/personal-assistant

# Create runtime dirs
mkdir -p "$WS/output/daily" "$WS/output/weekly" "$WS/output/drafts" "$WS/inbox" "$WS/projects"
touch "$WS/MEMORY.md"

# Symlink shared skills
mkdir -p "$WS/.claude/skills"
for skill in shared/skills/*/*/; do
  name=$(basename "$skill")
  ln -sf "$(pwd)/$skill" "$WS/.claude/skills/$name"
done

# Copy config templates (edit locally, never commit the real files)
mkdir -p ~/.claude-assistant/config
cp config/*.example.* ~/.claude-assistant/config/
# rename each: remove the .example from the filename, then fill in your values
```

## Re-running

Safe to re-run. Symlinks and directories already present are skipped. Config templates already at `~/.claude-assistant/config/` are not overwritten.

## Adding a new workspace

1. Create the folder: `cp -R workspaces/my-assistant workspaces/work`
2. Edit `workspaces/work/context/` files
3. Run `./install.sh workspaces/work`
4. Point Cowork at `workspaces/work/`

New workspaces are gitignored automatically (only `workspaces/my-assistant/` is tracked).

## Adding a new shared skill

1. Create `shared/skills/<category>/<skill-name>/SKILL.md`
2. Re-run `./install.sh` — it will symlink the new skill into all workspaces

See [spec.md](product/spec.md#skillmd-format) for the SKILL.md format.
