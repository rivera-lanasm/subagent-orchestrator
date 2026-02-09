#!/bin/bash
# validate-commit-msg.sh
# PreToolUse hook: Enforce commit message prefixes
#
# Receives JSON via stdin with tool_input.command
# Exit 0 to allow, exit 2 to block
#
# Valid prefixes: wip:, checkpoint:, complete:

set -e

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Only check git commit commands
if ! echo "$COMMAND" | grep -qE "git commit"; then
  exit 0
fi

# Extract commit message (look for -m flag)
MSG=$(echo "$COMMAND" | grep -oP '(?<=-m\s*["\x27])[^"\x27]+' || true)

if [ -z "$MSG" ]; then
  # No -m flag found, might be using editor - allow
  exit 0
fi

# Check for valid prefix
if echo "$MSG" | grep -qE "^(wip|checkpoint|complete):"; then
  exit 0
fi

echo "Blocked: Commit message must start with wip:, checkpoint:, or complete:" >&2
echo "Got: $MSG" >&2
exit 2
