# Claude Code Settings

Personal Claude Code configuration with session tracking, statusline customization, and plugin settings.

## Quick Setup

```bash
# Clone to home directory
git clone https://github.com/billyrichards/claude-settings.git ~/claude-settings

# Run the install script
cd ~/claude-settings
./install.sh
```

## What's Included

### Session Tracking System

Sessions are **automatically scoped to project + git branch**. No more manual session IDs needed!

```bash
# Initialize a session (in any project directory)
session set "Working on authentication"       # Description only
session set auth-impl "Implementing OAuth"    # Optional task ID + description

# Update progress (0-100)
session progress 50

# Change status
session status paused   # active, paused, blocked, complete, archived

# View current session
session show

# List all sessions across projects
session list

# Track agents in the session
session agent add abc123
```

### How Context Works

Sessions are automatically identified by:
- **Project**: Current directory name (e.g., `my-app`)
- **Git Branch**: Current branch (e.g., `main`, `feature/login`)
- **Task ID** (optional): Your custom identifier

Example contexts:
- `my-app/main` - Main branch of my-app
- `my-app/feature/login` - Feature branch
- `my-app/feature/login:auth-impl` - Feature branch with task ID

### Statusline

Custom statusline showing:
- `user@host` in green
- Current directory in blue
- Context + progress bar in yellow

Examples:
- `billyrichards@pc:/home/project [main ████░░ 50%]`
- `billyrichards@pc:/home/project [feature/auth:task-1 ██░░░░ 25%]`

### Status States

| Emoji | Status | Description |
|-------|--------|-------------|
| 🟢 | Active | Currently being worked on |
| 🟡 | Paused | Temporarily stopped |
| 🔴 | Blocked | Waiting on external dependency |
| ⚪ | Complete | Finished |
| 📦 | Archived | Closed/no longer needed |

## File Structure

```
~/.claude/
├── settings.json                    # Claude Code configuration
├── CLAUDE.md                        # Instructions for Claude about sessions
├── bin/
│   └── session                      # Session management CLI
├── sessions.md                      # Global session index (markdown table)
└── current-session-*.json           # Per-project/branch session state files
```

## Files Managed by This Repo

The install script creates/updates:

1. **`~/.claude/settings.json`** - Claude Code settings (plugins, statusline, etc.)
2. **`~/.claude/CLAUDE.md`** - Helps Claude understand the session system
3. **`~/.claude/bin/session`** - Session management CLI
4. **`~/.bashrc`** - Adds `~/.claude/bin` to PATH

## Manual Setup (Alternative)

If you prefer not to use the install script:

```bash
# 1. Copy settings and CLAUDE.md
cp settings.json CLAUDE.md ~/.claude/

# 2. Copy bin directory
mkdir -p ~/.claude/bin
cp bin/session ~/.claude/bin/
chmod +x ~/.claude/bin/session

# 3. Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$HOME/.claude/bin:$PATH"

# 4. Initialize session files
session show  # This creates the files if they don't exist
```

## Updating

```bash
cd ~/claude-settings
git pull
./install.sh
```

## Customization

### Edit Settings
Modify `settings.json` to change plugins, statusline format, etc.

### Edit Session Script
Modify `bin/session` to add custom commands or change behavior.

### Sync Between Machines
1. Make changes on one machine
2. Commit and push: `cd ~/claude-settings && git add -A && git commit -m "Update" && git push`
3. Pull on other machines: `cd ~/claude-settings && git pull && ./install.sh`

## Session Data

**Note:** Session data (`sessions.md`, `current-session-*.json`) is **not** tracked in this repo by default. Each machine maintains its own session history. If you want to sync sessions, you can add them:

```bash
cd ~/claude-settings
cp ~/.claude/sessions.md .
git add sessions.md
git commit -m "Add session data"
```

## Troubleshooting

### Session command not found
Make sure PATH is set up. Run:
```bash
source ~/.bashrc
```

### Statusline not showing session
Restart Claude Code or run a new terminal session.

### jq not installed
The session script requires `jq` for JSON parsing:
```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq
```

### Different sessions showing in different terminals
That's expected! Sessions are scoped by working directory + git branch. Each project/branch combination has its own session state.
