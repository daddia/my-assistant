# Add skills to my-assistant

Skills teach my-assistant how to do specific things — weekly reviews, meal planning, trip research, whatever you need.

Built-in skills cover install, setup, tasks, and memory via repo skills (`.claude/skills/`) and plugins (`/assistant:*`, `/productivity:*`). You can add your own.

## What is a skill?

A skill is a short instruction file that tells my-assistant when and how to handle a type of request. When you ask something that matches, my-assistant follows those instructions.

You don't need to understand the file format to use skills. To **add** one, describe what you want and ask Claude Code or Cowork to create it for you.

## Add a skill by describing it

Tell my-assistant or Claude Code what you want:

```
Add a weekly-review skill. Every Friday I want to review what I completed,
what slipped, and set priorities for next week. Save the summary to my
output folder.
```

It creates the skill file and installs it in your workspace.

## Add a skill yourself

If you want to write one directly, create a folder in your workspace for a **workspace-only override**:

```
workspaces/<name>/.claude/skills/weekly-review/SKILL.md
```

Or add a skill to a plugin under `skills/<plugin>/skills/` and enable it via the **adk** marketplace.

A skill file has two parts:

**At the top** — a name and when to use it:

```yaml
---
name: weekly-review
description: Friday review of wins, misses, and next week's priorities.
---
```

**Below** — step-by-step instructions:

```markdown
# Weekly review

1. Read my task list
2. Ask what went well and what slipped
3. Write a summary to output/weekly/
4. Update my priorities for next week
```

Save the file. Next time you say "weekly review" or run `/weekly-review`, my-assistant follows those steps.

## Ideas for personal skills

- **Meal planning** — weekly menu and shopping list based on what's in the pantry
- **School admin** — term dates, permission slips, pickup arrangements
- **Travel planning** — itinerary drafts, packing lists, booking reminders
- **Gift tracker** — birthdays, ideas, what you've bought

## Changing a skill

Skills are plain text. Open the file, edit the instructions, save. Changes apply on the next session.

## Next

[Connect email, calendar, and chat →](04-connect-tools.md)
