# Configure your profile and policies

Your **profile** and **policies** make My Assistant sound like you and respect your rules. They're created by `/assistant:setup` and read at the start of every session.

## Working folder and config

Setup creates a user-owned folder (default `~/MyAssistant`):

```text
~/MyAssistant/
  config/
    profile.md              # identity, voice, working rules, goals
    my-assistant.json       # paths, scope, platform (selective)
  policies/
    email.policy.md         # VIP tiers, reply threshold, auto-archive, labels
    calendar.policy.md      # scheduling, buffers, focus-time defence
  TASKS.md
  memory/
  scheduled/
  ...
```

Policy **templates** ship in the plugin's `policies/` directory (repo root). Setup copies and fills them into your `{assistantPath}/policies/` folder.

Outside the plugin directory — so `/plugin update` overwrites plugin files but never your personalisation. Open this folder in Cowork or Cursor so hooks and scheduled jobs find your files. Path resolution: `rules/paths.md`.

## Run setup

```
/assistant:setup
```

Pick the 2-minute quick-start, a **starter profile**, or the full 10-minute interview.

### Starter profiles

Five vertical ICP personas ship in `config/starter-profiles/` — fictional identities for profile sections (identity, voice, working rules). Policies are always filled from the master templates in `policies/`:

| Starter | Best for |
|---------|----------|
| Founder | Early-stage CEO / co-founder |
| Consultant | Independent advisor |
| Sales lead | Account executive |
| Operator | Chief of staff / ops lead |
| Investor | Angel / micro-VC |

During `/assistant:setup`, choose a starter for a quick customize (name, company, timezone) or keep as-is for demo. The assistant writes profile to `{assistantPath}/config/` and policies to `{assistantPath}/policies/`.

Browse [before/after draft demos](../../examples/before-after/) to see generic AI output vs profile-tuned replies. **Evals** still use Alex Rivera ([`evals/profile.fixture.md`](../../evals/profile.fixture.md)); starters are for onboarding.

### Interview sections

| Section | File | What it captures |
|---------|------|------------------|
| **Identity** | `profile.md` | Name, role, timezone, working hours, key people |
| **Voice** | `profile.md` | Tone, spelling, formats, sign-offs by relationship |
| **Anti-style** | `profile.md` | AI tells to never use ("delve", "circle back", em-dash overuse) |
| **Working rules & autonomy** | `profile.md` | Draft-vs-send, money threshold, autonomy tier |
| **Goals** | `profile.md` | This quarter's priorities and deadlines (optional) |
| **VIP tiers** | `email.policy.md` | Who surfaces first and who to draft fastest for |
| **Email policy** | `email.policy.md` | Reply threshold, auto-archive senders, labels |
| **Calendar policy** | `calendar.policy.md` | Working hours, buffers, focus-time defence |

## Tips

- **Be specific about voice.** "Direct and warm, no fluff" beats "professional."
- **The anti-style section matters most** — it's the most effective way to stop generic AI output.
- **Paste real emails** into `{assistantPath}/voice/` so drafts match your rhythm.
- **Autonomy defaults to Tier 1 (Draft).** Raise it only after a week of good output.

## Update later

Re-run `/assistant:setup` to adjust any section, or just correct the assistant mid-work — when a durable convention emerges (a new VIP, a tone tweak), it proposes a change and shows you the diff before writing.

## Next

[Examples gallery →](../../examples/README.md) · [Skills and commands →](03-skills-and-commands.md) · [Connect your tools →](04-connect-tools.md)
