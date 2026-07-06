# Connect email, calendar, and chat

My Assistant works without any connections — every skill runs on content you paste. Connect your tools and it works directly against your real inbox, calendar, and messages.

## How to connect

In Cowork: **Settings → Connectors**. Sign in to the services you use.

## What you can connect

| Tool | What My Assistant does with it |
|------|-------------------------------|
| **Gmail** (native, draft-only) | Read mail, triage, create reply drafts — never sends |
| **Google Calendar** (native) | See your schedule, prep meetings, propose times |
| **Google Drive** (native) | Read shared documents for meeting prep |
| **Slack** | Scan messages, post digests you've opted into |
| **Notion** | Notes and knowledge lookups |
| **Microsoft 365** | Email, calendar, OneDrive (alternative to Google) |
| **Jira / Linear / monday** | Task and work-item context |

Connect only what you use. The plugin refers to tools by category (`~~email`, `~~calendar`, `~~chat`, …) so any provider in that category works — see [`CONNECTORS.md`](../../CONNECTORS.md).

## Gmail is draft-only — by design

Claude's Gmail connector can read and draft but **cannot send**. That's exactly how My Assistant operates: it drafts, you send. The limitation and the design are the same thing.

## Using connectors

Once connected:

```
/my-assistant:inbox                 # triages your real inbox
/my-assistant:brief                 # pulls today's real calendar + unread
/my-assistant:update --comprehensive # scans email/calendar/chat for missed todos
```

It always asks before adding a task or a memory, and never sends or books automatically.

## Without connectors

Everything still runs — paste a thread, your agenda, or work from `TASKS.md` and memory alone. Skills skip any missing connector and note the gap rather than failing.

## Next

[Protect your privacy →](05-protect-privacy.md)
