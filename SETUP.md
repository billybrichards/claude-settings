# Claude Code Setup Guide

Complete instructions for setting up Claude Code on a new device.

## Quick Start (Existing Device Sync)

If you already have Claude Code configured elsewhere and just want to sync:

```bash
cd ~/claude-settings
git pull
./install.sh
source ~/.bashrc
```

## Fresh Device Setup

### 1. Prerequisites

Install required dependencies:

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install -y git jq nodejs npm
```

**macOS:**
```bash
brew install git jq node
```

**Verify installations:**
```bash
git --version
jq --version
npx --version
```

### 2. Install Claude Code CLI

Follow official instructions at: https://docs.anthropic.com/claude-code

```bash
# Typical installation (may vary)
npm install -g @anthropic/claude-code
```

### 3. Clone Settings Repository

```bash
git clone https://github.com/billybrichards/claude-settings.git ~/claude-settings
cd ~/claude-settings
```

### 4. Run Installer

```bash
./install.sh
```

The installer will:
- Copy settings.json, CLAUDE.md, and session CLI
- Install custom session tracking plugins
- Prompt for API keys (optional)
- Set up your shell PATH

### 5. Activate Shell Changes

```bash
source ~/.bashrc   # or source ~/.zshrc
```

### 6. Verify Installation

```bash
./install.sh --verify
```

### 7. Authenticate Claude Code

Run Claude Code and complete the OAuth flow:

```bash
claude
```

This creates `~/.claude/.credentials.json` with your auth tokens.

## API Keys Setup

### Tavily (Web Search)

1. Go to https://tavily.com
2. Create a free account
3. Get your API key from the dashboard
4. Either:
   - Enter when prompted during `./install.sh`, OR
   - Add to `~/.claude/.env`:
     ```
     TAVILY_API_KEY=tvly-your-key-here
     ```
   - Then run: `./install.sh` again

### Stripe (Optional)

1. Go to https://dashboard.stripe.com/apikeys
2. Create a restricted key or use test key
3. Run `claude` and use the Stripe plugin - it will prompt for OAuth

### GitHub (Optional)

1. Run `claude`
2. Use any GitHub command
3. Complete OAuth flow when prompted

### Asana (Optional)

1. Run `claude` in a project that needs Asana
2. Use Asana plugin commands
3. Complete OAuth flow when prompted

## Directory Structure

After installation, your `~/.claude/` directory will contain:

```
~/.claude/
├── settings.json           # Main configuration (synced)
├── settings.local.json     # Device-specific overrides (not synced)
├── mcp.json               # MCP server config with API keys
├── CLAUDE.md              # Instructions for Claude (synced)
├── .credentials.json      # OAuth tokens (auto-generated)
├── .env                   # API keys (not synced)
├── sessions.md            # Session tracking index
├── bin/
│   └── session            # Session CLI
├── plugins/
│   ├── session-init/      # Auto session init plugin
│   ├── session-update/    # Session tracking plugin
│   └── cache/             # Official plugin cache
└── backups/               # Config backups
```

## Cross-Device Sync Workflow

### Push Changes from Current Device

```bash
cd ~/claude-settings

# Make any changes to settings.json, CLAUDE.md, etc.

git add -A
git commit -m "Update settings"
git push
```

### Pull to Another Device

```bash
cd ~/claude-settings
git pull
./install.sh
```

### What Syncs vs What Doesn't

| Syncs via Git | Does NOT Sync |
|---------------|---------------|
| settings.json | .credentials.json |
| CLAUDE.md | mcp.json (contains API keys) |
| bin/session | .env (API keys) |
| plugins/session-* | sessions.md (local history) |
| | current-session-*.json |

## Troubleshooting

### "session: command not found"

```bash
# Add to PATH
export PATH="$HOME/.claude/bin:$PATH"

# Or reload shell config
source ~/.bashrc
```

### "jq: command not found"

```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq
```

### Plugins not loading

```bash
# Reinstall plugins
cd ~/claude-settings
./install.sh

# Check plugin installation
ls -la ~/.claude/plugins/
```

### MCP servers not connecting

1. Check mcp.json exists: `cat ~/.claude/mcp.json`
2. Verify API keys are set (not placeholders)
3. Test npx: `npx @browsermcp/mcp@latest --help`

### Session tracking not working

```bash
# Test directly
~/.claude/bin/session show

# Check jq is working
echo '{}' | jq .
```

## Backup & Restore

### Create Backup

```bash
cd ~/claude-settings
./install.sh --backup
```

Backups are stored in `~/.claude/backups/YYYYMMDD_HHMMSS/`

### Restore from Backup

```bash
./install.sh --restore
```

## Agent Monitor (Optional)

If you want the real-time session monitoring dashboard:

1. Clone the mcpbill project (contains Agent Monitor)
2. Follow its setup instructions
3. Launch: `./launch-agent-monitor.sh`
4. Access: http://localhost:8080/agents

## Getting Help

- Claude Code docs: https://docs.anthropic.com/claude-code
- Issues: https://github.com/anthropics/claude-code/issues
- This settings repo: https://github.com/billybrichards/claude-settings
