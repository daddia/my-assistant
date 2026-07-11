# Get started

Install takes a couple of minutes.

## Step 1 — Install the plugin

### Claude Cowork or Claude Code

Customize → Plugins → **add a marketplace from a GitHub URL** and paste:

```
https://github.com/daddia/my-assistant
```

Then install **My Assistant** from that marketplace. It shows up in both chat and Cowork. (You can also upload the plugin as a zip, or add the repo as a local directory marketplace during development.)

**Naming:** display name **My Assistant** · repo/marketplace `my-assistant` · plugin id `assistant` · commands `/assistant:*` · default working folder `~/MyAssistant` (`config/profile.md` + `config/my-assistant.json`).

### Cursor

**Settings → Plugins → Add plugin:**

- **Paste this repo URL** — `https://github.com/daddia/my-assistant` — then install **My Assistant** from the marketplace list, or
- **Add a local marketplace** — point at a clone of this repo during development.

The `.cursor-plugin/` manifest wires up the same skills, commands, agents, hooks, rules, and MCP suggestions as the Claude build.

## Step 2 — Run setup

```
/assistant:setup
```

A short conversation captures your identity, writing voice, anti-AI style, working rules and autonomy tier, VIP tiers, and email/calendar policy.

**New:** Pick a **starter profile** (founder, consultant, sales lead, operator, investor) for a realistic persona in minutes, or choose the blank template for the full interview. See the [examples gallery](../examples/README.md).

Choose the 2-minute quick-start, a starter persona, or the full 10-minute interview.

Setup asks for a **working folder** (default `~/MyAssistant`), then writes:

```text
~/MyAssistant/config/profile.md          # your personalisation
~/MyAssistant/config/my-assistant.json   # paths, scope, platform
```

This lives *outside* the plugin, so updating the plugin never overwrites your data. Open `~/MyAssistant` in Cowork or Cursor so scheduled jobs and hooks resolve paths reliably.

## Step 3 — Try the wedge

```
/assistant:inbox triage  # triage + draft replies
/assistant:brief         # morning briefing
```

No connectors yet? Paste an email thread or your calendar — every skill works standalone. Try thread [`01-vip-board-update`](../../evals/corpus/threads/01-vip-board-update.md) and compare your draft to the [before/after gallery](../examples/before-after/01-vip-board-update/).

## Step 4 — Run status check

```
/assistant:status
```

A scannable status report checks your profile, working folder, scheduled jobs (if configured), connectors (advisory), and platform fit. Each row is **pass**, **warn**, **fail**, or **skip** with a concrete fix — usually `/assistant:setup`, `/assistant:schedules`, or a guide chapter.

Setup runs a short **Setup status** block automatically after writing your profile. Run the full status check anytime after plugin updates or when something feels off. Add `--save` to write `status-report-YYYY-MM-DD.md` to your working folder.

## Next

[Configure your profile →](02-configure-profile.md) · [Examples gallery →](../../examples/README.md) · [Connect your tools →](04-connect-tools.md)
