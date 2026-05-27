# Connect email, calendar, and chat

my-assistant works without any connections — everything runs from files on your computer. Connect email, calendar, or chat if you want it to scan for tasks and reminders you've missed.

## How to connect

In Cowork: **Settings → Connectors**. Choose the services you use and sign in.

## What you can connect

| Tool | What my-assistant can do with it |
|------|----------------------------------|
| **Gmail** | Spot action items in recent email |
| **Google Calendar** | See what's coming up, flag prep needed |
| **Google Drive** | Read shared documents |
| **Slack** | Scan messages for commitments you made |
| **Microsoft 365** | Email, calendar, and OneDrive (alternative to Google) |

You don't need all of these. Connect what you actually use.

## Using connectors

Once connected, run:

```
/update --comprehensive
```

my-assistant scans your recent activity and suggests tasks or memories you might have missed — "You said you'd call the plumber in an email Tuesday — want me to add that?"

It always asks before adding anything. Nothing is sent or changed automatically.

## Without connectors

Run `/productivity:update` without the flag. my-assistant reviews your local task list and memory only. Still useful — just no email or calendar scan.

## Next

[Protect your privacy →](05-protect-privacy.md)
