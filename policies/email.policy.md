# Email policy

VIP tiers, inbox triage, and reply rules. Setup writes this to `{assistantPath}/policies/email.policy.md` — outside the plugin, so `/plugin update` never overwrites it. See `rules/paths.md`.

---

## VIP tiers — who surfaces first

### Tier 1 — surface immediately, never auto-touch
- [immediate family, key clients — names or email addresses]

### Tier 2 — high priority, draft fastest
- [close colleagues, active-deal contacts]

### Tier 3 — normal
- Everyone else not caught by archive rules.

## Reply threshold

Which categories to draft for vs summarise vs archive — the "how often to reply" dial.

- [e.g. draft for needs-reply + VIP; summarise FYI; archive marketing]

## Auto-archive (high confidence, exact sender only)

| Sender | Action |
|--------|--------|
| noreply@github.com | Archive + mark read |
| [add exact addresses] | Archive + mark read |

## Labels in use

- [e.g. @ToRead, @Family, Auto-Archive]

## Newsletter platforms → @ToRead

substack.com, beehiiv.com, mailchimp.com, buttondown.email

## Rules

- Never mark Tier 1 read without confirmation.
- When in doubt, leave in inbox and flag in the summary.
