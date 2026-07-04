#!/bin/bash
# =============================================================================
# Bash Aliases - Search & Text
# Shortcuts für Suche und Textvergleiche
# =============================================================================

# Diff Vergleiche
alias diff_files="diff --suppress-common-lines -y"
alias compare="sdiff"
alias patch_apply="patch"

# Text Suchen rekursiv
alias txt_search="grep -rnw . -e"
alias text_find="grep -ril"

# Suche ohne Binärdateien
alias clean_find="find . -type f ! -name '*.png' ! -name '*.jpg' ! -name '*.exe' ! -name '*.o'"


#!/bin/bash
# =============================================================================
# Search Functions
# Funktionen zum Suchen von Dateien und Inhalten
# =============================================================================

# Rekursive Textsuche in Dateien
function search() {
    if [ -z "$1" ]; then
        echo "usage: search <search_string>"
        return 1
    fi
    egrep -roi "$1" . 2>/dev/null | cut -d: -f2- | sort | uniq -c | sort -rn
}

# Suche nach Dateien nach Name (flexibel)
function findfile() {
    if [ -z "$1" ]; then
        echo "usage: findfile <filename_pattern>"
        return 1
    fi
    find . -type f -iname "*$1*" 2>/dev/null | head -30
}

# Finde große Dateien (> 100MB)
function findbig() {
    echo "🔍 Searching for files larger than 100MB..."
    find . -type f -size +100M -exec du -h {} \; | sort -hr | head -20
}

# Finde geänderte Dateien (letzte 7 Tage)
function findchanged() {
    find . -type f -mtime -7 -exec ls -lt {} \;
}

# Suche in Inhalten aller Konfigurationsdateien
function configsearch() {
    if [ -z "$1" ]; then
        echo "usage: configsearch <pattern>"
        return 1
    fi
    find /etc -type f \( -name "*.conf" -o -name "*.cfg" -o -name "*.ini" \) -exec grep -l "$1" {} \;
}
