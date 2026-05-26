# Contributing to the AI Assistant ADK

We deeply appreciate your interest in contributing to our repository! Whether you're reporting bugs, suggesting enhancements, improving docs, or submitting pull requests, your contributions help improve the project for everyone.

## Reporting Bugs

If you've encountered a bug in the project, we encourage you to report it to us. Please follow these steps:

1. **Check the Issue Tracker**: Before submitting a new bug report, please check our [issue tracker](https://github.com/daddia/my-assistant/issues) to see if the bug has already been reported. If it has, you can add to the existing report.
2. **Create a New Issue**: If the bug hasn't been reported, create a new issue. Provide a clear title and a detailed description of the bug. Include any relevant logs, error messages, and steps to reproduce the issue.
3. **Label Your Issue**: If possible, label your issue as a `bug` so it's easier for maintainers to identify.

When reporting issues with skills or workspace behavior, include which **provider** you used (e.g. Claude Cowork, Claude Code, Cursor) and the workspace path you pointed the agent at.

## Suggesting Enhancements

We're always looking for suggestions to make our project better. If you have an idea for an enhancement, please:

1. **Check the Issue Tracker**: Similar to bug reports, please check if someone else has already suggested the enhancement. If so, feel free to add your thoughts to the existing issue.
2. **Create a New Issue**: If your enhancement hasn't been suggested yet, create a new issue. Provide a detailed description of your suggested enhancement and how it would benefit the project.

Enhancements might include new skills, rules, workspace templates, provider-agnostic patterns, or documentation for building assistants on other platforms.

## Improving Documentation

Documentation is crucial for understanding and using our project effectively.
You can find the user guide under [`docs`](./docs/).

To fix smaller typos, you can edit the code directly in GitHub or use GitHub.dev (press `.` on a file in GitHub).

If you want to make larger changes, please check out the Code Contributions section below.

## Code Contributions

We welcome your contributions to our code and documentation. Here's how you can contribute:

### Environment Setup

AI Assistant ADK development is **file-based** — there is no build or package manager for the core repo. You need:

- **Git** — to clone, branch, and open pull requests
- **A text editor** — for Markdown, YAML, and skill files
- **An agent runtime (recommended)** — [Claude Cowork](https://claude.com/product/cowork), Claude Code, or Cursor, to exercise skills and workspaces the way users do

Optional: read [`AGENTS.md`](./AGENTS.md) (repo root) and [`docs/guide/00-introduction.md`](./docs/guide/00-introduction.md) before your first change.

### Setting Up the Repository Locally

To set up the repository on your local machine, follow these steps:

1. **Fork the Repository**: Make a copy of the repository to your GitHub account.
2. **Clone the Repository**: Clone your fork locally, e.g. `git clone https://github.com/<your-user>/my-assistant.git`
3. **Know the layout**:
   - `skills/assistant/` and `skills/productivity/` — canonical plugin skills (install, setup, tasks, memory, etc.)
   - `rules/` — shared behaviour referenced from workspace `CLAUDE.md` files
   - `workspaces/my-assistant/` — publishable template workspace (safe to commit; fictional or generic context only)
   - `workspaces/personal-assistant/` — **local only**; gitignored. Never commit real names, household details, or other private data.
   - `config/*.example.*` — example policy templates users copy locally
   - `docs/guide/` — end-user documentation

4. **Create a personal workspace (optional)**: To test install flows, copy the template and install skills as described in [`skills/assistant/skills/install/SKILL.md`](./skills/assistant/skills/install/SKILL.md), or run the README install prompt in Claude Code.

### Using Git Worktrees

If you work on multiple branches in parallel using [git worktrees](https://git-scm.com/docs/git-worktree), each worktree is a full clone of the repo. No extra setup script is required.

Remember that `workspaces/personal-assistant/` and local `config/` (without `.example` in the name) are gitignored in every worktree — your personal files stay on disk only in the worktree where you created them.

Tip: consider automating worktree creation with a shell alias that runs `git worktree add` and opens the new directory in your editor.

### Running the Examples

The reference workspace is [`workspaces/my-assistant/`](./workspaces/my-assistant/). Use it to validate changes before opening a PR:

1. **Point your agent at the template workspace** — In Claude Cowork: Settings → folder → select `workspaces/my-assistant/` (or your local copy of `personal-assistant` if you created one for testing).
2. **Run core commands** — e.g. `/setup`, `/start`, `/update` as documented in [`docs/guide/`](./docs/guide/).
3. **Test install/setup skills** — From repo root in Claude Code, follow or simulate the flow in [`skills/assistant/skills/install/SKILL.md`](./skills/assistant/skills/install/SKILL.md) when you change install or setup behaviour.

If you add a new skill under `skills/`, copy it into the template workspace under `workspaces/my-assistant/.claude/skills/<name>/` so the shipped example stays in sync (see Building Packages below).

### Local Development Workflow

#### Building Packages

There are no npm packages to build. The equivalent step is **syncing canonical skills into the publishable workspace template**.

When you change a skill in `skills/assistant/skills/` or `skills/productivity/skills/`, update the matching copy under:

```text
workspaces/my-assistant/.claude/skills/<skill-name>/SKILL.md
```

Setup sub-commands live under `skills/assistant/skills/setup/commands/` and `workspaces/my-assistant/.claude/skills/setup/commands/`. Keep those in sync as well.

If you change shared behaviour in `rules/`, ensure [`workspaces/my-assistant/CLAUDE.md`](./workspaces/my-assistant/CLAUDE.md) still references the right rule files.

#### Testing Packages

Validate changes in an agent session rather than a unit-test runner:

1. Open the workspace you updated (template or personal copy).
2. Trigger the skill via its slash command or a natural-language phrase that matches the skill `description` in the YAML frontmatter.
3. Confirm file outputs land in the expected paths (`context/`, `TASKS.md`, `memory/`, `output/`, etc.) and that the agent follows confirmation rules in [`rules/core-behavior.md`](./rules/core-behavior.md) and [`rules/file-safety.md`](./rules/file-safety.md).

For doc-only PRs, read the changed pages in preview and check links under `docs/`.

#### Adding package dependencies

This repo does not use `package.json` dependencies. When you add or extend functionality:

- **New skill** — Add `skills/<plugin>/skills/<name>/SKILL.md` with frontmatter (`name`, `description`), mirror it under `workspaces/my-assistant/.claude/skills/`, and document the command in the relevant plugin README and [`docs/guide/03-add-skills.md`](./docs/guide/03-add-skills.md) if user-facing.
- **New rule** — Add under `rules/` and reference it from workspace `CLAUDE.md` files as needed.
- **New config template** — Add `config/<name>.example.md` or `.yaml` with fictional data only; never commit real VIPs, API keys, or label IDs.
- **Connectors** — Prefer category-based wording (chat, email, calendar) per [`skills/productivity/CONNECTORS.md`](./skills/productivity/CONNECTORS.md) so skills stay provider-agnostic where possible.

### Submitting Pull Requests

We greatly appreciate your pull requests. Here are the steps to submit them:

1. **Create a New Branch**: Initiate your changes in a fresh branch. It's recommended to name the branch in a manner that signifies the changes you're implementing (e.g. `docs/readme-adk`, `feat/weekly-review-skill`).
2. **Privacy check**: Do not include `workspaces/personal-assistant/`, filled-in `config/` files, `.env`, or `*.local.md` in your commit. The template workspace must use generic or fictional content only.
3. **Changelog**: For user-visible changes, add a short entry under `[Unreleased]` or the next version in [`CHANGELOG.md`](./CHANGELOG.md).
4. **Commit Your Changes**: Ensure your commits are succinct and clear, detailing what modifications have been made and the reasons behind them. We don't require a specific commit message format, but please be descriptive.
5. **Push the Changes to Your GitHub Repository**: After committing your changes, push them to your fork.
6. **Open a Pull Request**: Propose your changes for review. Furnish a clear title and description of your contributions. Link any relevant issues your PR resolves. Suggested PR title prefixes:
   - `fix(docs): …` or `fix(skills): …`
   - `feat(skills): …` or `feat(workspace): …`
   - `chore: …`
7. **Respond to Feedback**: Stay receptive to and address any feedback or alteration requests from the project maintainers.

Thank you for contributing to the AI Assistant ADK! Your efforts help improve the project for everyone.

## Learn More

We have additional contributor documentation in the [contributing/](./contributing/) folder.
