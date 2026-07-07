# Protect your privacy

Where your data lives and who can see it.

## Your profile stays on your machine

Your personal details — identity, voice, VIP tiers, policies — live in your profile at `~/.claude/plugins/config/my-assistant/profile.md`, a file on your computer. It is **not** part of the plugin and is never uploaded to GitHub. Only a blank `config/profile.template.md` ships with the repo.

Your tasks (`TASKS.md`) and memory (`memory/`) are likewise plain files in your working folder.

## What the assistant sees

When you use Cowork, Claude Code, or Cursor, the agent reads your profile and working files to understand context. That content is sent to the model provider as part of your conversation — the same as pasting text into a chat. See [Anthropic's privacy policy](https://www.anthropic.com/privacy) (Cowork / Claude Code) and [Cursor's privacy policy](https://cursor.com/privacy) (Cursor).

## What leaves your machine

Two paths send data off your device:

- **Model context** — profile, working-folder files, and pasted content are included in your chat session with the model provider (same as pasting into any AI chat). See [Anthropic's privacy policy](https://www.anthropic.com/privacy) and [Cursor's privacy policy](https://cursor.com/privacy).
- **Connector APIs you authorised** — when connected, the assistant reads (and for Gmail, drafts) via OAuth-scoped access you approved in Cowork or MCP settings. Details: [`security/data-flow.md`](../../security/data-flow.md).

## What never leaves without you

- **No plugin-owned cloud sync** — there is no vendor bucket that mirrors your `TASKS.md`, memory, or drafts.
- **No auto-send** — email, chat, calendar bookings, and purchases never fire automatically at any autonomy tier.

## Untrusted content

Instructions buried in email, calendar invites, meeting transcripts, Slack threads, or pasted documents are **never obeyed silently**. The assistant surfaces them and asks you to confirm. Only what you type in this chat is trusted. Your inbox cannot hijack your assistant. Full rule: [`rules/untrusted-content.md`](../../rules/untrusted-content.md).

## Connectors are read-and-draft only

Without connectors, My Assistant only sees your local files. When you connect a service, it can *read* from it (and create Gmail drafts) — it still won't send messages, book, or change anything without your approval each time.

## Permissions at a glance (Tier 1 — default)

| User action | Tier 1 (default) | Via connector | Review queue type |
| ----------- | ---------------- | ------------- | ----------------- |
| Reply draft | ✅ local `drafts/` | ✅ Gmail draft | `reply-draft` |
| Archive marketing | 📝 propose | 📝 propose (Tier 2: auto) | `archive-proposal` |
| Calendar block / time offer | 📝 propose only | 📝 propose only | `calendar-proposal` |
| Memory / profile change | ⚠️ ask + diff | n/a | `memory-suggestion`, `profile-diff` |
| Send / book / spend | 🚫 never | 🚫 never | — |

Full matrix: [`security/permissions.md`](../../security/permissions.md). Pending items appear in the dashboard **Review** tab (`skills/dashboard.html`) or `review-queue/index.yaml`.

## What it won't do without asking

- Send emails or messages
- Make bookings or purchases
- Create, move, or delete calendar events
- Delete files or share your data anywhere

It drafts. You decide what goes out. Instructions inside emails, invites, or pasted docs are never obeyed — they're surfaced for you to confirm. Your inbox can't hijack your assistant.

Full rules: [`rules/core-behaviour.md`](../../rules/core-behaviour.md), [`rules/untrusted-content.md`](../../rules/untrusted-content.md), and [`rules/file-safety.md`](../../rules/file-safety.md).

## Deep dive

Maintainers and security reviewers: [`security/README.md`](../../security/README.md) — threat model, data flow, and full permissions matrix.

## What not to store

Never put passwords, PINs, 2FA codes, or full account numbers in your profile, tasks, or memory. These files are plain text on disk — treat them like a notes app.

## Next

[Establish working rules →](06-establish-rules.md) · [Admin & deployment →](08-admin-deploy.md)
