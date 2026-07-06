---
name: setup-interview
description: Onboarding interview for my-assistant. Activate when the user says
  "/my-assistant:setup", "set me up", "configure my assistant", "help me get started",
  or when no profile exists at ~/.claude/plugins/config/my-assistant/profile.md.
  Writes the personalisation profile that every other skill reads.
---

# Setup interview

A 10-minute conversation that produces the user's **profile** — the single file that makes every other skill sound like them and respect their rules. Skipping this is the number-one cause of generic output, so lead with it.

## Where the profile goes

Write to `~/.claude/plugins/config/my-assistant/profile.md` — **outside** the plugin directory, so `/plugin update` never overwrites it. Create the directory if needed. Base it on `config/profile.template.md` in the plugin.

In Cowork, if the user prefers, the profile can live in a workspace folder they keep open. Ask which they want; default to the config path.

> This is the only skill that writes the full profile without a diff prompt. Every other skill proposes profile changes and asks first.

## Two paths — offer both

- **Quick-start (2 min):** identity + voice one-liner + autonomy tier. Enough to be useful today.
- **Full interview (10 min):** all eight sections below. Recommend this.

Ask which they'd like, then proceed.

## The interview — eight sections

Ask conversationally, one section at a time. Confirm and write after each. Don't dump all questions at once.

1. **Identity** — name, preferred name, role/company (skip for purely personal use), location, timezone, working hours, key people (partner, kids, co-founder, EA, top clients).
2. **Voice** — one-line description of their writing voice; locale/spelling; date/number formats; how they structure messages; default length; sign-offs by relationship (client vs colleague vs friend); openers. Then **show a two-sentence sample in that voice and ask if it sounds right.** Adjust until it does. Invite them to paste 2–3 real sent emails into a `voice/` folder next to the profile.
3. **Anti-style** — show the banned-tells list (openers, AI words, corporate-speak, em-dash/hedging/rule-of-three patterns). Ask which bother them most and what to add. Collect one "sounds like me" and one "sounds like AI" example.
4. **Working rules & autonomy** — pick an autonomy tier (default **Tier 1 — Draft**; explain the four tiers from `rules/core-behaviour.md`); scope (personal only? work + personal?); money threshold; anything off-limits.
5. **VIP tiers** — who must surface first and never be auto-touched (Tier 1); who to draft fastest for (Tier 2).
6. **Email policy** — reply threshold (which categories to draft for vs summarise vs archive — this is the "how often to reply" dial); exact-sender auto-archive list (start conservative); labels they use.
7. **Calendar policy** — working hours; meeting-length defaults and buffers; focus-time defence level; what may be auto-proposed vs must-always-ask.
8. **Goals** (optional) — this quarter's top objectives and deadlines to watch.

## Writing the profile

Fill the template section by section from their answers. Leave clear placeholders for anything skipped. Keep it under ~2,000 words. After writing, summarise what's captured and point them at the wedge:

> "You're set up. Try `/my-assistant:inbox` to triage your mail, or `/my-assistant:brief` for a morning briefing. Re-run `/my-assistant:setup` anytime to adjust."

## Notes

- Never store passwords, PINs, 2FA codes, or full account numbers.
- If a profile already exists, don't overwrite blindly — ask whether to update specific sections and show the diff.
- Everything works standalone; connectors just make it sharper. Don't block setup on OAuth.
