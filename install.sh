#!/usr/bin/env bash
#
# Claude Settings Installer
# Sets up Claude Code configuration on a new machine
#
# Usage:
#   ./install.sh           Install/update configuration
#   ./install.sh --verify  Check installation status
#   ./install.sh --backup  Create timestamped backup
#   ./install.sh --restore Restore from latest backup
#   ./install.sh --help    Show this help
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backups"
ENV_FILE="$CLAUDE_DIR/.env"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_err() { echo -e "${RED}[ERR]${NC} $1"; }
print_skip() { echo -e "${YELLOW}[SKIP]${NC} $1"; }

show_help() {
    echo "Claude Settings Installer"
    echo ""
    echo "Usage:"
    echo "  ./install.sh           Install/update configuration"
    echo "  ./install.sh --verify  Check installation status"
    echo "  ./install.sh --backup  Create timestamped backup"
    echo "  ./install.sh --restore Restore from latest backup"
    echo "  ./install.sh --help    Show this help"
    echo ""
    echo "For first-time setup, see SETUP.md for complete instructions."
}

check_dependencies() {
    local missing=()

    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi

    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi

    if ! command -v npx &> /dev/null; then
        missing+=("npx (Node.js)")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo ""
        print_warn "Missing dependencies: ${missing[*]}"
        echo ""
        echo "Install with:"
        for dep in "${missing[@]}"; do
            case "$dep" in
                jq)
                    echo "  Ubuntu/Debian: sudo apt install jq"
                    echo "  macOS: brew install jq"
                    ;;
                git)
                    echo "  Ubuntu/Debian: sudo apt install git"
                    echo "  macOS: brew install git"
                    ;;
                "npx (Node.js)")
                    echo "  Ubuntu/Debian: sudo apt install nodejs npm"
                    echo "  macOS: brew install node"
                    ;;
            esac
        done
        echo ""
        return 1
    fi
    return 0
}

create_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$BACKUP_DIR/$timestamp"

    mkdir -p "$backup_path"

    # Backup key files
    [[ -f "$CLAUDE_DIR/settings.json" ]] && cp "$CLAUDE_DIR/settings.json" "$backup_path/"
    [[ -f "$CLAUDE_DIR/settings.local.json" ]] && cp "$CLAUDE_DIR/settings.local.json" "$backup_path/"
    [[ -f "$CLAUDE_DIR/mcp.json" ]] && cp "$CLAUDE_DIR/mcp.json" "$backup_path/"
    [[ -f "$CLAUDE_DIR/CLAUDE.md" ]] && cp "$CLAUDE_DIR/CLAUDE.md" "$backup_path/"
    [[ -d "$CLAUDE_DIR/bin" ]] && cp -r "$CLAUDE_DIR/bin" "$backup_path/"

    # Backup custom plugins (not cache)
    if [[ -d "$CLAUDE_DIR/plugins/session-init" ]]; then
        mkdir -p "$backup_path/plugins"
        cp -r "$CLAUDE_DIR/plugins/session-init" "$backup_path/plugins/"
    fi
    if [[ -d "$CLAUDE_DIR/plugins/session-update" ]]; then
        mkdir -p "$backup_path/plugins"
        cp -r "$CLAUDE_DIR/plugins/session-update" "$backup_path/plugins/"
    fi

    print_ok "Backup created at: $backup_path"
    echo "$timestamp" > "$BACKUP_DIR/latest"
}

restore_backup() {
    if [[ ! -f "$BACKUP_DIR/latest" ]]; then
        print_err "No backup found to restore"
        return 1
    fi

    local latest=$(cat "$BACKUP_DIR/latest")
    local backup_path="$BACKUP_DIR/$latest"

    if [[ ! -d "$backup_path" ]]; then
        print_err "Backup directory not found: $backup_path"
        return 1
    fi

    echo "Restoring from backup: $latest"

    [[ -f "$backup_path/settings.json" ]] && cp "$backup_path/settings.json" "$CLAUDE_DIR/"
    [[ -f "$backup_path/settings.local.json" ]] && cp "$backup_path/settings.local.json" "$CLAUDE_DIR/"
    [[ -f "$backup_path/mcp.json" ]] && cp "$backup_path/mcp.json" "$CLAUDE_DIR/"
    [[ -f "$backup_path/CLAUDE.md" ]] && cp "$backup_path/CLAUDE.md" "$CLAUDE_DIR/"
    [[ -d "$backup_path/bin" ]] && cp -r "$backup_path/bin" "$CLAUDE_DIR/"
    [[ -d "$backup_path/plugins" ]] && cp -r "$backup_path/plugins/"* "$CLAUDE_DIR/plugins/"

    print_ok "Restored from backup: $latest"
}

