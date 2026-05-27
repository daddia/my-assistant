# Assistant Plugin

Memory plugin for **my-assistant** — two-tier memory so your assistant remembers people, places, and projects.

Install and setup are **repo-level skills** at `.claude/skills/` (not part of this plugin). See the [assistant README at repo root](../../README.md) and `docs/guide/`.

Adapted from patterns in [Anthropic's productivity plugin](https://github.com/anthropics/knowledge-work-plugins/tree/main/productivity) and [Tribe AI's brand voice plugin](https://github.com/TribeAI/claude-cowork-brand-voice-plugin).

## What it does

- **Memory** — two-tier memory: `MEMORY.md` for working memory, `memory/` for deep storage

## Commands

| Command | What it does |
|---------|--------------|
| `/assistant:memory` | Load and apply memory management instructions |

Setup (configuring `context/` files) uses the repo skill `/setup` — see `.claude/skills/setup/SKILL.md`.

### Setup sub-commands (repo skill `/setup`)

| Command | File |
|---------|------|
| `/setup:about` | `context/about-me.md` |
| `/setup:voice` | `context/voice-and-style.md` |
| `/setup:anti-style` | `context/anti-ai-writing-style.md` |
| `/setup:working-rules` | `context/working-rules.md` |

## Skills

| Skill | Description |
|-------|-------------|
| `memory` | Two-tier memory — `MEMORY.md` for working memory, `memory/` for deep storage |

## Context files

Setup populates four files that define who you are and how my-assistant operates:

```
context/
  about-me.md              — identity, household, priorities
  voice-and-style.md       — how to write to you and as you
  anti-ai-writing-style.md — patterns to never use
  working-rules.md         — scope, privacy, acting on your behalf
```

## Example workflow

```
You: /setup

Claude: Let's configure my-assistant. First — what's your name,
        and what do you like to be called?

You: Jonathan, call me Jon.

Claude: [continues through all four sections, writing each file]
        Setup complete. Run /productivity:start to initialise tasks and memory.
```
