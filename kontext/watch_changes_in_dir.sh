#!/bin/bash
# =============================================================================
#~/.local/share/nautilus/scripts/watch-folder

# Parameter: $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS enthält den ausgewählten Ordner
FOLDER="${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS}"

if [ -z "$FOLDER" ]; then
    FOLDER="$(pwd)"
fi

if command -v entr &> /dev/null; then
    find "$FOLDER" -type f | entr -s "echo 'Change detected at'\`date\`"
elif command -v watchexec &> /dev/null; then
    watchexec -w "$FOLDER" "echo Change detected"
else
    notify-send "Error" "Need to install entr or watchexec"
    exit 1
fi
