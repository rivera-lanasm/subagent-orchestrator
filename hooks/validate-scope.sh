#!/bin/bash
# validate-scope.sh
# PreToolUse hook: Block writes outside agent's designated scope
#
# Receives JSON via stdin with tool_input containing file path
# Exit 0 to allow, exit 2 to block
#
# TODO: Scope should be defined in .agent/config.yaml

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# TODO: Check against allowed scope in .agent/config.yaml
# For now, just block writes to .git/
if echo "$FILE_PATH" | grep -q "^\.git/"; then
  echo "Blocked: Cannot modify .git directory" >&2
  exit 2
fi

exit 0
