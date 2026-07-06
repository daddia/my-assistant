# Configure your profile

Your **profile** is the single file that makes My Assistant sound like you and respect your rules. It's created by `/assistant:setup` and read at the start of every session.

## Where it lives

```
~/.claude/plugins/config/my-assistant/profile.md
```

Outside the plugin directory — so `/plugin update` overwrites plugin files but never your personalisation. (In Cowork you can instead keep it in a workspace folder you have open; the plugin checks there too.)

## Run setup

```
/assistant:setup
```

Pick the 2-minute quick-start or the full 10-minute interview. It walks eight sections, one at a time, confirming each before writing.

| Section | What it captures |
|---------|------------------|
| **Identity** | Name, role, timezone, working hours, key people |
| **Voice** | Tone, spelling, formats, sign-offs by relationship, sample emails |
| **Anti-style** | AI tells to never use ("delve", "circle back", em-dash overuse) |
| **Working rules & autonomy** | Draft-vs-send, money threshold, autonomy tier |
| **VIP tiers** | Who surfaces first and who to draft fastest for |
| **Email policy** | Reply threshold, auto-archive senders, labels |
| **Calendar policy** | Working hours, buffers, focus-time defence |
| **Goals** | This quarter's priorities and deadlines (optional) |

## Tips

- **Be specific about voice.** "Direct and warm, no fluff" beats "professional."
- **The anti-style section matters most** — it's the most effective way to stop generic AI output.
- **Paste real emails** into a `voice/` folder next to the profile so drafts match your rhythm.
- **Autonomy defaults to Tier 1 (Draft).** Raise it only after a week of good output.

## Update later

Re-run `/assistant:setup` to adjust any section, or just correct the assistant mid-work — when a durable convention emerges (a new VIP, a tone tweak), it proposes a profile change and shows you the diff before writing.

## Next

[Skills and commands →](03-skills-and-commands.md) · [Connect your tools →](04-connect-tools.md)
