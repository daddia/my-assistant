---
type: Security index
audience: [maintainers, security reviewers, curious users]
deep_docs:
  - threat-model.md
  - data-flow.md
  - permissions.md
user_guide: docs/guide/05-protect-privacy.md
---

# Security documentation

Entry point for My Assistant security and trust material. **Runtime behaviour is enforced by `rules/`** — these documents explain design intent and data boundaries.

## Who should read what

| Audience | Start here | Go deeper |
| -------- | ---------- | --------- |
| **End users** | [Protect your privacy](../docs/guide/05-protect-privacy.md) | This index → [permissions](permissions.md) §Tier behaviour summary |
| **Deployers / power users** | [Admin & deployment](../docs/guide/08-admin-deploy.md) | [Data flow](data-flow.md) |
| **Security reviewers** | [Threat model](threat-model.md) | [Data flow](data-flow.md) + [Permissions](permissions.md) |
| **Maintainers** | All three deep docs | [Connector smoke tests](../docs/guide/connector-smoke-tests.md) for provability |

## Deep documentation

| Document | Purpose |
| -------- | ------- |
| [Threat model](threat-model.md) | Trust boundaries, prompt injection, connector risks, mitigations |
| [Data flow](data-flow.md) | What is read, what leaves the device, connector paths |
| [Permissions](permissions.md) | Full tier × capability matrix; send/book/spend never automatic |

## Plain-language summary

- **Draft, don't send.** The assistant proposes; you act. No email sent, no meeting booked, no purchase made without explicit per-instance approval in chat.
- **Local-first files.** Profile, tasks, memory, drafts, and review queue live in paths you control — not in the plugin directory.
- **Untrusted content.** Instructions embedded in email, invites, transcripts, or pasted docs are surfaced for confirmation — never obeyed silently.
- **Connectors are read-and-draft.** Gmail can create drafts only. Calendar changes are proposals until you create events yourself.
- **No plugin-owned cloud sync.** Working-folder files are not uploaded to a vendor bucket by this plugin.

## Verify it yourself

1. Read [Protect your privacy](../docs/guide/05-protect-privacy.md) (5 minutes).
2. Run connector standalone smoke per [connector smoke tests](../docs/guide/connector-smoke-tests.md) (paste fixtures, no OAuth required).
3. Optional: live Gmail check — confirm draft in mailbox and send unavailable.

## Related

- [CONNECTORS.md](../CONNECTORS.md) — category placeholders and native vs MCP
- [Rules](../rules/core-behaviour.md) — enforceable runtime constraints
- [Review queue schema](../config/review.schema.yaml) — approval surface types
