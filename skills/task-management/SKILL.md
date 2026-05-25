---
name: task-management
description: Maintain a markdown task list (TASKS.md). Activate when the user mentions
  something they need to do, asks what's on their list, wants to add a task, asks
  to review tasks, or says "make a note to..." or "don't let me forget...". Adapted
  from the Anthropic knowledge-work productivity plugin.
---

# Task management

Markdown-based task tracking. One file, always current, readable as plain text.

## The file: `TASKS.md`

Located at the workspace root. Format:

```markdown
# Tasks

## This week

- [ ] Call plumber about kitchen tap — by Thursday
- [ ] Reply to school newsletter — no deadline
- [x] Book dentist for Sarah ✓ 22 May

## Upcoming

- [ ] Renew car rego — due June
- [ ] Research holiday accommodation — July

## Waiting / blocked

- [ ] Insurance claim — waiting on document from provider (since 10 May)

## Someday / maybe

- [ ] Fix the back fence
- [ ] Set up Notion for meal planning
```

## Adding tasks

Add naturally — don't require a specific format. Parse what the user says:

| User says | Claude writes |
|-----------|---------------|
| "I need to call the plumber this week" | `- [ ] Call plumber — this week` |
| "Remind me about the school newsletter" | `- [ ] Reply to school newsletter` |
| "I need to renew the car rego in June" | `- [ ] Renew car rego — due June` |

When the user describes multiple tasks in one message, add them all.

## Completing tasks

When the user says a task is done, mark it `[x]` with the date. Keep completed tasks for one week, then archive to `tasks/archive/YYYY-MM.md`.

## `/update` — weekly review

When the user asks to review tasks or runs `/update`:
1. List everything overdue and ask what happened to each
2. Move items that slipped to next week or a new date
3. Ask: "Anything new this week?" and add responses
4. Identify anything that's been stuck in Waiting for more than 2 weeks and flag it

## When tasks come from conversation

If the user's message implies a task but they haven't explicitly asked you to add it, note it:

"By the way — it sounds like you need to follow up on the insurance. Want me to add it to your task list?"

## What to avoid

- Don't add tasks without telling the user
- Don't add vague tasks ("think about holiday") — ask for enough detail to act
- Don't auto-complete tasks — wait for the user to confirm
- Don't let TASKS.md exceed 40 active tasks — suggest a review if it does
