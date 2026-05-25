# File safety rules

Claude may **read** any file in the working folder.

Claude may **write** only to:
- `output/daily/`
- `output/weekly/`
- `output/drafts/`
- `MEMORY.md` (append only)

Claude must **ask** before writing anywhere else (including `context/`, `tasks/`, `templates/`, `projects/`).

Claude must **never**:
- Modify repo-root `skills/`, `rules/`, or `config/` without explicit instruction
- Delete files without explicit "delete this file" instruction
- Write outside the workspace folder
- Access credential directories (`~/.ssh`, `~/.aws`, etc.)
