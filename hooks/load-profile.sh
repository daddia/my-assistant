#!/usr/bin/env bash
# SessionStart: load the user's profile and policies if present.
# Resolution order: rules/paths.md

set -euo pipefail

WORKSPACE="${CLAUDE_PROJECT_DIR:-.}"
DEFAULT_ASSISTANT="${HOME}/MyAssistant"
LEGACY_CONFIG="${HOME}/.claude/plugins/config/my-assistant"

read_json_path() {
  local key="$1" file="$2"
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get(sys.argv[2], ''))" "$file" "$key" 2>/dev/null || true
  elif command -v jq >/dev/null 2>&1; then
    jq -r ".$key // empty" "$file" 2>/dev/null || true
  fi
}

find_config_json() {
  local candidates=(
    "${WORKSPACE}/config/my-assistant.json"
    "${DEFAULT_ASSISTANT}/config/my-assistant.json"
    "${LEGACY_CONFIG}/my-assistant.json"
  )
  for f in "${candidates[@]}"; do
    if [[ -f "$f" ]]; then
      echo "$f"
      return 0
    fi
  done
  return 1
}

load_policies() {
  local policies_dir="$1"
  if [[ ! -d "$policies_dir" ]]; then
    return 0
  fi
  local found=0
  shopt -s nullglob
  local files=("${policies_dir}"/*.policy.md)
  shopt -u nullglob
  if (( ${#files[@]} == 0 )); then
    return 0
  fi
  IFS=$'\n' files=($(printf '%s\n' "${files[@]}" | sort))
  for policy in "${files[@]}"; do
    if [[ -f "$policy" ]]; then
      if (( found == 0 )); then
        echo ""
        echo "---"
        echo ""
        found=1
      else
        echo ""
        echo "---"
        echo ""
      fi
      cat "$policy"
    fi
  done
}

try_load() {
  local config_path="$1"
  if [[ -n "$config_path" && -f "${config_path}/profile.md" ]]; then
    cat "${config_path}/profile.md"
    load_policies "${config_path}/policies"
    exit 0
  fi
}

CONFIG_JSON=""
if CONFIG_JSON="$(find_config_json)"; then
  CONFIG_PATH="$(read_json_path configPath "$CONFIG_JSON")"
  try_load "$CONFIG_PATH"
fi

PROFILE_CANDIDATES=(
  "${WORKSPACE}/config/profile.md"
  "${WORKSPACE}/profile.md"
  "${DEFAULT_ASSISTANT}/config/profile.md"
  "${LEGACY_CONFIG}/profile.md"
)

for profile in "${PROFILE_CANDIDATES[@]}"; do
  if [[ -f "$profile" ]]; then
    cat "$profile"
    config_dir="$(dirname "$profile")"
    load_policies "${config_dir}/policies"
    exit 0
  fi
done

echo "assistant: no profile found. Run /assistant:setup to create one at ~/MyAssistant/config/profile.md (or your chosen working folder). The plugin still works with pasted content."
