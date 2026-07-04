#!/bin/bash
# =============================================================================
# Cleanup & Maintenance Functions
# Funktionen zur Systemverwaltung und Aufräumen
# =============================================================================

# Clean apt cache thoroughly
function apt_deep_clean() {
    echo "🧽 Deep cleaning APT packages..."
    sudo apt autoremove -y
    sudo apt autoclean
    sudo apt clean
    echo "✅ APT cleanup complete"
}

# Remove orphaned kernels (USE WITH CAUTION)
function clean_kernels() {
    echo "⚠️ This will list older kernels but NOT auto-remove them for safety."
    echo "Current running kernel: $(uname -r)"
    echo "Installed kernels:"
    dpkg --list 'linux-image-*' | grep '^ii' | awk '{print $2, $3}'
    echo ""
    echo "To manually remove old ones use: sudo apt remove linux-image-<version>"
}

# Thumbs.db and OS junk removal
function cleanup_junk() {
    echo "🗑️ Removing common junk files..."
    find . -name "Thumbs.db" -delete
    find . -name ".DS_Store" -delete
    find . -name "*.pyc" -delete
    find . -name "__pycache__" -type d -exec rm -rf {} +
    find . -name "*.swp" -delete
    find . -name "*~" -delete
    echo "✅ Junk cleanup complete"
}

# Trash emptied safely (alternative to rm)
function trash_delete() {
    if command -v trash-put &> /dev/null; then
        trash-put "$@"
        echo "✅ Moved to trash: $@"
    else
        echo "Install trash-cli: sudo apt install trash-cli"
        return 1
    fi
}
