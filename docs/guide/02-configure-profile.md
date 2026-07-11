# Configure your profile

Your **profile** is the single file that makes My Assistant sound like you and respect your rules. It's created by `/assistant:setup` and read at the start of every session.

## Working folder and config

Setup creates a user-owned folder (default `~/MyAssistant`):

```text
~/MyAssistant/
  config/
    profile.md              # human personalisation
    my-assistant.json       # paths, scope, platform (selective)
  TASKS.md
  memory/
  schedules/
  ...
```

Outside the plugin directory — so `/plugin update` overwrites plugin files but never your personalisation. Open this folder in Cowork or Cursor so hooks and scheduled jobs find your files. Path resolution: `rules/paths.md`.

## Run setup

```
/assistant:setup
```

Pick the 2-minute quick-start, a **starter profile**, or the full 10-minute interview.

### Starter profiles

Five vertical ICP personas ship in `config/starter-profiles/` — fictional identities only, same eight sections as the template:

| Starter | Best for |
|---------|----------|
| Founder | Early-stage CEO / co-founder |
| Consultant | Independent advisor |
| Sales lead | Account executive |
| Operator | Chief of staff / ops lead |
| Investor | Angel / micro-VC |

During `/assistant:setup`, choose a starter for a quick customize (name, company, timezone) or keep as-is for demo. The assistant writes to `{assistantPath}/config/` — same as a hand-built profile.

Browse [before/after draft demos](../../examples/before-after/) to see generic AI output vs profile-tuned replies. **Evals** still use Alex Rivera ([`evals/profile.fixture.md`](../../evals/profile.fixture.md)); starters are for onboarding.

It walks eight sections, one at a time, confirming each before writing (blank path).

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
- **Paste real emails** into `{assistantPath}/voice/` so drafts match your rhythm.
- **Autonomy defaults to Tier 1 (Draft).** Raise it only after a week of good output.

## Update later

Re-run `/assistant:setup` to adjust any section, or just correct the assistant mid-work — when a durable convention emerges (a new VIP, a tone tweak), it proposes a profile change and shows you the diff before writing.

## Next

[Examples gallery →](../../examples/README.md) · [Skills and commands →](03-skills-and-commands.md) · [Connect your tools →](04-connect-tools.md)
