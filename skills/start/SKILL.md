---
name: start
description: Initialize tasks and memory and open the dashboard — a light first-run
  wedge without the full profile interview. Use when setting up for the first time,
  bootstrapping working memory from an existing task list, or decoding shorthand in todos.
---

# Start command

> If you see unfamiliar placeholders or need to check which tools are connected, see [CONNECTORS.md](../../CONNECTORS.md).

Initialize the task and memory systems, then open the unified dashboard. This is the **fast path** — for identity, voice, VIP tiers, and email/calendar policies, run `/assistant:setup` afterward.

## Instructions

### 1. Check what exists

Resolve the working folder per `rules/paths.md` (default `~/MyAssistant`). Check for:

- `TASKS.md` — task list
- `AGENTS.md` — working memory hot cache
- `CLAUDE.md` — compat shim (`@AGENTS.md`)
- `memory/` — deep memory directory
- `dashboard.html` — visual UI

### 2. Create what's missing

**If `TASKS.md` doesn't exist:** create it from `skills/assistant-setup/assets/TASKS.template.md` (sections: To do, In progress, In review, Done, Cancelled, Blocked).

**If `dashboard.html` doesn't exist:** copy from `${CLAUDE_PLUGIN_ROOT}/skills/dashboard.html` to the working folder.

**If `AGENTS.md`, `CLAUDE.md`, and `memory/` don't exist:** scaffold from setup assets (`AGENTS.template.md`, `CLAUDE.template.md`, `glossary.template.md`, `memory/people/`, `memory/projects/`, `memory/context/`). Then continue to memory bootstrap (step 5).

**Do not** write `config/profile.md` or policies in this command — offer `/assistant:setup` when the user wants inbox/calendar sharpness.

### 3. Open the dashboard

Do **not** use `open` or `xdg-open` — in Cowork, the agent runs in a VM and shell open commands won't reach the user's browser. Tell the user:

> Dashboard is ready at `{assistantPath}/dashboard.html`. Open it from your file browser (Chrome or Edge) and select this folder.

### 4. Orient the user

If everything was already initialized:

```
Dashboard ready. Tasks and memory are loaded.
- /assistant:update — sync tasks, memory gaps, and follow-ups
- /assistant:update --all — deep scan of connected email, calendar, chat, and tasks
- /assistant:setup — full profile, voice, and policies (recommended when you connect mail)
```

If memory hasn't been bootstrapped yet, continue to step 5.

### 5. Bootstrap memory (first run only)

Only when `AGENTS.md` and `memory/` are empty or freshly scaffolded.

The best source of workplace language is the user's **actual task list**. Real tasks = real shorthand.

**Ask the user:**

```
Where do you keep your todos? This could be:
- A local file (e.g. TASKS.md, todo.txt)
- An app (Asana, Linear, Jira, Notion, Todoist, GitHub Issues)
- A notes file or paste

I'll use your tasks to learn your workplace shorthand.
```

**Once you have the task list:**

For each task item, analyze shorthand — names, acronyms, project codenames, internal terms. Decode interactively using the checklist in `skills/memory-management/SKILL.md` (✓ / ? markers). Ask only about terms not already in memory.

### 6. Optional comprehensive scan

After task decoding, offer:

```
Want a deeper scan of chat, email, and docs for people and projects?
Run /assistant:update --all when connectors are ready — or skip for now.
```

If they choose to scan now and connectors are available, follow the comprehensive templates in `commands/update.md` (`--all` section). Group memory proposals by confidence (see `memory-management` skill).

### 7. Write memory files

From everything gathered, populate:

- **`AGENTS.md`** — People, Terms, Projects, Preferences tables (~50–80 lines). Link to `config/profile.md` when a profile exists.
- **`memory/glossary.md`** — full decoder ring
- **`memory/people/{slug}.md`**, **`memory/projects/{slug}.md`**, **`memory/context/`** as needed

Present memory proposals grouped by confidence:

- **Ready to add** (high confidence) — offer to add directly
- **Needs clarification** — ask the user
- **Low frequency / unclear** — note for later

### 8. Report results

```
Start complete:
- Tasks: TASKS.md ({N} items)
- Memory: {N} people, {N} terms, {N} projects
- Dashboard: open in browser

Next: /assistant:update to stay current · /assistant:setup for profile and voice
```

## Notes

- If memory is already populated, this command scaffolds missing files and points at the dashboard.
- Nicknames are critical — always capture how people are actually referred to.
- If a source isn't available, skip it and note the gap.
- Memory grows organically through conversation after bootstrap.
