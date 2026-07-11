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

resolve_policies_dir() {
  local policies_path="${1:-}"
  local assistant_path="$2"
  local config_path="${3:-}"

  if [[ -n "$policies_path" && -d "$policies_path" ]]; then
    echo "$policies_path"
    return 0
  fi
  if [[ -d "${assistant_path}/policies" ]]; then
    echo "${assistant_path}/policies"
    return 0
  fi
  # Legacy: policies under config/ before path fix
  if [[ -n "$config_path" && -d "${config_path}/policies" ]]; then
    echo "${config_path}/policies"
    return 0
  fi
  if [[ -n "$policies_path" ]]; then
    echo "$policies_path"
    return 0
  fi
  echo "${assistant_path}/policies"
}

try_load() {
  local config_path="$1"
  local assistant_path="$2"
  local policies_path="${3:-}"
  if [[ -n "$config_path" && -f "${config_path}/profile.md" ]]; then
    cat "${config_path}/profile.md"
    load_policies "$(resolve_policies_dir "$policies_path" "$assistant_path" "$config_path")"
    exit 0
  fi
}

CONFIG_JSON=""
if CONFIG_JSON="$(find_config_json)"; then
  CONFIG_PATH="$(read_json_path configPath "$CONFIG_JSON")"
  ASSISTANT_PATH="$(read_json_path assistantPath "$CONFIG_JSON")"
  POLICIES_PATH="$(read_json_path policiesPath "$CONFIG_JSON")"
  try_load "$CONFIG_PATH" "$ASSISTANT_PATH" "$POLICIES_PATH"
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
    if [[ "$(basename "$config_dir")" == "config" ]]; then
      assistant_path="$(dirname "$config_dir")"
    else
      assistant_path="$config_dir"
    fi
    load_policies "$(resolve_policies_dir "" "$assistant_path" "$config_dir")"
    exit 0
  fi
done

echo "assistant: no profile found. Run /assistant:setup to create one at ~/MyAssistant/config/profile.md (or your chosen working folder). The plugin still works with pasted content."
