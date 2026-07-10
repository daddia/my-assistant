---
name: setup-interview
description: Onboarding interview for the assistant plugin. Activate when the user says
  "/assistant:setup", "set me up", "configure my assistant", "help me get started",
  or when no profile exists at ~/.claude/plugins/config/my-assistant/profile.md.
  Writes the personalisation profile that every other skill reads.
---

# Setup interview

A 10-minute conversation that produces the user's **profile** — the single file that makes every other skill sound like them and respect their rules. Skipping this is the number-one cause of generic output, so lead with it.

## Where the profile goes

Write to `~/.claude/plugins/config/my-assistant/profile.md` — **outside** the plugin directory, so `/plugin update` never overwrites it. Create the directory if needed. Base it on `config/profile.template.md` in the plugin.

In Cowork, if the user prefers, the profile can live in a workspace folder they keep open. Ask which they want; default to the config path. **Starter profiles follow the same path choice** — copy the selected starter to whichever location the user picks.

> This is the only skill that writes the full profile without a diff prompt. Every other skill proposes profile changes and asks first.

## Three paths — offer when no profile exists

When **no profile exists** (or the user asks to "start from template"), read `config/starter-profiles/manifest.yaml` and present:

| Option | What happens |
|--------|----------------|
| **Starter persona** (five choices) | Copy a vertical ICP profile, optional quick customize, write external profile |
| **Blank template (full interview)** | Existing eight-section interview below |
| **Quick-start (2 min)** | Identity + voice one-liner + autonomy tier only (blank path shortcut) |

### Starter selection table

Present all five starters with ICP one-liner from the manifest:

| ID | Title | ICP |
|----|-------|-----|
| `founder` | Founder | Early-stage CEO or co-founder |
| `consultant` | Consultant | Independent advisor |
| `sales-lead` | Sales lead | Account executive |
| `operator` | Operator | Chief of staff / ops lead |
| `investor` | Investor | Angel / micro-VC |

### Starter flow

1. User picks a starter id (or blank / quick-start).
2. **Unknown id** — list valid ids from manifest; offer blank interview. Do not write a partial profile.
3. **Missing starter file** — say "Starter unavailable — use blank template" and link to the repo issue tracker. Do not write an empty profile.
4. Read `config/starter-profiles/{id}.md`.
5. Offer **Quick customize** (name, company, timezone) OR **Keep as-is for demo**.
6. **Do not write** until the user confirms customize-or-keep (match interview pacing — no half-written profiles if they abort).
7. Write the profile to the chosen external path.
8. Summarize: `Profile: {Title} starter (customized|as-is)`.
9. Point to `examples/README.md` and `examples/workflows/setup-with-starter.md`; suggest thread `01-vip-board-update` for a first paste demo.

If user picks **blank** or **quick-start**, continue with the paths below.

## Two paths — when blank or profile exists

- **Quick-start (2 min):** identity + voice one-liner + autonomy tier. Enough to be useful today.
- **Full interview (10 min):** all eight sections below. Recommend this when not using a starter.

Ask which they'd like (when not using a starter), then proceed.

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

Fill the template section by section from their answers. Leave clear placeholders for anything skipped. Keep it under ~2,000 words.

### Post-setup health check

After the **initial** profile write (starter, quick-start, or full interview — not when updating an existing profile), run the health check **subset**:

1. Read and follow `skills/health-check/SKILL.md` with `checks: [profile, working-folder]` only.
2. Render a compact **Setup health** block (≤8 lines): summary counts (`pass` / `warn` / `fail` / `skip`) plus the top fails or warns with `fix_ref` links.
3. Do **not** block the wedge on warnings — always continue to the handoff below.
4. Chat-only — do not auto-save `health-report-*.md` after setup.

Then summarise what's captured and point them at the wedge:

> "You're set up. Try `/assistant:inbox triage` to sort your mail, or `/assistant:brief` for a morning briefing. Run `/assistant:health` anytime for a full install check. Browse [`examples/README.md`](../../examples/README.md) for persona demos and before/after drafts. Re-run `/assistant:setup` anytime to adjust."

## Notes

- Never store passwords, PINs, 2FA codes, or full account numbers.
- If a profile already exists, don't overwrite blindly — ask whether to update specific sections and show the diff.
- Everything works standalone; connectors just make it sharper. Don't block setup on OAuth.

## Approval frame

Follow [`rules/approval-frame.md`](../../rules/approval-frame.md) when proposing post-setup profile changes.

**Queue writing:**

- The **initial full profile write** during setup is **exempt** from `profile-diff` queue items — the user is actively answering interview questions.
- **Post-setup profile change proposals** use queue type `profile-diff` via the standard diff flow in `pending-profile/`.

Use the four-part frame when showing profile diffs after setup.
