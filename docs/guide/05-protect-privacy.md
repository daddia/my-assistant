# Protect your privacy

Where your data lives and who can see it.

## Your profile stays on your machine

Your personal details — identity, voice, VIP tiers, policies — live in your profile at `~/.claude/plugins/config/my-assistant/profile.md`, a file on your computer. It is **not** part of the plugin and is never uploaded to GitHub. Only a blank `config/profile.template.md` ships with the repo.

Your tasks (`TASKS.md`) and memory (`memory/`) are likewise plain files in your working folder.

## What the assistant sees

When you use Cowork, Claude Code, or Cursor, the agent reads your profile and working files to understand context. That content is sent to the model provider as part of your conversation — the same as pasting text into a chat. See [Anthropic's privacy policy](https://www.anthropic.com/privacy) (Cowork / Claude Code) and [Cursor's privacy policy](https://cursor.com/privacy) (Cursor).

## Connectors are read-and-draft only

Without connectors, My Assistant only sees your local files. When you connect a service, it can *read* from it (and create Gmail drafts) — it still won't send messages, book, or change anything without your approval each time.

## What it won't do without asking

- Send emails or messages
- Make bookings or purchases
- Create, move, or delete calendar events
- Delete files or share your data anywhere

It drafts. You decide what goes out. Full rules: [`rules/core-behaviour.md`](../../rules/core-behaviour.md) and [`rules/file-safety.md`](../../rules/file-safety.md).

## What not to store

Never put passwords, PINs, 2FA codes, or full account numbers in your profile, tasks, or memory. These files are plain text on disk — treat them like a notes app.

## Next

[Establish working rules →](06-establish-rules.md)
