# Set up your personal workspace

Your workspace is a folder on your computer. Everything my-assistant knows about you lives here — point Cowork at it and my-assistant reads it each session.

## Run setup

`/setup` is how my-assistant learns about you. It runs a conversation and saves your answers.

```
/setup
```

my-assistant goes through four sections, one at a time. After each section it saves the file and checks you're happy before continuing.

### What gets configured

| Section | What my-assistant asks about |
|---------|------------------------------|
| **About me** | Your name, household, what you want help with, what to avoid |
| **Voice and style** | How you write — tone, length, sign-offs, Australian vs American English |
| **Anti-AI writing** | Phrases and patterns to never use ("Great question!", "delve", corporate-speak) |
| **Working rules** | What my-assistant can do on your behalf — draft vs send, money, privacy |

You don't need to prepare anything. Answer in your own words. Skip anything you're not sure about — you can always update later.

### Update one section later

Changed jobs, new partner, different writing preferences? Update just the part that changed:

| Command | Updates |
|---------|---------|
| `/setup:about` | About me |
| `/setup:voice` | Voice and style |
| `/setup:anti-style` | Anti-AI writing patterns |
| `/setup:working-rules` | Working rules |

### Tips

- **Be specific about voice.** "Direct and warm, no fluff" works better than "professional."
- **The anti-AI section matters.** It's the most effective way to stop my-assistant sounding like a chatbot.
- **Working rules are your guardrails.** If you never want it booking things without asking, say so here.

## What's in your workspace

**Context** — who you are and how you operate. Created by `/setup`.

- About me — household, priorities, preferences
- Voice and style — how my-assistant writes
- Anti-AI writing — what to never say
- Working rules — what it can and can't do for you

**Memory** — people, places, and projects my-assistant remembers.

- Short notes it always knows (family members, key places)
- Deeper files it loads when relevant (extended profiles, recurring commitments)
- Session notes so nothing gets lost between conversations

**Tasks** — your to-do list in plain markdown. Add tasks naturally ("remind me to call the plumber") or run `/update` to review what's open.

**Output** — where my-assistant writes drafts, summaries, and plans. Your context and memory files stay separate — my-assistant doesn't overwrite them without asking.

**Inbox** — drop files here for my-assistant to read and process.

## Day to day

**Starting a session** — just ask. my-assistant reads your context and memory automatically.

**Adding a task** — say it naturally: "I need to renew the car rego in June." my-assistant adds it to your list.

**Reviewing tasks** — run `/update` to triage overdue items and catch gaps in memory.

**Ending a session** — my-assistant saves anything worth remembering. Pick up where you left off next time.

## More than one assistant

You can have separate workspaces for different parts of your life — personal, work, a specific project. Each has its own context and memory. Nothing mixes unless you copy files between them.

Ask Claude Code: "Copy my-assistant to a new workspace called work-assistant."

## Next

[Add skills to my-assistant →](03-add-skills.md) · [Connect email, calendar, and chat →](04-connect-tools.md)
