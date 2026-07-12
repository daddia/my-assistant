---
name: email-drafting
description: Draft email, chat, and letter replies in the user's own voice. Activate when
  triaging needs-reply mail, when the user says "/assistant:draft email|chat|letter",
  "/assistant:email draft", "draft a reply", or pastes a message they need to answer.
  Creates drafts only — never sends.
---

# Email drafting

Write the reply the user would have written on their best day — then leave it as a draft for them to glance at and send. Never send.

## Voice is the whole job

Load the profile's **voice** and **anti-style** sections (and any samples in `voice/`) before writing a word. Match:

- Their one-line voice, sentence rhythm, and typical length (usually shorter than people expect).
- Sign-off by relationship — client vs colleague vs friend (from the profile).
- Opener style ("Hi [Name]," not "Dear").

And avoid every banned tell: no "I hope this finds you well", no "just wanted to reach out", no delve/leverage/robust, no hedging stacks, no em-dash overuse. If the draft could have come from any AI, rewrite it.

## How to draft

1. Read the thread. Identify what the sender actually wants and what the user needs to decide or say.
2. If the reply needs a fact the user hasn't given (a date, a number, a yes/no), don't invent it — leave a clearly marked `[[gap: confirm the date]]` inline and note it above the draft.
3. Write the draft in the user's voice, as short as it can be while complete.
4. Match formality to the contact's VIP tier and relationship.

## Where the draft goes

- **Connected (`~~email`):** create a Gmail draft on the thread (draft-only connector — this is exactly right). Confirm the draft is in place.
- **Standalone:** return the draft text in a code block for the user to copy, plus a one-line note of any gaps.

## Output shape

```
Draft — Re: Q3 board deck (to Priya, Tier 1)

  Hi Priya,

  Revised deck attached — I tightened the revenue slide and cut
  the appendix. [[gap: attach the file before sending]]

  Happy to walk through it Thursday if useful.

  Jon

Gaps to fill: attach the deck.
```

## Rules

- **Draft only.** Never send, even at Tier 3.
- One draft per thread; if there are several plausible responses (accept vs decline), offer the two shortest options rather than one long hedge.
- Don't over-explain or pad. A three-line reply that lands beats a paragraph that hedges.
- Flag anything that commits the user (a deadline, a spend, a promise) so they notice before sending.

## Approval frame

Follow [`rules/approval-frame.md`](../../rules/approval-frame.md) for every draft.

**Queue writing:**

- Write a `reply-draft` item to `review-queue/index.yaml` for each draft produced.
- **Always** create a local mirror at `drafts/reply-*.md` in the working folder — even when a Gmail draft is created via `~~email`.
- Set `external_ref` to the connector draft id when present (e.g. Gmail draft id).

Append the observability footer when queue items are written.

## Post-draft feedback prompt

After presenting a **standalone** draft (via `/assistant:email draft` or a single-thread draft request), append one optional line:

```text
Sent it? `/assistant:email feedback good` · light edit · heavy rewrite` — helps tune your voice.
```

**Omit** when:

- User is mid-thread or clearly iterating on the same draft.
- Draft was produced inside **inbox-triage** batch context (many drafts in one run).
- User already invoked feedback or dismissed the prompt.
