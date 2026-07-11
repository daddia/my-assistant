#!/usr/bin/env bash
# SessionStart: load the user's profile if present.
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

CONFIG_JSON=""
if CONFIG_JSON="$(find_config_json)"; then
  CONFIG_PATH="$(read_json_path configPath "$CONFIG_JSON")"
  if [[ -n "$CONFIG_PATH" && -f "${CONFIG_PATH}/profile.md" ]]; then
    cat "${CONFIG_PATH}/profile.md"
    exit 0
  fi
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
    exit 0
  fi
done

echo "assistant: no profile found. Run /assistant:setup to create one at ~/MyAssistant/config/profile.md (or your chosen working folder). The plugin still works with pasted content."
