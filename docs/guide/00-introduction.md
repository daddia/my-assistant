# What is My Assistant?

**My Assistant** is a single plugin for [Claude Cowork](https://claude.com/product/cowork), Claude Code, and [Cursor](https://cursor.com) that acts as your AI chief of staff. It knows who you are, how you write, and what you want handled — so you stop repeating yourself every session.

## Who is it for?

Anyone drowning in inbox, calendar, and follow-ups who wants an executive assistant that prepares the work and leaves the decisions to them.

My Assistant:

- Triages your inbox into needs-reply / FYI / marketing / VIP
- Drafts replies in *your* voice, not generic AI-speak
- Tracks what you're waiting on and drafts the nudges
- Preps your meetings and turns your notes into follow-ups
- Runs a morning briefing and a weekly review
- Manages tasks and remembers your people, projects, and shorthand
- **Drafts everything — never sends, books, or spends without your say-so**

No coding required.

## How it works

1. **Install** the plugin (Cowork, Claude Code, or Cursor → Plugins → add this repo's marketplace).
2. **Setup** — run `/assistant:setup`. A short interview writes your profile.
3. **Use** — ask for help, or let skills fire as you work. Add scheduled tasks for hands-off mornings.

## The commands

### Workflow rituals

| Command | When to use it |
|---------|----------------|
| `/assistant:setup` | First run, or to update who you are and how you write |
| `/assistant:brief` | Morning briefing |
| `/assistant:update` | Bring the assistant up to date (default: tasks + memory + follow-ups; `tasks` · `memory` scopes; `--all` deep-scans connectors) |
| `/assistant:report` | Weekly report |
| `/assistant:schedules` | Set up recurring scheduled tasks |

### Domain commands (verb arguments)

| Command | When to use it |
|---------|----------------|
| `/assistant:inbox triage` | Triage mail and draft replies (default) |
| `/assistant:inbox sweep` | Lighter bucket-and-archive pass |
| `/assistant:email draft` | Draft one reply without full triage |
| `/assistant:email review` | Review what's awaiting a response |
| `/assistant:tasks` | Add, review, or sync tasks (`add` · `review` · `sync`) |
| `/assistant:meeting prep` | Prep for today's meetings |
| `/assistant:meeting follow-up` | Turn pasted notes into extraction, recap drafts, and queue items (default) |

## Next

[Get started →](01-getting-started.md)
