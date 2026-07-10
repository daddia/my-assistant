#!/usr/bin/env bash
# SessionStart: load the user's profile if present.
# Checks the default config path first, then profile.md in the open workspace (Cowork).

WORKSPACE_PROFILE="${CLAUDE_PROJECT_DIR:-.}/profile.md"
CONFIG_PROFILE="${HOME}/.claude/plugins/config/my-assistant/profile.md"

if [[ -f "$WORKSPACE_PROFILE" ]]; then
  cat "$WORKSPACE_PROFILE"
elif [[ -f "$CONFIG_PROFILE" ]]; then
  cat "$CONFIG_PROFILE"
else
  echo "assistant: no profile found at ~/.claude/plugins/config/my-assistant/profile.md or profile.md in your open workspace. Run /assistant:setup to create one. The plugin still works with pasted content."
fi
