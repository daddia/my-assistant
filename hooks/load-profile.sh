#!/usr/bin/env bash
# SessionStart: load the user's profile if present.
# Checks the default config path first, then profile.md in the open workspace (Cowork).

CONFIG_PROFILE="${HOME}/.claude/plugins/config/my-assistant/profile.md"
WORKSPACE_PROFILE="./profile.md"

if [[ -f "$CONFIG_PROFILE" ]]; then
  cat "$CONFIG_PROFILE"
elif [[ -f "$WORKSPACE_PROFILE" ]]; then
  cat "$WORKSPACE_PROFILE"
else
  echo "assistant: no profile found at ~/.claude/plugins/config/my-assistant/profile.md or profile.md in your open workspace. Run /assistant:setup to create one. The plugin still works with pasted content."
fi
