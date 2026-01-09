#!/usr/bin/env bash
#
# Claude Settings Sync Script
# Pulls latest settings and reinstalls
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo "Syncing Claude Code settings..."
echo ""

cd "$REPO_DIR"

# Check for uncommitted changes
if [[ -n "$(git status --porcelain)" ]]; then
    echo "Warning: You have uncommitted changes in claude-settings"
    echo ""
    git status --short
    echo ""
    read -p "Stash changes and continue? (y/N): " stash_changes
    if [[ "$stash_changes" == "y" || "$stash_changes" == "Y" ]]; then
        git stash
        echo "Changes stashed."
    else
        echo "Aborting sync."
        exit 1
    fi
fi

# Pull latest
echo "Pulling latest changes..."
git pull --ff-only

echo ""

# Run installer
./install.sh --backup
./install.sh

echo ""
echo "Sync complete!"
