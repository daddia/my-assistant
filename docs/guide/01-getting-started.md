# Get started

Install takes a couple of minutes.

## Step 1 — Install the plugin

In **Cowork** or **Claude Code**: Customize → Plugins → **add a marketplace from a GitHub URL** and paste:

```
https://github.com/daddia/my-assistant
```

Then install **my-assistant** from that marketplace. It shows up in both chat and Cowork. (You can also upload the plugin as a zip, or add the repo as a local directory marketplace during development.)

## Step 2 — Run setup

```
/my-assistant:setup
```

A short conversation captures your identity, writing voice, anti-AI style, working rules and autonomy tier, VIP tiers, and email/calendar policy. Choose the 2-minute quick-start or the full 10-minute interview.

Your answers are written to a **profile** at:

```
~/.claude/plugins/config/my-assistant/profile.md
```

This lives *outside* the plugin, so updating the plugin never overwrites your personalisation.

## Step 3 — Try the wedge

```
/my-assistant:inbox      # triage + draft replies
/my-assistant:brief      # morning briefing
```

No connectors yet? Paste an email thread or your calendar — every skill works standalone.

## Next

[Configure your profile →](02-setup-workspace.md) · [Connect your tools →](04-connect-tools.md)
