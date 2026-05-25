# daddia-assistant

A personal AI assistant built on Claude Cowork — pre-configured with skills, context, and sensible defaults so you can stop setting up and start getting things done.

---

## Get started

Paste this into Claude Code:

```
Set up my personal assistant workspace from this repo:
https://github.com/daddia/assistant

Clone it and tell me:
- What workspaces are available
- What skills I have and what they do
- How to point Cowork at my workspace

What can you help me with once I'm set up?
```

Claude Code will clone the repo, create your workspace, wire up the runtime folders, and walk you through everything.

Then open Cowork, point it at your workspace folder, and run:

```
/setup
```

That's it. `/setup` guides you through configuring the assistant in a conversation — no files to edit manually.

---

## What you get

| Skill | What it does |
|-------|-------------|
| `/setup` | First-time guided setup — configures everything through conversation |
| `/setup:about` | Update who you are and what you want help with |
| `/setup:voice` | Update your writing voice and style |
| `/setup:anti-style` | Define writing patterns to never use |
| `/setup:working-rules` | Update what the assistant can and can't do on your behalf |
| `/standup` | Start a session — surfaces open loops and today's focus |
| `/done` | End a session — saves decisions and open loops to memory |
| `/weekly-review` | Friday review — wins, misses, next week's priorities |
| `/todo-add` | Capture a task or reminder |
| `/todo-review` | Review and clear your open tasks |

Skills are Markdown files. You can read them, edit them, and add your own. No code required.

---

## How it works

**One repo. Multiple workspaces.**

Each workspace is a folder you point Cowork at. Workspaces have separate identity files, so each assistant knows its own context.

```
workspaces/
  my-assistant/    ← template workspace (copy this to get started)
  personal-assistant/ ← yours (stays on your machine, never committed)
```

**Context files.** Four files define who you are, how to write like you, and what the assistant can do on your behalf. `/setup` populates them through conversation.

**Memory persists.** `/done` appends session notes to `MEMORY.md`. `/standup` reads it at the next session. Nothing gets lost between conversations.

---

## Privacy

Your `workspaces/personal-assistant/` folder never gets committed — it's excluded by `.gitignore`. Only the `workspaces/my-assistant/` template ships with the repo. Your real context stays on your machine.

---

## Docs

[docs](./docs) · [MIT Licence](./LICENSE)
