#!/bin/bash
# treesize.sh - Bash script like TreeSize Free: recursive dir sizes with tree view + eye-candy bars
# Usage: ./treesize.sh [directory] [max-depth]   (default: current dir, depth 3)
# Run: chmod +x treesize.sh && ./treesize.sh

set -euo pipefail

# Configurable
MAX_DEPTH=${2:-3}
TARGET_DIR="${1:-.}"
HUMAN_READABLE=true
SHOW_BARS=true
BAR_WIDTH=30
SORT_BY_SIZE=true

# Colors for eye-candy
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to format bytes to human readable
human() {
    local bytes=$1
    if [ "$HUMAN_READABLE" = false ]; then
        echo "$bytes"
        return
    fi
    if [ "$bytes" -ge 1073741824 ]; then
        echo "$(awk "BEGIN {printf \"%.1fG\", $bytes/1073741824}")"
    elif [ "$bytes" -ge 1048576 ]; then
        echo "$(awk "BEGIN {printf \"%.1fM\", $bytes/1048576}")"
    elif [ "$bytes" -ge 1024 ]; then
        echo "$(awk "BEGIN {printf \"%.1fK\", $bytes/1024}")"
    else
        echo "${bytes}B"
    fi
}

# Function to create progress bar (eye-candy)
progress_bar() {
    local percent=$1
    local filled=$(( (percent * BAR_WIDTH) / 100 ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=filled; i<BAR_WIDTH; i++)); do bar+="░"; done
    echo -e "${YELLOW}[${bar}]${NC} ${percent}%"
}

# Recursive tree printer
print_tree() {
    local dir="$1"
    local prefix="$2"
    local depth=$3
    local total_size=0

    if [ "$depth" -gt "$MAX_DEPTH" ]; then
        return
    fi

    # Get immediate subdirs and their sizes (du is efficient)
    local items=()
    while IFS= read -r line; do
        items+=("$line")
    done < <(du -s --bytes "$dir"/* 2>/dev/null | sort -nr)  # sort by size desc

    local count=${#items[@]}
    local idx=0

    for item in "${items[@]}"; do
        idx=$((idx + 1))
        local size=$(echo "$item" | awk '{print $1}')
        local path=$(echo "$item" | awk '{for(i=2;i<=NF;i++) printf "%s ", $i; print ""}' | xargs)
        local name=$(basename "$path")
        local is_last=$((idx == count))
        local connector=$([ "$is_last" = true ] && echo "└──" || echo "├──")
        local sub_prefix=$([ "$is_last" = true ] && echo "${prefix}    " || echo "${prefix}│   ")

        total_size=$((total_size + size))

        # Print line with eye-candy
        local hsize=$(human "$size")
        printf "${prefix}%s ${BLUE}%s${NC}  ${GREEN}%s${NC}  " "$connector" "$name" "$hsize"

        if [ "$SHOW_BARS" = true ] && [ "$total_size" -gt 0 ]; then  # rough % based on siblings (not perfect)
            local rough_pct=$(( (size * 100) / (total_size + 1) ))  # avoid div0
            if [ "$rough_pct" -gt 100 ]; then rough_pct=100; fi
            progress_bar "$rough_pct"
        else
            echo
        fi

        # Recurse into directories
        if [ -d "$path" ] && [ "$depth" -lt "$MAX_DEPTH" ]; then
            print_tree "$path" "$sub_prefix" $((depth + 1))
        fi
    done

    # Print total for this level (optional)
    if [ "$depth" -eq 1 ]; then
        echo -e "${prefix}${GREEN}Total: $(human "$total_size")${NC}"
    fi
}

# Main
echo -e "${YELLOW}=== TreeSize Bash - Scanning $TARGET_DIR (depth $MAX_DEPTH) ===${NC}"
echo -e "${BLUE}Root: $(basename "$(realpath "$TARGET_DIR")")${NC}\n"

# Root size
root_size=$(du -sb "$TARGET_DIR" 2>/dev/null | cut -f1)
echo -e "Root size: ${GREEN}$(human "$root_size")${NC}\n"

print_tree "$TARGET_DIR" "" 1

echo -e "\n${YELLOW}Done. For interactive explorer, install ncdu: sudo apt install ncdu${NC}"
