# daddia-assistant

A personal AI assistant built on Claude Cowork — pre-configured with skills, context, and sensible defaults so you can stop setting up and start getting things done.

---

## Paste this into Claude Code

```
Set up my personal assistant workspace from this repo:
https://github.com/daddia/assistant

Clone it, run the install script, and tell me:
- What workspaces are available
- What skills I have and what they do
- How to point Cowork at my workspace

What can you help me with once I'm set up?
```

Claude Code will clone the repo, wire up the skills, create the runtime folders, and walk you through the rest.

---

## What you get

Once set up, you have a workspace that knows how to:

| Skill | What it does |
|-------|-------------|
| `/standup` | Start a session — surfaces open loops and today's focus |
| `/done` | End a session — saves decisions and open loops to memory |
| `/weekly-review` | Friday review — wins, misses, next week's priorities |
| `/todo-add` | Capture a task or reminder |
| `/todo-review` | Review and clear your open tasks |

Skills are Markdown files. You can read them, edit them, and add your own. No code required.

---

## How it works

**One repo. Multiple assistants.**

Each workspace is a folder you point Cowork at. They share the same skills and templates but have separate identity files — so your personal assistant knows your family and your cooking habits, while a work assistant knows your colleagues and projects.

```
workspaces/
  example/            ← explore this first (fictional persona, safe to poke around)
  personal-assistant/ ← yours (stays on your machine, never committed)
```

**Claude only writes to `output/`.** Context files, tasks, and templates are read-only by default. This is baked into the shared rules — you don't have to think about it.

**Memory persists.** The `/done` skill appends session notes to `MEMORY.md`. The `/standup` skill reads it at the start of the next session. Nothing gets lost between conversations.

---

## Manual setup (if you prefer)

If you'd rather do it yourself:

1. **Clone the repo**

   ```bash
   git clone https://github.com/daddia/assistant ~/assistant
   cd ~/assistant
   ```

2. **Run the install script**

   macOS / Linux:
   ```bash
   ./install.sh
   ```

   Windows (PowerShell):
   ```powershell
   .\install.ps1
   ```

   This links the shared skills into each workspace and creates the runtime folders.

3. **Copy your workspace and fill it in**

   ```bash
   # macOS / Linux
   cp -R workspaces/example workspaces/my-assistant
   ./install.sh workspaces/my-assistant

   # Windows
   Copy-Item -Recurse workspaces\example workspaces\my-assistant
   .\install.ps1 workspaces\my-assistant
   ```

   Edit the three files in `workspaces/my-assistant/context/`:
   - `about-me.md` — who you are, what you want help with
   - `rules.md` — what Claude can and can't do on your behalf
   - `style.md` — how you write; Claude will match it

4. **Paste the Global Instructions into Cowork**

   Settings → Cowork → Global Instructions → paste from [docs/product/spec.md](docs/product/spec.md#global-instructions).

5. **Point Cowork at your workspace**

   Open Cowork, select folder → `workspaces/my-assistant/`

6. **Say hello**

   Run `/standup` to let Claude read your context and tell you what it can do.

---

## Adding connectors (optional)

Skills like `/morning-brief` and `/triage-inbox` need Gmail and Google Calendar connected. Connect them in **Settings → Cowork → Connectors**, then copy the policy templates:

```bash
cp config/email-policy.example.md ~/.claude-assistant/config/email-policy.md
cp config/triage-config.example.md ~/.claude-assistant/config/triage-config.md
cp config/calendar-policy.example.md ~/.claude-assistant/config/calendar-policy.md
```

Open each file and replace the placeholders with your own VIPs, label IDs, and working hours.

---

## Privacy

Your `workspaces/personal-assistant/` folder never gets committed — it's excluded by `.gitignore`. Only the fictional `workspaces/example/` workspace ships with the repo. Fill in your real context locally and it stays on your machine.

---

## Read the docs

[docs](./docs)

## Licence

MIT Licence. Copyright (c) 2026 daddia.
