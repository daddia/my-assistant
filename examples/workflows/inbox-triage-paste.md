# Workflow — inbox triage (paste-only)

Triage and draft a reply from a pasted email thread — no connectors required.

## Prerequisites

- Profile loaded (starter from `/assistant:setup` or paste a starter file)
- A corpus thread from [`evals/corpus/threads/`](../../evals/corpus/threads/)

## Recommended threads

| Thread ID | File | Good for |
|-----------|------|----------|
| `01-vip-board-update` | [`01-vip-board-update.md`](../../evals/corpus/threads/01-vip-board-update.md) | VIP / board tone |
| `04-needs-reply-contract-renewal` | [`04-needs-reply-contract-renewal.md`](../../evals/corpus/threads/04-needs-reply-contract-renewal.md) | Commercial negotiation |
| `24-scheduling-client-meeting` | [`24-scheduling-client-meeting.md`](../../evals/corpus/threads/24-scheduling-client-meeting.md) | Scheduling / calendar |

## Steps

### 1. Paste the thread

Open a thread file and paste the full contents into chat.

### 2. Triage

```
/assistant:inbox triage
```

Review the bucket (Needs reply, VIP, FYI, etc.) and summary bullets.

### 3. Draft

```
/assistant:email draft
```

Or ask: "Draft a reply to this thread."

### 4. Compare

Find the matching before/after demo in [`examples/before-after/`](../before-after/):

- Generic draft = **what not to ship**
- `{persona}-draft.md` = profile-tuned reference for your starter

Live output may not match the curated demo exactly — the reference shows voice and required content gaps.

## Score against goldens (maintainers)

Compare to [`evals/golden/triage/{id}.yaml`](../../evals/golden/triage/) and [`evals/golden/drafts/{id}.yaml`](../../evals/golden/drafts/) using the rubrics in [`evals/rubric/`](../../evals/rubric/).

## See also

- [Setup with a starter](./setup-with-starter.md)
- [Proof harness](../../evals/README.md)
