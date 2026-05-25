# Email policy (example — replace with your values)

Copy to `~/.claude-assistant/config/email-policy.md` and edit locally. Do not commit the populated file.

## VIP tiers

### Tier 1 — Never touch without explicit confirmation
- Immediate family
- [add names or addresses]

### Tier 2 — High priority
- Close friends
- [add names or addresses]

## Auto-archive (high confidence)
Exact sender matches only. Start conservative; add after reviewing triage reports.

| Sender | Action |
|--------|--------|
| noreply@github.com | Archive + mark read |
| notifications@example.com | Archive + mark read |

## Required Gmail labels
- `@ToRead`
- `@Family`
- `Auto-Archive`

## Rules
- Never mark Tier 1 as read without separate confirmation.
- When in doubt, leave in inbox and flag in summary.
