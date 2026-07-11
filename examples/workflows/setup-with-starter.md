# Workflow — setup with a starter

Pick a vertical persona, optionally customize identity fields, then try inbox triage with a demo thread.

## Prerequisites

- Plugin installed (see root [README](../../README.md))
- No existing install at `~/MyAssistant/config/` (or choose to start fresh / pick a different folder)

## Steps

### 1. Run setup

```
/assistant:setup
```

When no profile exists, you'll see five **starter personas** plus **Blank template (full interview)**.

| Starter | ICP |
|---------|-----|
| Founder | Early-stage CEO or co-founder |
| Consultant | Independent advisor |
| Sales lead | Account executive |
| Operator | Chief of staff / ops lead |
| Investor | Angel or micro-VC |

### 2. Confirm working folder

Default `~/MyAssistant` — accept or choose another path.

### 3. Select a starter

Example: **Founder**

The assistant reads [`config/starter-profiles/founder.md`](../../config/starter-profiles/founder.md).

### 4. Customize or keep as-is

- **Quick customize** — update name, company, timezone
- **Keep as-is for demo** — write the starter verbatim (fictional identity)

Profile and `my-assistant.json` are written to `{assistantPath}/config/` (default `~/MyAssistant/config/`).

### 5. Confirm summary

Expect a line like: **Profile: Founder starter (customized)**

### 6. Try a demo thread

Continue with [Inbox triage (paste-only)](./inbox-triage-paste.md) using thread **01-vip-board-update**.

Compare your draft to [`before-after/01-vip-board-update/founder-draft.md`](../before-after/01-vip-board-update/founder-draft.md).

## If a profile already exists

Setup will not overwrite. Ask to update specific sections, or remove/rename the existing profile if you want a fresh starter.

## See also

- [Examples gallery](../README.md)
- [Configure your profile](../../docs/guide/02-configure-profile.md)
