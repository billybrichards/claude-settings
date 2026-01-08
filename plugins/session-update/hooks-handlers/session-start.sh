#!/usr/bin/env bash

# Session Update Plugin - Session Start Handler
# Initializes the session update timer

CWD=$(pwd)
PROJECT_NAME=$(basename "$CWD")
GIT_BRANCH=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")

# Create state directory
STATE_DIR="$HOME/.claude/session-update-state"
mkdir -p "$STATE_DIR"

# Create context hash for this session
CONTEXT_HASH=$(echo -n "${CWD}:${GIT_BRANCH}" | md5sum | cut -c1-8)
TIMESTAMP_FILE="$STATE_DIR/last-update-${CONTEXT_HASH}"

# Initialize timestamp (mark as needing first update)
echo "0" > "$TIMESTAMP_FILE"

# Output hook response with instructions
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Session update tracking initialized for ${PROJECT_NAME}/${GIT_BRANCH}. Session status will auto-update every 10 minutes. You can also run /update-session manually. When updating, provide a 1-2 sentence summary of current work and run 'session set \"summary\"'."
  }
}
EOF

exit 0
