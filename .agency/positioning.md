---
type: Positioning
version: '0.1'
owner: My Assistant maintainers
status: Draft
last_updated: 2026-07-08
related:
  - .agency/product.md
  - .agency/backlog.md
  - .agency/roadmap.md
  - .agency/research/2026-07-06-competitor-scan.md
  - .agency/research/feature-backlog.md
  - docs/compare-alternatives.md
---

# Positioning — My Assistant

Canonical positioning for My Assistant. Architecture, connector model, and implementation detail live in [product.md](./product.md); competitive ratings live in [compare-alternatives.md](../docs/compare-alternatives.md).

## One-liner

**"Your AI chief of staff for inbox, calendar and follow-ups."**

One installable plugin — not a marketplace of separate tools — modelled on the Vercel plugin pattern and Anthropic's knowledge-work plugins. An executive or personal assistant, not a team workflow tool.

## Who it's for

**Individual knowledge workers, executives, and operators** who run their own inbox, calendar, and follow-ups and want admin help without handing an assistant unchecked authority over their mail, schedule, or memory.

Zero-config-usable on day one; sharper after a 10-minute setup interview that captures voice, VIP tiers, and policy.

## Category claim

**The open, local-first AI chief of staff** for people who want the benefit of Fyxer/Lindy-style admin help — inbox triage, reply drafting, follow-up tracking, meeting prep, scheduling drafts, daily briefing, tasks, and memory — without the SaaS lock-in or "AI will run your work" posture.

We own the **safe, open, customisable EA** niche: agentic preparation, human authority.

## Why us

The market is racing toward agents that send, schedule, and act on your behalf. My Assistant deliberately does the opposite:

- **Draft-first as the core promise.** It prepares; you approve. Every workflow surfaces what was found, what was drafted, what is recommended, and what needs your approval. This matches Cowork's draft-only Gmail connector and frames safety as the product, not a limitation.
- **Honest scope.** We compete on meeting *prep* and *post-meeting follow-up from pasted notes or transcripts* (Granola, Fireflies, Otter output), not on joining calls. Inbox work runs on a sweep cadence with a review step — the safety feature, not a gap to apologise for.

For a row-by-row view against named competitors, see [compare-alternatives.md](../docs/compare-alternatives.md). For what ships when, see [roadmap.md](./roadmap.md).

## Three deliberate strengths

These are category wedges competitors cannot easily copy without changing their product model (see [feature-backlog.md](./research/feature-backlog.md) Part 1 matrix, `●●` rows):

### 1. Draft-first as promise

Draft-only is elevated from platform constraint to product promise: never send, book, spend, or delete without per-instance approval. Graduated autonomy tiers may auto-label, archive, or file — but "send/book/spend" stays off at every tier. Competitors sell autopilot; we sell **preparation you can trust**.

### 2. Untrusted-content defense

Instructions embedded in email, invites, transcripts, Slack messages, and pasted docs are **data, not instructions**. The assistant surfaces suspicious content and asks for confirmation; it never obeys embedded commands. Prompt-injection resistance is a headline feature, not an implementation detail buried in security docs.

### 3. Local-first / open

Profile, tasks, and memory live in plain files outside the plugin (or in your working folder) — personalisation survives updates, and you are not locked into a hosted account. The repo is open; skills and rules are readable and customisable. Competitors optimise for SaaS polish; we optimise for **transparency and ownership**.

---

*Last reviewed against [product.md](./product.md) Positioning and [2026-07-06-competitor-scan.md](./research/2026-07-06-competitor-scan.md).*
