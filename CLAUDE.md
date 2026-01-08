# Claude Code Session Tracking System

## Overview

This workspace uses a custom session tracking system. Sessions are **automatically scoped to project + git branch**, so different projects and branches have independent session states.

## How Context Works

Sessions are identified by:
- **Project**: Current directory name
- **Git Branch**: Current git branch (if in a git repo)
- **Task ID** (optional): User-defined identifier

Example: In `/home/user/my-app` on branch `feature/login`, the context is `my-app/feature/login`.

## Session Commands

```bash
session set [task-id] [description]     # Initialize/update session
session status <state>                  # Update status
session progress <0-100>                # Update progress percentage
session agent add <agent-id>            # Track an agent
session agent remove <agent-id>         # Remove agent tracking
session show                            # Show current session
session list                            # Show all sessions (markdown table)
session clear                           # Clear current session
session help                            # Show help
```

## Usage Guidelines for Claude

### At Session Start
1. Run `session show` to check if a session exists for current context
2. If no session exists, ask the user what they're working on
3. Run `session set "Description of work"` to initialize

### During Work
- Update progress with `session progress <0-100>` at milestones:
  - 25% - Planning/research complete
  - 50% - Core implementation done
  - 75% - Testing/polish
  - 100% - Complete

### When Spawning Agents
Track them with `session agent add <agent-id>` so user sees agent counts in the session table.

### Status Changes
Update status when appropriate:
- `session status paused` - User stepping away
- `session status blocked` - Waiting on external dependency
- `session status complete` - Task finished

## Status States

| Status | Emoji | When to Use |
|--------|-------|-------------|
| active | 🟢 | Currently working |
| paused | 🟡 | Temporarily stopped |
| blocked | 🔴 | Waiting on dependency |
| complete | ⚪ | Done |
| archived | 📦 | No longer relevant |

## Session Data Files

- `~/.claude/sessions.md` - Global index of all sessions (markdown table)
- `~/.claude/current-session-*.json` - Per-context session state (one file per project/branch)

## Statusline

The Claude Code statusline shows the current context and progress:
```
user@host:/path [branch ████░░ 50%]
user@host:/path [branch:task-id ██░░░░ 25%]
```

## Example Workflow

```bash
# User starts working in my-app on feature/auth branch
cd ~/my-app
git checkout feature/auth

# Initialize session
session set "Implementing OAuth login"

# As work progresses
session progress 25   # Planning done
session progress 50   # Core implementation
session progress 75   # Tests written
session progress 100  # Complete
session status complete
```
