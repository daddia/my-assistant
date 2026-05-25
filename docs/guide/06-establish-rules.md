# Establish working rules

How my-assistant keeps you in control.

## Draft, don't send

By default, my-assistant can:

- Research and summarise
- Plan and draft
- Remind you and track tasks
- Write files to your output folder

It needs your explicit approval to:

- Send emails or messages
- Make bookings
- Spend money
- Change your calendar
- Delete files

This is set in your working rules during `/setup`. You can tighten or loosen them anytime with `/setup:working-rules`.

## What not to store

Don't put these in your workspace files:

- Passwords or PINs
- Bank account numbers
- API keys or recovery codes

Your workspace files are plain text on disk — not encrypted. Treat them like a notes app.

## Separate work and personal

Keep work and home in different workspaces. The default template is scoped to personal life. If you ask something work-related, my-assistant flags it and checks before proceeding.

## Connected services

When you connect Gmail, Slack, or other tools in Cowork, you sign in through Anthropic's connector system. Check what permissions you're granting in Cowork settings before connecting.

Connecting a service lets my-assistant *read* during sync — it does not let it send or write on your behalf without approval per action.

## If something feels wrong

Update your working rules:

```
/setup:working-rules
```

Tell my-assistant what it should never do without asking. It follows those rules every session.
