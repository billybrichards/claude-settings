#!/usr/bin/env bash
#
# Claude Plugin Cache Cleaner
# Removes old plugin cache entries to save space
#

CLAUDE_DIR="$HOME/.claude"
CACHE_DIR="$CLAUDE_DIR/plugins/cache"

if [[ ! -d "$CACHE_DIR" ]]; then
    echo "No cache directory found."
    exit 0
fi

echo "Claude Plugin Cache Cleaner"
echo ""

# Show current cache size
size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)
echo "Current cache size: $size"
echo ""

# Count items
count=$(find "$CACHE_DIR" -maxdepth 1 -type d | wc -l)
echo "Cache directories: $((count - 1))"
echo ""

read -p "Clear cache? (y/N): " clear_cache

if [[ "$clear_cache" == "y" || "$clear_cache" == "Y" ]]; then
    # Keep marketplace repos but clear downloaded plugins
    find "$CACHE_DIR" -maxdepth 2 -name ".git" -type d | while read gitdir; do
        echo "Keeping: $(dirname "$gitdir")"
    done

    # Remove non-git directories (downloaded/extracted plugins)
    find "$CACHE_DIR" -maxdepth 1 -type d ! -name "cache" | while read dir; do
        if [[ ! -d "$dir/.git" && "$dir" != "$CACHE_DIR" ]]; then
            echo "Removing: $dir"
            rm -rf "$dir"
        fi
    done

    new_size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)
    echo ""
    echo "New cache size: $new_size"
fi
