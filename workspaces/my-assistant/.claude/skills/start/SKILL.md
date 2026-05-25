---
name: start
description: Initialise tasks and memory for my-assistant. Use on first run, when
  bootstrapping memory from an existing task list, or when setting up a new workspace.
---

# Start

> If you see unfamiliar placeholders or need to check which tools are connected, see [CONNECTORS.md](../../CONNECTORS.md).

Initialise the task and memory systems for my-assistant.

## Instructions

### 1. Check what exists

Check the working directory for:
- `TASKS.md` — task list
- `CLAUDE.md` — working memory
- `memory/` — deep memory directory
- `context/` — identity files (about-me, voice, rules)

### 2. Create what's missing

**If `TASKS.md` doesn't exist:** Create it with the standard template (see task-management skill).

**If `memory/` doesn't exist:** Create it with empty category files (people, places, projects, recurring, references).

**If context files are still templates:** Suggest running `/setup` first.

### 3. Bootstrap memory (first run only)

Only if context files are configured but memory is sparse.

Ask the user:
```
Let's seed my-assistant's memory. Tell me:
1. Who's in your household? (names and relationships)
2. What are your top 3 priorities right now?
3. Any recurring commitments I should know? (school runs, bin night, etc.)
```

Write answers to `CLAUDE.md` (working memory) and appropriate `memory/` files.

### 4. Seed tasks (optional)

Ask: "Do you have an existing task list anywhere — a notes app, email, or file? I can pull tasks from there."

If the user has connected `~~email` or `~~calendar`, offer to scan for obvious action items.

### 5. Report results

```
my-assistant is ready:
- Context: [configured / needs /setup]
- Tasks: TASKS.md (X items)
- Memory: X people, X places, X projects

Use /update to keep things current.
```

## Notes

- If memory is already initialised, confirm status and suggest `/update`
- Don't store credentials or financial account details in memory
- If a connector isn't available, skip it and note the gap
