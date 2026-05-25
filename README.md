# Claude Cowork Multi-Agent Workspace

Version-controlled layout for running multiple **Claude Cowork** assistants from one repo — shared skills, rules, and templates; separate workspaces for personal, work, or demo use.

## Quick start

```bash
git clone <repo-url> assistant && cd assistant
chmod +x scripts/install.sh
./scripts/install.sh workspaces/example
```

1. Paste [Global Instructions](docs/product/spec.md#global-instructions) into **Settings → Cowork → Global Instructions**.
2. In Cowork, open folder `workspaces/example/`.
3. Try `/standup` and `/weekly-review`.

## Your own workspace

```bash
cp -R workspaces/example workspaces/personal-assistant   # or any name
# Edit workspaces/personal-assistant/context/ with your files (kept local via .gitignore)
./scripts/install.sh workspaces/personal-assistant
```

Point Cowork at `workspaces/personal-assistant/`. That folder is **not** committed — only `workspaces/example/` ships in the public repo.

## Documentation

| Doc | Purpose |
|-----|---------|
| [spec.md](docs/product/spec.md) | Canonical structure, formats, privacy rules |
| [research.md](docs/product/research.md) | Practitioner guide and Cowork constraints |

## Layout

```
shared/          skills, rules, templates (public)
config/          *.example.* policy templates (public)
workspaces/
  example/       fictional demo workspace (public)
  */             your real workspaces (local, gitignored)
scripts/         install.sh — link skills, create runtime dirs
```

## Privacy

Nothing in `shared/`, `config/*.example`, or `workspaces/example/` should contain real names, contacts, or private data. See [Publication and privacy](docs/product/spec.md#publication-and-privacy) in the spec.
