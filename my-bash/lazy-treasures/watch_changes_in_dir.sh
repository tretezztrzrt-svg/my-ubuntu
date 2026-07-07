#!/bin/bash
# =============================================================================
# Development Helper Functions
# Funktionen zur Unterstützung bei der Entwicklung
# =============================================================================

# Watch directory for changes (requires entr or watchexec)
function watch_changes() {
    if command -v entr &> /dev/null; then
        find . -type f | entr -s "echo 'Change detected at'\`date\`"
    elif command -v watchexec &> /dev/null; then
        watchexec -w . "echo Change detected"
    else
        echo "Need to install entr or watchexec"
        return 1
    fi
}
