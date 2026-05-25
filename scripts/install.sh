#!/usr/bin/env bash
# Link shared skills into workspace(s) and create runtime directories.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_DEST="${HOME}/.claude-assistant/config"

link_skills() {
  local ws="$1"
  mkdir -p "${ws}/.claude/skills"
  for category in "${ROOT}/shared/skills"/*/; do
    [ -d "$category" ] || continue
    for skill_dir in "${category}"*/; do
      [ -d "$skill_dir" ] || continue
      name="$(basename "$skill_dir")"
      target="${ws}/.claude/skills/${name}"
      if [ ! -e "$target" ]; then
        ln -sf "${skill_dir%/}" "$target"
        echo "  linked ${name} → ${ws}/.claude/skills/"
      fi
    done
  done
}

create_runtime_dirs() {
  local ws="$1"
  mkdir -p "${ws}/inbox" \
           "${ws}/output/daily" \
           "${ws}/output/weekly" \
           "${ws}/output/drafts" \
           "${ws}/projects"
  touch "${ws}/MEMORY.md"
}

install_config_templates() {
  mkdir -p "$CONFIG_DEST"
  for f in "${ROOT}/config/"*.example.*; do
    [ -f "$f" ] || continue
    base="$(basename "$f")"
    dest_name="${base/.example/}"
    dest="${CONFIG_DEST}/${dest_name}"
    if [ ! -f "$dest" ]; then
      cp "$f" "$dest"
      echo "  copied ${base} → ${dest}"
    else
      echo "  skip ${dest_name} (already exists)"
    fi
  done
}

if [ "$#" -gt 0 ]; then
  WORKSPACES=("$@")
else
  WORKSPACES=()
  for ws in "${ROOT}"/workspaces/*/; do
    [ -d "$ws" ] || continue
    WORKSPACES+=("${ws%/}")
  done
fi

echo "→ Installing policy config templates to ${CONFIG_DEST}/"
install_config_templates

for ws in "${WORKSPACES[@]}"; do
  [ -d "$ws" ] || { echo "skip ${ws} (not a directory)"; continue; }
  echo "→ Workspace: ${ws}"
  link_skills "$ws"
  create_runtime_dirs "$ws"
done

echo "Done. Point Cowork at workspaces/<name>/"
