---
name: memory-management
description: Two-tier memory that decodes shorthand, acronyms, nicknames, and internal
  language so the assistant understands requests like a colleague would. Activate when
  the user introduces a person, project, or term ("remember that", "X means Y", "who is
  Todd"), during /assistant:update, "/assistant:memory add", "/assistant:memory prune",
  or when another skill surfaces a durable fact to save. CLAUDE.md for working memory, memory/ for the full knowledge base.
user-invocable: false
---

# Memory management

Memory makes the assistant your workplace collaborator — someone who speaks your internal language.

## The goal

Transform shorthand into understanding:

```
User: "ask todd to do the PSR for oracle"
              ↓ decode
"Ask Todd Martinez (Finance lead) to prepare the Pipeline Status Report
 for the Oracle Systems deal ($2.3M, closing Q2)"
```

Without memory, that request is meaningless. With memory, the assistant knows:
- **todd** → Todd Martinez, Finance lead, prefers Slack
- **PSR** → Pipeline Status Report (weekly sales doc)
- **oracle** → Oracle Systems deal, not the company

## Three layers — don't mix them up

| Layer | File | What lives here |
|-------|------|-----------------|
| **Profile** | `~/.claude/plugins/config/my-assistant/profile.md` | Identity, voice, VIP tiers, email/calendar policy, autonomy — written by `/assistant:setup` |
| **Working memory** | `CLAUDE.md` in the working folder | Hot cache: top people, terms, active projects (~50–80 lines) |
| **Deep memory** | `memory/` in the working folder | Full glossary, people profiles, project detail, company context |

**Read the profile first** for who the user is and how they write. Use `CLAUDE.md` + `memory/` to decode shorthand and store workplace context. Never duplicate voice, VIP tiers, or identity into `CLAUDE.md` — that's the profile's job.

In Cowork, the profile may live in a workspace folder the user has open; check there too.

## Architecture

```
profile.md         ← Who you are, how you write, your rules (setup interview)
CLAUDE.md          ← Hot cache (~30 people, common terms)
memory/
  glossary.md      ← Full decoder ring (everything)
  people/          ← Complete profiles
  projects/        ← Project details
  context/         ← Company, teams, tools
```

**CLAUDE.md (hot cache):**
- Top ~30 people you interact with most
- ~30 most common acronyms/terms
- Active projects (5–15)
- Work preferences not already in the profile
- **Goal: cover 90% of daily decoding needs**

**memory/glossary.md (full glossary):**
- Complete decoder ring — everyone, every term
- Searched when something isn't in `CLAUDE.md`
- Can grow indefinitely

**memory/people/, projects/, context/:**
- Rich detail when needed for execution
- Full profiles, history, context

## Lookup flow

```
User: "ask todd about the PSR for phoenix"

1. Check CLAUDE.md (hot cache)
   → Todd? ✓ Todd Martinez, Finance
   → PSR? ✓ Pipeline Status Report
   → Phoenix? ✓ DB migration project

2. If not found → search memory/glossary.md
   → Full glossary has everyone/everything

3. If still not found → ask user
   → "What does X mean? I'll remember it."
```

This tiered approach keeps `CLAUDE.md` lean (~100 lines) while supporting unlimited scale in `memory/`.

## File locations

All memory files live in the **working folder** — the directory where `TASKS.md`, briefs, and drafts also live. Create `memory/` and the memory `CLAUDE.md` if missing.

- **Working memory:** `CLAUDE.md` in the working folder
- **Deep memory:** `memory/` subdirectory

**Visual editor:** `skills/dashboard.html` (open in Chrome or Edge) — Memory tab opens the working folder to browse and edit `CLAUDE.md` and `memory/` files.

Per `rules/file-safety.md`: the assistant may write to `memory/` and the memory `CLAUDE.md` without asking; tell the user what was added or changed.

## Working memory format (CLAUDE.md)

Use tables for compactness. Target ~50–80 lines total. Do **not** repeat profile content (name, voice, VIP list).

```markdown
# Memory

## People
| Who | Role |
|-----|------|
| **Todd** | Todd Martinez, Finance lead |
| **Sarah** | Sarah Chen, Engineering (Platform) |
| **Greg** | Greg Wilson, Sales |
→ Full list: memory/glossary.md, profiles: memory/people/

## Terms
| Term | Meaning |
|------|---------|
| PSR | Pipeline Status Report |
| P0 | Drop everything priority |
| standup | Daily 9am sync |
→ Full glossary: memory/glossary.md

## Projects
| Name | What |
|------|------|
| **Phoenix** | DB migration, Q2 launch |
| **Horizon** | Mobile app redesign |
→ Details: memory/projects/

## Preferences
- 25-min meetings with buffers
- Async-first, Slack over email
- No meetings Friday afternoons
```

## Deep memory format (memory/)

**memory/glossary.md** — the decoder ring:

```markdown
# Glossary

Workplace shorthand, acronyms, and internal language.

## Acronyms
| Term | Meaning | Context |
|------|---------|---------|
| PSR | Pipeline Status Report | Weekly sales doc |
| OKR | Objectives & Key Results | Quarterly planning |
| P0/P1/P2 | Priority levels | P0 = drop everything |

## Internal terms
| Term | Meaning |
|------|---------|
| standup | Daily 9am sync in #engineering |
| the migration | Project Phoenix database work |
| ship it | Deploy to production |
| escalate | Loop in leadership |

## Nicknames → full names
| Nickname | Person |
|----------|--------|
| Todd | Todd Martinez (Finance) |
| T | Also Todd Martinez |

## Project codenames
| Codename | Project |
|----------|---------|
| Phoenix | Database migration |
| Horizon | New mobile app |
```

**memory/people/{name}.md:**

```markdown
# Todd Martinez

**Also known as:** Todd, T
**Role:** Finance Lead
**Team:** Finance
**Reports to:** CFO (Michael Chen)

## Communication
- Prefers Slack DM
- Quick responses, very direct
- Best time: mornings

## Context
- Handles all PSRs and financial reporting
- Key contact for deal approvals over $500k
- Works closely with Sales on forecasting

## Notes
- Cubs fan, likes talking baseball
```

**memory/projects/{name}.md:**

```markdown
# Project Phoenix

**Codename:** Phoenix
**Also called:** "the migration"
**Status:** Active, launching Q2

## What it is
Database migration from legacy Oracle to PostgreSQL.

## Key people
- Sarah — tech lead
- Todd — budget owner
- Greg — stakeholder (sales impact)

## Context
$1.2M budget, 6-month timeline. Critical path for Horizon project.
```

**memory/context/company.md:**

```markdown
# Company context

## Tools & systems
| Tool | Used for | Internal name |
|------|----------|---------------|
| Slack | Communication | - |
| Asana | Engineering tasks | - |
| Salesforce | CRM | "SF" or "the CRM" |
| Notion | Docs/wiki | - |

## Teams
| Team | What they do | Key people |
|------|--------------|------------|
| Platform | Infrastructure | Sarah (lead) |
| Finance | Money stuff | Todd (lead) |
| Sales | Revenue | Greg |

## Processes
| Process | What it means |
|---------|---------------|
| Weekly sync | Monday 10am all-hands |
| Ship review | Thursday deploy approval |
```

## How to interact

### Decoding user input (tiered lookup)

**Always** decode shorthand before acting on requests:

```
1. profile.md                  → Identity, VIP tiers (for prioritisation)
2. CLAUDE.md (hot cache)       → Check first, covers 90% of cases
3. memory/glossary.md          → Full glossary if not in hot cache
4. memory/people/, projects/    → Rich detail when needed
5. Ask user                    → Unknown term? Learn it.
```

Example:

```
User: "ask todd to do the PSR for oracle"

CLAUDE.md lookup:
  "todd" → Todd Martinez, Finance ✓
  "PSR" → Pipeline Status Report ✓
  "oracle" → (not in hot cache)

memory/glossary.md lookup:
  "oracle" → Oracle Systems deal ($2.3M) ✓

Now the assistant can act with full context.
```

### Adding memory

When the user says "remember this", "X means Y", or introduces a person/project:

1. **Glossary items** (acronyms, terms, shorthand):
   - Add to `memory/glossary.md`
   - If frequently used, add to `CLAUDE.md` Terms table

2. **People:**
   - Create/update `memory/people/{name}.md`
   - Add to `CLAUDE.md` People table if important
   - **Capture nicknames** — critical for decoding
   - If they're a VIP or key person, **propose a profile update** (show diff, ask first)

3. **Projects:**
   - Create/update `memory/projects/{name}.md`
   - Add to `CLAUDE.md` Projects table if current
   - **Capture codenames** — "Phoenix", "the migration", etc.

4. **Work preferences:** add to `CLAUDE.md` Preferences (not the profile unless it's a durable policy change)

Tell the user what was saved. Never store passwords, PINs, 2FA codes, or full account numbers.

### Recalling memory

When the user asks "who is X" or "what does X mean":

1. Check `CLAUDE.md` first
2. Check `memory/` for full detail
3. If not found: "I don't know what X means yet. Can you tell me?"

### Progressive disclosure

1. Load `CLAUDE.md` for quick parsing of any request
2. Dive into `memory/` when you need full context for execution
3. Example: drafting an email to todd about the PSR
   - `CLAUDE.md` tells you Todd = Todd Martinez, PSR = Pipeline Status Report
   - `memory/people/todd-martinez.md` tells you he prefers Slack, is direct

## Integration with other skills

| Skill / command | How memory fits |
|-----------------|-----------------|
| **meeting-prep** | Decode attendees; offer to save new facts after prep |
| **meeting-follow-up** | Resolve names in notes; offer to save people/projects/decisions |
| **inbox-triage** / **email-drafting** | Decode thread shorthand; match senders to `memory/people/` |
| **task-management** | Decode task entities ("PSR for oracle" → real names) |
| **weekly-review** | Prune stale or contradictory entries with user confirmation |
| **`/assistant:update`** | Decode task entities against memory; surface gaps to fill |
| **`/assistant:update --comprehensive`** | Scan `~~email`, `~~calendar`, `~~chat`, `~~drive` for new people/projects not yet in memory — present each for the user to add, never auto-add |
| **`/assistant:memory add`** | Explicit capture of people, projects, or terms |
| **`/assistant:memory prune`** | Demote stale entries; propose removals with confirmation |

When another skill surfaces a durable fact, **offer** to save it — don't add silently.

## Bootstrapping

- **No profile yet?** Offer `/assistant:setup` — captures identity, voice, and key people into the profile.
- **Empty memory?** Start with `CLAUDE.md` and `memory/glossary.md` from what the user tells you in conversation.
- **Fill gaps from activity:** `/assistant:update` decodes existing tasks against memory and asks about unknowns. Add `--comprehensive` to scan connected sources for people and projects worth remembering.

No connectors? Memory still works from conversation, pasted threads, and meeting notes.

## Conventions

- **Bold** terms in `CLAUDE.md` for scannability
- Keep `CLAUDE.md` under ~100 lines (the "hot 30" rule)
- Filenames: lowercase, hyphens (`todd-martinez.md`, `project-phoenix.md`)
- Always capture nicknames and alternate names
- Glossary tables for easy lookup
- When something's used frequently, promote it to `CLAUDE.md`
- When something goes stale, demote it to `memory/` only

## What goes where

| Type | profile.md | CLAUDE.md (hot cache) | memory/ (full storage) |
|------|------------|----------------------|------------------------|
| Your identity & voice | ✓ | ✗ | ✗ |
| VIP tiers & email policy | ✓ | ✗ | ✗ |
| Person | Key people only | Top ~30 frequent contacts | glossary.md + people/{name}.md |
| Acronym/term | ✗ | ~30 most common | glossary.md (complete list) |
| Project | Goals/deadlines | Active projects only | glossary.md + projects/{name}.md |
| Nickname | ✗ | In People if top 30 | glossary.md (all nicknames) |
| Company context | ✗ | Quick reference only | context/company.md |
| Work preferences | Policy-level | Day-to-day prefs | — |
| Historical/stale | ✗ | ✗ Remove | ✓ Keep in memory/ |

## Promotion / demotion

**Promote to CLAUDE.md when:**
- You use a term/person frequently
- It's part of active work

**Demote to memory/ only when:**
- Project completed
- Person no longer a frequent contact
- Term rarely used

**Propose a profile update when:**
- Someone becomes a VIP or key person
- A durable policy preference emerges (not just a shorthand term)

This keeps `CLAUDE.md` fresh and relevant without bloating the profile.

## Rules

- Decode before acting — never guess what shorthand means.
- Tell the user after every write to `memory/` or the memory `CLAUDE.md`.
- Don't delete or overwrite memory entries without confirmation.
- Don't invent biographies — if someone isn't in memory, say so and offer to learn.
- Profile changes always need a diff and approval (except during setup).
