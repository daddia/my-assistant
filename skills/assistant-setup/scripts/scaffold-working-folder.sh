#!/usr/bin/env bash
# Create the canonical {assistantPath} directory tree per rules/paths.md.
# Idempotent — safe to re-run. Does not write profile, policies, or my-assistant.json.
#
# Usage:
#   scaffold-working-folder.sh <assistantPath>                    # directories only
#   scaffold-working-folder.sh <assistantPath> --tasks            # + TASKS.md
#   scaffold-working-folder.sh <assistantPath> --memory           # + memory/ tree + glossary
#   scaffold-working-folder.sh <assistantPath> --agents           # + AGENTS.md + CLAUDE.md shim
#   scaffold-working-folder.sh <assistantPath> --dashboard        # + dashboard.html (needs --plugin-root)
#   scaffold-working-folder.sh <assistantPath> --full --plugin-root <path>  # all of the above

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="${SCRIPT_DIR}/../assets"
TASKS_TEMPLATE="${ASSETS_DIR}/TASKS.template.md"
AGENTS_TEMPLATE="${ASSETS_DIR}/AGENTS.template.md"
CLAUDE_TEMPLATE="${ASSETS_DIR}/CLAUDE.template.md"
GLOSSARY_TEMPLATE="${ASSETS_DIR}/glossary.template.md"
CONTEXT_PERSONAL_TEMPLATE="${ASSETS_DIR}/context-personal.template.md"
CONTEXT_COMPANY_TEMPLATE="${ASSETS_DIR}/context-company.template.md"

usage() {
  cat <<'EOF'
Usage: scaffold-working-folder.sh <assistantPath> [options]

  <assistantPath>     Absolute path or ~ path to the working folder

Options:
  --tasks             Copy TASKS.template.md when TASKS.md is missing
  --memory            Create memory/{people,projects,context}/ and glossary.md
  --agents            Copy AGENTS.template.md and CLAUDE.template.md when missing
  --dashboard         Copy skills/dashboard.html when missing (requires --plugin-root)
  --full              --tasks --memory --agents --dashboard
  --plugin-root PATH  Plugin repo root (for --dashboard)

Creates: config/, policies/, memory/, drafts/, scheduled/, review-queue/
Does not write: profile.md, policies content, my-assistant.json, populated AGENTS.md
EOF
}

expand_path() {
  local path="$1"
  if [[ "$path" == "~" ]]; then
    echo "${HOME}"
  elif [[ "$path" == ~/* ]]; then
    echo "${HOME}/${path#~/}"
  else
    echo "$path"
  fi
}

copy_if_missing() {
  local src="$1"
  local dest="$2"
  local label="$3"
  if [[ ! -f "$src" ]]; then
    echo "scaffold-working-folder.sh: missing template: $src" >&2
    exit 1
  fi
  if [[ ! -f "$dest" ]]; then
    cp "$src" "$dest"
    echo "Created ${label}"
  fi
}

if [[ $# -lt 1 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

ASSISTANT_PATH="$(expand_path "$1")"
WITH_TASKS=0
WITH_MEMORY=0
WITH_AGENTS=0
WITH_DASHBOARD=0
PLUGIN_ROOT=""
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tasks)
      WITH_TASKS=1
      ;;
    --memory)
      WITH_MEMORY=1
      ;;
    --agents)
      WITH_AGENTS=1
      ;;
    --dashboard)
      WITH_DASHBOARD=1
      ;;
    --full)
      WITH_TASKS=1
      WITH_MEMORY=1
      WITH_AGENTS=1
      WITH_DASHBOARD=1
      ;;
    --plugin-root)
      if [[ $# -lt 2 ]]; then
        echo "scaffold-working-folder.sh: --plugin-root requires a path" >&2
        exit 1
      fi
      PLUGIN_ROOT="$(expand_path "$2")"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "scaffold-working-folder.sh: unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [[ -z "$ASSISTANT_PATH" ]]; then
  echo "scaffold-working-folder.sh: assistantPath is required" >&2
  exit 1
fi

if [[ "$ASSISTANT_PATH" != /* ]]; then
  echo "scaffold-working-folder.sh: path must be absolute or start with ~ (got: $ASSISTANT_PATH)" >&2
  exit 1
fi

if [[ "$WITH_DASHBOARD" -eq 1 && -z "$PLUGIN_ROOT" ]]; then
  echo "scaffold-working-folder.sh: --dashboard requires --plugin-root" >&2
  exit 1
fi

DIRS=(
  "${ASSISTANT_PATH}"
  "${ASSISTANT_PATH}/config"
  "${ASSISTANT_PATH}/policies"
  "${ASSISTANT_PATH}/memory"
  "${ASSISTANT_PATH}/memory/people"
  "${ASSISTANT_PATH}/memory/projects"
  "${ASSISTANT_PATH}/memory/context"
  "${ASSISTANT_PATH}/drafts"
  "${ASSISTANT_PATH}/scheduled"
  "${ASSISTANT_PATH}/review-queue"
)

for dir in "${DIRS[@]}"; do
  mkdir -p "$dir"
done

if [[ "$WITH_TASKS" -eq 1 ]]; then
  copy_if_missing "$TASKS_TEMPLATE" "${ASSISTANT_PATH}/TASKS.md" "${ASSISTANT_PATH}/TASKS.md"
fi

if [[ "$WITH_MEMORY" -eq 1 ]]; then
  copy_if_missing "$GLOSSARY_TEMPLATE" "${ASSISTANT_PATH}/memory/glossary.md" "${ASSISTANT_PATH}/memory/glossary.md"
  if [[ ! -f "${ASSISTANT_PATH}/memory/context/personal.md" && ! -f "${ASSISTANT_PATH}/memory/context/company.md" ]]; then
    copy_if_missing "$CONTEXT_PERSONAL_TEMPLATE" "${ASSISTANT_PATH}/memory/context/personal.md" "${ASSISTANT_PATH}/memory/context/personal.md"
  fi
fi

if [[ "$WITH_AGENTS" -eq 1 ]]; then
  copy_if_missing "$AGENTS_TEMPLATE" "${ASSISTANT_PATH}/AGENTS.md" "${ASSISTANT_PATH}/AGENTS.md"
  copy_if_missing "$CLAUDE_TEMPLATE" "${ASSISTANT_PATH}/CLAUDE.md" "${ASSISTANT_PATH}/CLAUDE.md"
fi

if [[ "$WITH_DASHBOARD" -eq 1 ]]; then
  DASHBOARD_SRC="${PLUGIN_ROOT}/skills/dashboard.html"
  DASHBOARD_DEST="${ASSISTANT_PATH}/dashboard.html"
  if [[ ! -f "$DASHBOARD_SRC" ]]; then
    echo "scaffold-working-folder.sh: dashboard not found at $DASHBOARD_SRC" >&2
    exit 1
  fi
  if [[ ! -f "$DASHBOARD_DEST" ]]; then
    cp "$DASHBOARD_SRC" "$DASHBOARD_DEST"
    echo "Created ${DASHBOARD_DEST}"
  fi
fi

echo "Scaffolded working folder: ${ASSISTANT_PATH}"
