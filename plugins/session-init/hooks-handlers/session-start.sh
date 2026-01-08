#!/usr/bin/env bash

# Session Init Hook for Agent Monitor
# Checks if a session exists and creates one if missing

# Get current working directory and branch
CWD=$(pwd)
PROJECT_NAME=$(basename "$CWD")
GIT_BRANCH=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# Path to session command
SESSION_CMD="$HOME/claude-settings/bin/session"

# Check if session command exists
if [[ ! -x "$SESSION_CMD" ]]; then
    # Fallback - just output success without session check
    cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Session tracking available. Run 'session set \"task description\"' to register in Agent Monitor."
  }
}
EOF
    exit 0
fi

# Check if session already exists for this context
SESSION_OUTPUT=$("$SESSION_CMD" show 2>&1)

if echo "$SESSION_OUTPUT" | grep -q "No active session"; then
    # No session exists - AUTO-CREATE one with default description
    # Claude will update it with a better description after asking the user
    "$SESSION_CMD" set "Development session in ${PROJECT_NAME}" 2>/dev/null

    # Inject instructions for Claude to get a proper description
    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "SESSION INITIALIZED: Auto-created session for ${PROJECT_NAME}/${GIT_BRANCH}. Please ask the user what they're working on and update with 'session set \"their task description\"' for better Agent Monitor visibility. Also set initial progress with 'session progress 10' if just starting."
  }
}
EOF
else
    # Session already exists - remind Claude to update progress
    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Session active for ${PROJECT_NAME}/${GIT_BRANCH}. Remember to update description with 'session set \"current task\"' and progress with 'session progress <0-100>' at milestones."
  }
}
EOF
fi

exit 0
