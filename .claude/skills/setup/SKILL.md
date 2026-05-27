---
name: setup
description: Guide the user through configuring my-assistant. Activate when the user
  says "/setup", "set up my assistant", "configure my workspace", or "help me get
  started". Also handles sub-commands /setup:about, /setup:voice, /setup:anti-style,
  /setup:working-rules.
---

# Setup

Walks the user through configuring my-assistant through conversation — no manual file editing required.

> Sub-command details: see [skills/assistant/README.md](../../../skills/assistant/README.md)

## Sub-commands

| Command | File | What it configures |
|---------|------|--------------------|
| `/setup` | all four | Full guided setup, one section at a time |
| `/setup:about` | `context/about-me.md` | Identity, family, priorities, what to help with |
| `/setup:voice` | `context/voice-and-style.md` | Writing voice, tone, structure, sign-offs |
| `/setup:anti-style` | `context/anti-ai-writing-style.md` | Patterns to never use, AI tells to avoid |
| `/setup:working-rules` | `context/working-rules.md` | Scope, privacy, acting on behalf, output rules |

## Routing

- `/setup` → run all four sections in order
- `/setup:about` → run Section 1 only, then stop
- `/setup:voice` → run Section 2 only, then stop
- `/setup:anti-style` → run Section 3 only, then stop
- `/setup:working-rules` → run Section 4 only, then stop

After each section, write the file and confirm what was saved before continuing.

---

## Section 1 — About me (`/setup:about`)

Read `commands/about.md` and follow it.

## Section 2 — Voice and style (`/setup:voice`)

Read `commands/voice.md` and follow it.

## Section 3 — Anti-AI writing style (`/setup:anti-style`)

Read `commands/anti-style.md` and follow it.

## Section 4 — Working rules (`/setup:working-rules`)

Read `commands/working-rules.md` and follow it.

---

## On completion

Summarise what's configured and suggest `/productivity:start` to initialise tasks and memory.
