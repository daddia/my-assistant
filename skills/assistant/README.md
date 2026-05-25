# Assistant Plugin

Core plugin for **my-assistant** — install, configure, and remember context for your personal Claude Cowork workspace.

Adapted from patterns in [Anthropic's productivity plugin](https://github.com/anthropics/knowledge-work-plugins/tree/main/productivity) and [Tribe AI's brand voice plugin](https://github.com/TribeAI/claude-cowork-brand-voice-plugin).

## What it does

- **Install** — clone the repo, create your workspace, wire up skills (100% agentic, no shell scripts)
- **Setup** — guided conversation to populate your context files
- **Memory** — two-tier memory so my-assistant remembers people, places, and projects

## Commands

| Command | What it does |
|---------|--------------|
| `/setup` | First-time guided setup — configures all context files through conversation |

### Setup sub-commands

Run individually to update one file:

| Command | File |
|---------|------|
| `/setup:about` | `context/about-me.md` |
| `/setup:voice` | `context/voice-and-style.md` |
| `/setup:anti-style` | `context/anti-ai-writing-style.md` |
| `/setup:working-rules` | `context/working-rules.md` |

## Skills

| Skill | Description |
|-------|-------------|
| `install` | Agentic workspace setup — activated by the README install prompt |
| `setup` | Guided context configuration with sub-commands |
| `memory` | Two-tier memory — `CLAUDE.md` for working memory, `memory/` for deep storage |

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
        Setup complete. Run /start to initialise tasks and memory.
```
