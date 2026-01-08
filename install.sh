#!/usr/bin/env bash
#
# Claude Settings Installer
# Sets up Claude Code configuration on a new machine
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing Claude Code settings..."
echo ""

# Create directories
mkdir -p "$CLAUDE_DIR/bin"

# Copy settings.json (backup existing if present)
if [[ -f "$CLAUDE_DIR/settings.json" ]]; then
    echo "Backing up existing settings.json to settings.json.bak"
    cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.bak"
fi
cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/settings.json"
echo "[OK] Installed settings.json"

# Copy session script
cp "$SCRIPT_DIR/bin/session" "$CLAUDE_DIR/bin/session"
chmod +x "$CLAUDE_DIR/bin/session"
echo "[OK] Installed session CLI"

# Copy CLAUDE.md (helps Claude understand the session system)
cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "[OK] Installed CLAUDE.md"

# Initialize sessions.md if it doesn't exist
if [[ ! -f "$CLAUDE_DIR/sessions.md" ]]; then
    cat > "$CLAUDE_DIR/sessions.md" << 'EOF'
# Claude Session Index

| Context (Project/Branch) | Task ID | Status | Progress | Description | Started | Last Active | Agents |
|--------------------------|---------|--------|----------|-------------|---------|-------------|--------|
EOF
    echo "[OK] Created sessions.md"
else
    echo "[SKIP] sessions.md already exists"
fi

# Note: current-session files are created per-project automatically

# Add to PATH in shell RC
add_to_path() {
    local rcfile="$1"
    local marker="# Claude Code session management"

    if [[ -f "$rcfile" ]]; then
        if grep -q "$marker" "$rcfile"; then
            echo "[SKIP] PATH already configured in $(basename "$rcfile")"
        else
            echo "" >> "$rcfile"
            echo "$marker" >> "$rcfile"
            echo 'export PATH="$HOME/.claude/bin:$PATH"' >> "$rcfile"
            echo "[OK] Added to PATH in $(basename "$rcfile")"
        fi
    fi
}

# Detect shell and update appropriate RC file
if [[ -f "$HOME/.bashrc" ]]; then
    add_to_path "$HOME/.bashrc"
fi

if [[ -f "$HOME/.zshrc" ]]; then
    add_to_path "$HOME/.zshrc"
fi

# Check for jq dependency
if ! command -v jq &> /dev/null; then
    echo ""
    echo "[WARN] jq is not installed. The session command requires jq."
    echo "       Install with: sudo apt install jq (Ubuntu) or brew install jq (macOS)"
fi

echo ""
echo "Installation complete!"
echo ""
echo "To activate, run:"
echo "  source ~/.bashrc  (or ~/.zshrc)"
echo ""
echo "Then try:"
echo "  session set 'Working on my feature'    # Description only"
echo "  session set task-123 'Fix the login'   # Task ID + description"
echo "  session progress 50                    # Update progress"
echo ""
echo "Sessions are automatically scoped to project + git branch!"
echo ""
