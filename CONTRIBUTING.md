# Contributing to My Assistant

Thanks for your interest in contributing! Bug reports, enhancement ideas, doc fixes, and pull requests all help.

## Reporting bugs

1. **Check the [issue tracker](https://github.com/daddia/my-assistant/issues)** for an existing report.
2. **Open a new issue** with a clear title, what you expected, what happened, and steps to reproduce. Include which **runtime** you used (Claude Cowork, Claude Code, or Cursor) and which **connectors** (if any) were active.

## Suggesting enhancements

Check the tracker, then open an issue describing the change and the benefit. Enhancements might include new skills, sharper skill descriptions, better guardrails, or connector coverage.

## Repository layout

This is one plugin — file-based, no build step.

```
my-assistant/
├── .claude-plugin/plugin.json, marketplace.json   # Claude manifests
├── .cursor-plugin/plugin.json, marketplace.json   # Cursor manifests
├── .mcp.json                                        # connector suggestions
├── AGENTS.md  (CLAUDE.md → @AGENTS.md)              # orchestration
├── CONNECTORS.md                                    # ~~category placeholders
├── commands/   *.md                                 # slash commands
├── skills/     <name>/SKILL.md                      # auto-firing skills (+ dashboard.html)
├── agents/     *.md                                 # named + schedulable agents
├── managed-agents/ <name>/agent.yaml                # headless cookbooks
├── hooks/hooks.json, load-profile.sh                # SessionStart profile load (config + workspace)
├── rules/      core-behaviour.md, untrusted-content.md, file-safety.md
├── config/     profile.template.md                  # copied to the user's profile on setup
└── docs/       guide/
```

**User data never lives in the plugin.** Personalisation goes to `~/MyAssistant/config/profile.md`; tasks and memory live in the user's working folder. Never commit real names, contacts, or private data.

**Naming:** display name **My Assistant** · repo/marketplace/profile path `my-assistant` · plugin manifest `name` `assistant` · commands `/assistant:*`.

## Development environment

- **Git** — clone, branch, open PRs.
- **A text editor** — Markdown and YAML.
- **Python 3.12+** with dev dependencies — `pip install -r requirements.txt` (or create a `.venv` at repo root; the fixture validator uses it automatically).
- **A runtime (recommended)** — Claude Cowork, Claude Code, or Cursor, to exercise skills as users do.

Read [`AGENTS.md`](./AGENTS.md) and [`docs/guide/00-introduction.md`](./docs/guide/00-introduction.md) before your first change.

## Making changes

- **Manifests** — `.cursor-plugin/plugin.json` and `.claude-plugin/plugin.json` declare the same `skills`, `commands`, `agents`, `hooks`, `rules`, and `mcpServers` paths. Keep them in lockstep when those directories change.
- **New/edited skill** — `skills/<name>/SKILL.md` with `name` + `description` frontmatter. Descriptions must be explicit — Cowork under-triggers on weak ones. Keep a skill to one job; chain via documentation, not duplicated logic. Prefer `~~category` connector wording over product names.
- **New command** — `commands/<name>.md`; keep it a thin entry point that points at the relevant skill(s). Domain commands take verb arguments (`/assistant:inbox triage`); workflow commands are curated rituals (`/assistant:brief`). See the routing table in `AGENTS.md`.
- **New rule** — under `rules/`; reference it from `AGENTS.md`.
- **Connector suggestion** — add to `.mcp.json` and document in `CONNECTORS.md`.
- **Guardrails** — any change must preserve draft-don't-send, untrusted-content handling, and the autonomy tiers in [`rules/core-behaviour.md`](./rules/core-behaviour.md) and [`rules/untrusted-content.md`](./rules/untrusted-content.md).

## Testing

See [`docs/testing.md`](./docs/testing.md) for the full testing guide.

### Proof harness (eval fixtures)

For inbox triage, draft quality, and prompt-injection regression, follow the manual eval workflow in [`evals/README.md`](./evals/README.md). Run structural validation from the repo root:

```bash
python3 scripts/validate_fixtures.py
```

Or use the shell wrapper (uses `.venv/bin/python` when present):

```bash
LANG=en_US.UTF-8 ./evals/scripts/validate-fixtures.sh
```

Requires `pip install -r requirements.txt` if PyYAML is not already installed.

Structural validation also runs on every pull request via GitHub Actions.

Smoke subset: five corpus threads (VIP, marketing, ambiguous, long-thread, scheduling) plus the full injection suite. Record results in an `eval-run-YYYY-MM-DD.md` run log as described in the eval README.

**MA12 inbox excellence:** 44-thread corpus (includes live edge fixtures `36`–`39` and MA13 draft edge `40`–`44`), batch-digest smoke via `evals/corpus/batch-paste-bulk.md`, sweep→brief handoff check. CI runs `evals/automation/score_inbox.py --validate-goldens`. Full corpus triage rubric must score ≥ **90% Pass** for manual sign-off.

**MA13 draft excellence:** 18 draft goldens minimum; draft rubric ≥ **90% Pass** on `draft_required` threads including §6 Grounding. CI runs `score_draft.py` and `score_feedback.py --validate-goldens`. Feedback smoke 5/5; profile-diff goldens `fb-03`, `fb-04`, `fb-05` must pass.

**MA14 calendar depth:** 11 calendar fixtures minimum (6 protect + 5 new protect/schedule); protect rubric + [`evals/calendar/rubric/scheduling-accuracy.md`](./evals/calendar/rubric/scheduling-accuracy.md) each ≥ **90% Pass** for manual sign-off. CI smoke: `cal-01`, `cal-03`, `cal-04`, `cal-06`, `cal-08`. Domain registered in [`evals/automation/manifest.yaml`](./evals/automation/manifest.yaml).

### Skill and behaviour checks

Validate in an agent session, not a unit-test runner:

1. Install the plugin locally (add this repo as a directory marketplace, or point Claude Code at it).
2. Trigger the change via its slash command or a natural-language phrase matching the skill `description`.
3. Confirm drafts/outputs land in the right place and that no skill sends, books, or spends. Check behaviour against [`rules/core-behaviour.md`](./rules/core-behaviour.md) and [`rules/file-safety.md`](./rules/file-safety.md).

For doc-only PRs, preview the changed pages and check links under `docs/`.

## Submitting pull requests

1. **Branch** with a descriptive name (`feat/meeting-followup-skill`, `docs/readme`).
2. **Privacy check** — no real profiles, `.env`, or `*.local.md` in the commit.
3. **Changelog** — add a short entry under `[Unreleased]` in [`CHANGELOG.md`](./CHANGELOG.md) for user-visible changes.
4. **Commit** clearly and descriptively.
5. **Open the PR** with a clear title and description; link related issues. Suggested prefixes: `feat(skills):`, `fix(docs):`, `chore:`.
6. **Respond to review** feedback.

Thank you for contributing!