verify_installation() {
    echo "Verifying Claude Code installation..."
    echo ""

    local all_ok=true

    # Check core files
    if [[ -f "$CLAUDE_DIR/settings.json" ]]; then
        print_ok "settings.json exists"
    else
        print_err "settings.json missing"
        all_ok=false
    fi

    if [[ -f "$CLAUDE_DIR/CLAUDE.md" ]]; then
        print_ok "CLAUDE.md exists"
    else
        print_err "CLAUDE.md missing"
        all_ok=false
    fi

    if [[ -x "$CLAUDE_DIR/bin/session" ]]; then
        print_ok "session CLI installed and executable"
    else
        print_err "session CLI missing or not executable"
        all_ok=false
    fi

    # Check plugins
    if [[ -d "$CLAUDE_DIR/plugins/session-init" ]]; then
        print_ok "session-init plugin installed"
    else
        print_warn "session-init plugin missing"
    fi

    if [[ -d "$CLAUDE_DIR/plugins/session-update" ]]; then
        print_ok "session-update plugin installed"
    else
        print_warn "session-update plugin missing"
    fi

    # Check MCP config
    if [[ -f "$CLAUDE_DIR/mcp.json" ]]; then
        print_ok "mcp.json exists"
        # Check for placeholder
        if grep -q '\${TAVILY_API_KEY}' "$CLAUDE_DIR/mcp.json" 2>/dev/null; then
            print_warn "mcp.json contains unsubstituted placeholders"
        fi
    else
        print_warn "mcp.json missing (MCP servers not configured)"
    fi

    # Check dependencies
    echo ""
    echo "Dependencies:"
    if command -v jq &> /dev/null; then
        print_ok "jq installed ($(jq --version))"
    else
        print_err "jq not installed"
        all_ok=false
    fi

    if command -v npx &> /dev/null; then
        print_ok "npx installed"
    else
        print_warn "npx not installed (needed for browsermcp)"
    fi

    # Check PATH
    echo ""
    if echo "$PATH" | grep -q "$CLAUDE_DIR/bin"; then
        print_ok "PATH includes ~/.claude/bin"
    else
        print_warn "PATH does not include ~/.claude/bin (run: source ~/.bashrc)"
    fi

    # Test session command
    if [[ -x "$CLAUDE_DIR/bin/session" ]]; then
        if "$CLAUDE_DIR/bin/session" show &>/dev/null; then
            print_ok "session command works"
        else
            print_warn "session command returned error (may be normal if no session active)"
        fi
    fi

    echo ""
    if $all_ok; then
        echo "Installation verified successfully!"
    else
        echo "Some issues found. Run ./install.sh to fix."
        return 1
    fi
}

setup_mcp() {
    echo ""
    echo "Setting up MCP servers..."

    # Check for env file with API keys
    if [[ -f "$ENV_FILE" ]]; then
        source "$ENV_FILE"
    fi

    # Try to extract existing Tavily API key from current configs
    if [[ -z "$TAVILY_API_KEY" ]]; then
        # Check ~/.claude/mcp.json
        if [[ -f "$CLAUDE_DIR/mcp.json" ]]; then
            TAVILY_API_KEY=$(grep -oP 'tavilyApiKey=\K[^"&]+' "$CLAUDE_DIR/mcp.json" 2>/dev/null || true)
        fi
        # Check ~/.mcp.json (global)
        if [[ -z "$TAVILY_API_KEY" && -f "$HOME/.mcp.json" ]]; then
            TAVILY_API_KEY=$(grep -oP 'tavilyApiKey=\K[^"&]+' "$HOME/.mcp.json" 2>/dev/null || true)
        fi
    fi

    # Prompt for Tavily API key if still not set
    if [[ -z "$TAVILY_API_KEY" ]]; then
        echo ""
        echo "Tavily API key not found."
        echo "Get one at: https://tavily.com (free tier available)"
        echo ""
        read -p "Enter Tavily API key (or press Enter to skip): " TAVILY_API_KEY

        if [[ -n "$TAVILY_API_KEY" ]]; then
            # Save to env file
            echo "TAVILY_API_KEY=$TAVILY_API_KEY" >> "$ENV_FILE"
            chmod 600 "$ENV_FILE"
            print_ok "Saved API key to $ENV_FILE"
        fi
    else
        print_ok "Found existing Tavily API key"
    fi

    # Generate mcp.json from template (always update to get latest server configs)
    if [[ -n "$TAVILY_API_KEY" ]]; then
        # Remove _comment field and substitute key
        sed "s/\${TAVILY_API_KEY}/$TAVILY_API_KEY/g" "$SCRIPT_DIR/mcp.json.template" | \
            grep -v "_comment" > "$CLAUDE_DIR/mcp.json"
        chmod 600 "$CLAUDE_DIR/mcp.json"
        print_ok "Updated mcp.json with Tavily configured"

        # Also update global ~/.mcp.json for compatibility
        cat > "$HOME/.mcp.json" << EOF
{
  "mcpServers": {
    "tavily": {
      "url": "https://mcp.tavily.com/mcp/?tavilyApiKey=$TAVILY_API_KEY"
    }
  }
}
EOF
        chmod 600 "$HOME/.mcp.json"
        print_ok "Updated global ~/.mcp.json"
    else
        if [[ ! -f "$CLAUDE_DIR/mcp.json" ]]; then
            # Copy template as-is (user can edit later)
            grep -v "_comment" "$SCRIPT_DIR/mcp.json.template" > "$CLAUDE_DIR/mcp.json"
            chmod 600 "$CLAUDE_DIR/mcp.json"
            print_warn "Created mcp.json template (edit to add API keys)"
        else
            print_skip "Keeping existing mcp.json"
        fi
    fi
}

