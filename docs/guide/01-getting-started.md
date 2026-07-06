# Get started

Install takes a couple of minutes.

## Step 1 — Install the plugin

### Claude Cowork or Claude Code

Customize → Plugins → **add a marketplace from a GitHub URL** and paste:

```
https://github.com/daddia/my-assistant
```

Then install **assistant** from that marketplace. It shows up in both chat and Cowork. (You can also upload the plugin as a zip, or add the repo as a local directory marketplace during development.)

### Cursor

**Settings → Plugins → Add plugin:**

- **Paste this repo URL** — `https://github.com/daddia/my-assistant` — then install **My Assistant** from the marketplace list, or
- **Add a local marketplace** — point at a clone of this repo during development.

The `.cursor-plugin/` manifest wires up the same skills, commands, agents, hooks, rules, and MCP suggestions as the Claude build.

## Step 2 — Run setup

```
/assistant:setup
```

A short conversation captures your identity, writing voice, anti-AI style, working rules and autonomy tier, VIP tiers, and email/calendar policy. Choose the 2-minute quick-start or the full 10-minute interview.

Your answers are written to a **profile** at:

```
~/.claude/plugins/config/my-assistant/profile.md
```

This lives *outside* the plugin, so updating the plugin never overwrites your personalisation. (In Cowork you can instead keep the profile in a workspace folder you have open; the plugin checks there too.)

## Step 3 — Try the wedge

```
/assistant:inbox triage  # triage + draft replies
/assistant:brief         # morning briefing
```

No connectors yet? Paste an email thread or your calendar — every skill works standalone.

## Next

[Configure your profile →](02-configure-profile.md) · [Connect your tools →](04-connect-tools.md)
