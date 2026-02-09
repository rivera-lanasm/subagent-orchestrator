#!/bin/bash
# log-activity.sh
# PostToolUse hook: Append tool usage to activity log
#
# Receives JSON via stdin with tool_name and tool_input
# Appends entry to .agent/activity.log

set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

LOG_FILE=".agent/activity.log"

# Create log dir if needed
mkdir -p "$(dirname "$LOG_FILE")"

# Format log entry based on tool
case "$TOOL_NAME" in
  Edit|Write)
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // "unknown"')
    echo "$TIMESTAMP [$TOOL_NAME] $FILE_PATH" >> "$LOG_FILE"
    ;;
  Bash)
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // "unknown"')
    # Truncate long commands
    SHORT_CMD=$(echo "$COMMAND" | head -c 80)
    if echo "$COMMAND" | grep -qE "git commit"; then
      echo "$TIMESTAMP [COMMIT] $SHORT_CMD" >> "$LOG_FILE"
    else
      echo "$TIMESTAMP [BASH] $SHORT_CMD" >> "$LOG_FILE"
    fi
    ;;
  *)
    echo "$TIMESTAMP [$TOOL_NAME]" >> "$LOG_FILE"
    ;;
esac

exit 0