install_plugins() {
    echo ""
    echo "Installing custom plugins..."

    mkdir -p "$CLAUDE_DIR/plugins"

    # Install session-init plugin
    if [[ -d "$SCRIPT_DIR/plugins/session-init" ]]; then
        rm -rf "$CLAUDE_DIR/plugins/session-init"
        cp -r "$SCRIPT_DIR/plugins/session-init" "$CLAUDE_DIR/plugins/"
        chmod +x "$CLAUDE_DIR/plugins/session-init/hooks-handlers/"*.sh 2>/dev/null || true
        print_ok "Installed session-init plugin"
    fi

    # Install session-update plugin
    if [[ -d "$SCRIPT_DIR/plugins/session-update" ]]; then
        rm -rf "$CLAUDE_DIR/plugins/session-update"
        cp -r "$SCRIPT_DIR/plugins/session-update" "$CLAUDE_DIR/plugins/"
        chmod +x "$CLAUDE_DIR/plugins/session-update/hooks-handlers/"*.sh 2>/dev/null || true
        print_ok "Installed session-update plugin"
    fi
}

add_to_path() {
    local rcfile="$1"
    local marker="# Claude Code session management"

    if [[ -f "$rcfile" ]]; then
        if grep -q "$marker" "$rcfile"; then
            print_skip "PATH already configured in $(basename "$rcfile")"
        else
            echo "" >> "$rcfile"
            echo "$marker" >> "$rcfile"
            echo 'export PATH="$HOME/.claude/bin:$PATH"' >> "$rcfile"
            print_ok "Added to PATH in $(basename "$rcfile")"
        fi
    fi
}

main_install() {
    echo "Installing Claude Code settings..."
    echo ""

    # Check dependencies first
    if ! check_dependencies; then
        echo ""
        read -p "Continue anyway? (y/N): " continue_anyway
        if [[ "$continue_anyway" != "y" && "$continue_anyway" != "Y" ]]; then
            exit 1
        fi
    fi

    # Create directories
    mkdir -p "$CLAUDE_DIR/bin"
    mkdir -p "$BACKUP_DIR"

    # Backup existing config
    if [[ -f "$CLAUDE_DIR/settings.json" ]]; then
        create_backup
        echo ""
    fi

    # Copy settings.json
    cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/settings.json"
    print_ok "Installed settings.json"

    # Copy session script
    cp "$SCRIPT_DIR/bin/session" "$CLAUDE_DIR/bin/session"
    chmod +x "$CLAUDE_DIR/bin/session"
    print_ok "Installed session CLI"

    # Copy CLAUDE.md
    cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    print_ok "Installed CLAUDE.md"

    # Install custom plugins
    install_plugins

    # Setup MCP config
    setup_mcp

    # Initialize sessions.md if it doesn't exist
    if [[ ! -f "$CLAUDE_DIR/sessions.md" ]]; then
        cat > "$CLAUDE_DIR/sessions.md" << 'EOF'
# Claude Session Index

| Context (Project/Branch) | Task ID | Status | Progress | Description | Started | Last Active | Agents |
|--------------------------|---------|--------|----------|-------------|---------|-------------|--------|
EOF
        print_ok "Created sessions.md"
    else
        print_skip "sessions.md already exists"
    fi

    # Add to PATH in shell RC
    if [[ -f "$HOME/.bashrc" ]]; then
        add_to_path "$HOME/.bashrc"
    fi

    if [[ -f "$HOME/.zshrc" ]]; then
        add_to_path "$HOME/.zshrc"
    fi

    echo ""
    echo "========================================="
    echo "Installation complete!"
    echo "========================================="
    echo ""
    echo "To activate, run:"
    echo "  source ~/.bashrc  (or ~/.zshrc)"
    echo ""
    echo "Then try:"
    echo "  session set 'Working on my feature'"
    echo "  session progress 50"
    echo "  session show"
    echo ""
    echo "Run './install.sh --verify' to check installation."
    echo "See SETUP.md for complete setup instructions."
    echo ""
}

# Parse arguments
case "${1:-}" in
    --help|-h)
        show_help
        ;;
    --verify)
        verify_installation
        ;;
    --backup)
        create_backup
        ;;
    --restore)
        restore_backup
        ;;
    *)
        main_install
        ;;
esac
