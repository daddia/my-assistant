# Triage config (example — replace with your values)

Copy to `~/.claude-assistant/config/triage-config.md`. Discover Gmail label IDs via your connector's list-labels tool.

## Label IDs

| Label name | Gmail ID |
|------------|----------|
| @ToRead | LABEL_ID_HERE |
| Auto-Archive | LABEL_ID_HERE |

## Newsletter platforms
substack.com, beehiiv.com, mailchimp.com, buttondown.email

## Classification priority
1. VIP (from email-policy.md) → skip / surface only
2. Receipt / noreply notification → Auto-Archive
3. Newsletter platform → @ToRead
4. Score 0 (ambiguous) → SKIP, flag in summary

## Thresholds
- Archive only on explicit user confirmation after showing a table of proposed actions.
