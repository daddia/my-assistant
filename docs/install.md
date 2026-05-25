# Install reference

Technical reference for setting up my-assistant.

For the quick start, see [README.md](../README.md).

---

## Agentic install

Install is handled entirely by Claude Code — no shell scripts. Paste the install prompt from the README, or read and follow `skills/assistant/skills/install/SKILL.md`.

The install skill:
1. Clones the repo
2. Copies `workspaces/my-assistant/` to your personal workspace
3. Creates runtime directories (`output/`, `inbox/`, `projects/`, `memory/`)
4. Copies plugin skills into `.claude/skills/`

## Plugin structure

Skills are organised as local plugins (following [Anthropic's plugin format](https://github.com/anthropics/knowledge-work-plugins/tree/main/productivity)):

```
skills/
  assistant/          ← install, setup, memory
    .claude-plugin/
    README.md
    skills/
  productivity/       ← start, update, task-management
    .claude-plugin/
    .mcp.json
    CONNECTORS.md
    README.md
    skills/
```

## Manual equivalent

```bash
git clone https://github.com/daddia/assistant ~/assistant
cp -R ~/assistant/workspaces/my-assistant ~/assistant/workspaces/personal-assistant

WS=~/assistant/workspaces/personal-assistant
mkdir -p "$WS/output/daily" "$WS/output/weekly" "$WS/output/drafts"
mkdir -p "$WS/inbox" "$WS/projects" "$WS/memory"
touch "$WS/MEMORY.md" "$WS/TASKS.md"

# Copy plugin skills
mkdir -p "$WS/.claude/skills"
cp -R ~/assistant/skills/assistant/skills/* "$WS/.claude/skills/"
cp -R ~/assistant/skills/productivity/skills/* "$WS/.claude/skills/"
```

Then point Cowork at the workspace and run `/setup`.

## Adding a new workspace

1. Copy the template: `cp -R workspaces/my-assistant workspaces/work`
2. Run `/setup` in Cowork to configure context
3. Point Cowork at the new workspace folder

New workspaces are gitignored automatically (only `workspaces/my-assistant/` is tracked).

## Adding a new skill

1. Create `skills/<plugin>/skills/<skill-name>/SKILL.md`
2. Copy into workspace: `cp -R skills/<plugin>/skills/<skill-name> workspaces/<name>/.claude/skills/`
3. Document in the plugin's `README.md`

See [skills/assistant/README.md](../skills/assistant/README.md) for the SKILL.md format.

## Connectors

The productivity plugin includes a `.mcp.json` with pre-configured MCP servers. Connect tools in Cowork → Settings → Connectors. See [skills/productivity/CONNECTORS.md](../skills/productivity/CONNECTORS.md).
