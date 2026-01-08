#!/usr/bin/env bash

# Session Update Plugin - PostToolUse Handler
# Checks if 10 minutes have passed and prompts for session update

CWD=$(pwd)
PROJECT_NAME=$(basename "$CWD")
GIT_BRANCH=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")

# State directory and files
STATE_DIR="$HOME/.claude/session-update-state"
CONTEXT_HASH=$(echo -n "${CWD}:${GIT_BRANCH}" | md5sum | cut -c1-8)
TIMESTAMP_FILE="$STATE_DIR/last-update-${CONTEXT_HASH}"

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# Get current time
CURRENT_TIME=$(date +%s)

# Get last update time (default to 0 if file doesn't exist)
if [[ -f "$TIMESTAMP_FILE" ]]; then
    LAST_UPDATE=$(cat "$TIMESTAMP_FILE")
else
    LAST_UPDATE=0
fi

# Calculate time since last update (10 minutes = 600 seconds)
TIME_DIFF=$((CURRENT_TIME - LAST_UPDATE))
UPDATE_INTERVAL=600

if [[ $TIME_DIFF -ge $UPDATE_INTERVAL ]]; then
    # Update the timestamp file
    echo "$CURRENT_TIME" > "$TIMESTAMP_FILE"

    # Calculate minutes since last update
    MINUTES=$((TIME_DIFF / 60))

    # Prompt Claude to update session with description AND progress
    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "SESSION UPDATE DUE (${MINUTES}+ minutes since last update): Please update the Agent Monitor with: 1) Run 'session set \"brief 1-2 sentence summary of current work\"' - focus on the goal, not details. 2) Run 'session progress <0-100>' to update the progress bar based on task completion (25%=planning done, 50%=core implementation, 75%=testing/polish, 100%=complete). Example: session set \"Building OAuth integration for user login\" then session progress 50"
  }
}
EOF
else
    # No update needed, return empty response
    cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": ""
  }
}
EOF
fi

exit 0
