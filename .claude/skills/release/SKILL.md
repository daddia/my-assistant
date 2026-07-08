---
name: release
description: Release My Assistant — run gates, bump version, update changelog, commit, tag, and push. Use when asked to "release", "ship", "bump and push", or "cut a release".
---

# Release

End-to-end release workflow for My Assistant.

## Workflow

### 1. Pre-flight checks

Run all gates in parallel:

```bash
python3 scripts/validate.py
python3 scripts/validate_fixtures.py
```

Requires `pip install -r requirements.txt` if PyYAML is not already installed.

**Stop if any gate fails.** Fix issues before proceeding.

For minor or major releases, also run the connector smoke subset (`docs/guide/connector-smoke-tests.md`) and inbox smoke subset (`evals/README.md#smoke-subset`) before cutting the release.

### 2. Determine version bump

Read the current version from `.claude-plugin/plugin.json`. Ask the user which semver component to bump if not specified:

| Bump  | When                                                         |
|-------|--------------------------------------------------------------|
| patch | Bug fixes, test/fixture updates, docs                        |
| minor | New skills, commands, agents, or user-visible features     |
| major | Breaking changes to commands, skills, profile schema, or hooks |

Default to **patch** if the user says "release" without specifying.

### 3. Bump version

Update the `version` field in **both** manifest files — keep them in lockstep per `CONTRIBUTING.md`:

- `.claude-plugin/plugin.json`
- `.cursor-plugin/plugin.json`

These are the **only** version sources of truth. There is no `package.json` version to sync.

### 4. Update CHANGELOG

In `CHANGELOG.md`:

1. Confirm `[Unreleased]` accurately lists user-visible changes for this release.
2. Rename `[Unreleased]` to `[X.Y.Z] - YYYY-MM-DD` (today's date).
3. Add a fresh empty `[Unreleased]` section at the top with `### Added`, `### Changed`, and `### Fixed` subsections per existing style.

### 5. Stage, commit, tag, and push

```bash
git add -A
git commit -m "chore(release): bump plugin to <new-version>"
git tag v<new-version>
git push && git push --tags
```

Commit message style: match existing convention — `chore(release): bump plugin to X.Y.Z` or `chore(release): vX.Y.Z — <short summary>` (see `git log` for examples).

**Only commit when the user explicitly asks.** Privacy check: no real profiles, `.env`, or `*.local.md` in the commit.

If a hook fails, fix the issue and create a **new** commit (never amend).

## Version source of truth

`.claude-plugin/plugin.json` and `.cursor-plugin/plugin.json` — the `version` field in each (must match). There is no build step; this is a file-based plugin.

## Checklist (copy into your reasoning)

- [ ] `python3 scripts/validate.py` passes
- [ ] `python3 scripts/validate_fixtures.py` passes
- [ ] both `plugin.json` manifests bumped to the same version
- [ ] `CHANGELOG.md` updated
- [ ] commit includes all changes
- [ ] tag `v<version>` created
- [ ] pushed to main
