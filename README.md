# my-assistant

A personal AI assistant built on Claude Cowork — pre-configured with skills, context, and sensible defaults so you can stop setting up and start getting things done.

---

## Getting started with my-assistant

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

That's it. `/setup` guides you through configuring my-assistant in a conversation — no files to edit manually.

---

## Setting up my-assistant

| Command | What it does |
|---------|-------------|
| `/setup` | First-time guided setup — configures everything through conversation |

Sub-commands like `/setup:about` and `/setup:voice` are available for updating individual context files. See [skills/assistant/README.md](skills/assistant/README.md) for details.

Skills are Markdown files in `skills/`. You can read them, edit them, and add your own. No code required.

---

## How my-assistant works

**One repo. One workspace.**

Point Cowork at `workspaces/my-assistant/` (or your personal copy). The workspace contains everything my-assistant needs — context files, skills, and output folders.

```
workspaces/
  my-assistant/    ← template workspace (copy this to get started)
  personal-assistant/ ← yours (stays on your machine, never committed)
```

**Context files.** Four files define who you are, how to write like you, and what my-assistant can do on your behalf. `/setup` populates them through conversation.

**Plugins.** Skills are organised as local plugins — no blackbox installs:

| Plugin | Commands | Purpose |
|--------|----------|---------|
| [assistant](skills/assistant/) | `/setup` | Install, configure, remember context |
| [productivity](skills/productivity/) | `/start`, `/update` | Tasks, memory sync, daily updates |

**Memory persists.** my-assistant writes session notes to `MEMORY.md` and maintains a `memory/` directory for people, places, and projects. Nothing gets lost between conversations.

---

## Privacy

**Your data stays on your machine.**

- Context files (`context/about-me.md`, etc.) contain your personal details — they live in your workspace folder and are never uploaded anywhere except to Claude during your sessions.
- `workspaces/personal-assistant/` is excluded from git by default. Your real context never gets committed to the repo.
- Only the template workspace (`workspaces/my-assistant/`) ships with the repo — it contains placeholder content, not real personal data.
- my-assistant drafts messages and documents for you. It does not send emails, make bookings, or spend money without your explicit approval for each action.

**What Claude sees.** When you use Cowork, Claude reads your workspace files to understand context. This is the same as any Claude conversation — your files are sent to Anthropic's API. Review [Anthropic's privacy policy](https://www.anthropic.com/privacy) for how they handle data.

**Connectors are optional.** Email, calendar, and chat integrations require you to connect tools in Cowork settings. Without connectors, my-assistant works entirely from local files.

---

## Security

**Acting on your behalf.**

my-assistant follows a draft-don't-send rule by default:
- It can research, plan, draft, summarise, and remind.
- It needs your explicit approval to send messages, make bookings, purchases, or calendar changes.

**What not to store.**

Do not put passwords, PINs, financial account numbers, or API keys in context or memory files. These files are plain markdown on disk.

**Workspace isolation.**

Keep work and personal life in separate workspaces. The template workspace is scoped to personal life only — if a request looks work-shaped, my-assistant flags it and asks before proceeding.

**Local copies of skills.**

All skills are local markdown files in this repo. There are no remote plugin installs, no auto-updates from third parties, and no opaque skill bundles. You can read and edit every file.

---

## Docs

[skills/assistant/](skills/assistant/) · [skills/productivity/](skills/productivity/) · [docs/](docs/) · [MIT Licence](LICENSE)
