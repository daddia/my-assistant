#!/usr/bin/env bash
# Create the canonical {assistantPath} directory tree per rules/paths.md.
# Idempotent — safe to re-run. Does not write profile, policies, or my-assistant.json.
#
# Usage:
#   scaffold-working-folder.sh <assistantPath>           # directories only (Step 0)
#   scaffold-working-folder.sh <assistantPath> --tasks   # also scaffold TASKS.md if missing

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="${SCRIPT_DIR}/../assets"
TASKS_TEMPLATE="${ASSETS_DIR}/TASKS.template.md"

usage() {
  cat <<'EOF'
Usage: scaffold-working-folder.sh <assistantPath> [--tasks]

  <assistantPath>  Absolute path or ~ path to the working folder
  --tasks          Copy assets/TASKS.template.md to TASKS.md when missing

Creates: config/, policies/, memory/, drafts/, scheduled/, review-queue/
Does not write: profile.md, policies content, my-assistant.json, AGENTS.md
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

if [[ $# -lt 1 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

ASSISTANT_PATH="$(expand_path "$1")"
WITH_TASKS=0
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tasks)
      WITH_TASKS=1
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

DIRS=(
  "${ASSISTANT_PATH}"
  "${ASSISTANT_PATH}/config"
  "${ASSISTANT_PATH}/policies"
  "${ASSISTANT_PATH}/memory"
  "${ASSISTANT_PATH}/drafts"
  "${ASSISTANT_PATH}/scheduled"
  "${ASSISTANT_PATH}/review-queue"
)

for dir in "${DIRS[@]}"; do
  mkdir -p "$dir"
done

if [[ "$WITH_TASKS" -eq 1 ]]; then
  if [[ ! -f "$TASKS_TEMPLATE" ]]; then
    echo "scaffold-working-folder.sh: missing template: $TASKS_TEMPLATE" >&2
    exit 1
  fi
  if [[ ! -f "${ASSISTANT_PATH}/TASKS.md" ]]; then
    cp "$TASKS_TEMPLATE" "${ASSISTANT_PATH}/TASKS.md"
    echo "Created ${ASSISTANT_PATH}/TASKS.md"
  fi
fi

echo "Scaffolded working folder: ${ASSISTANT_PATH}"
