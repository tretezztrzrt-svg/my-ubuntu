#!/usr/bin/env bash
#
# treesize.sh – a TreeSize‑like disk usage viewer for Bash (Ubuntu)
# -----------------------------------------------------------------
# Low‑level comments inside – but you can ignore them, test the script,
# and I’ll improve it based on your feedback.

set -o pipefail   # preserve exit codes in pipelines
shopt -s extglob  # for extended pattern matching

# ----- colour definitions (ANSI) -----
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'   # No Color

# ----- default settings -----
MAX_DEPTH=9999         # unlimited by default
SORT_LEVELS=false      # sort children by size (desc)
TARGET_DIR="${PWD}"    # default: current directory

# ----- helper functions -----
usage() {
    cat <<EOF
Usage: $0 [-d depth] [-s] [directory]

Options:
  -d depth   Maximum recursion depth (default: unlimited)
  -s         Sort children by size (largest first) at each level
  -h         Show this help

If no directory is given, the current directory is scanned.
EOF
    exit 0
}

# parse command line
while getopts "d:sh" opt; do
    case "$opt" in
        d) MAX_DEPTH="$OPTARG" ;;
        s) SORT_LEVELS=true ;;
        h) usage ;;
        *) usage ;;
    esac
done
shift $((OPTIND-1))
[ -n "$1" ] && TARGET_DIR="$1"

# ----- sanity checks -----
if ! command -v du &>/dev/null; then
    echo -e "${RED}Error: 'du' not found.${NC}" >&2
    exit 1
fi
if ! command -v numfmt &>/dev/null; then
    echo -e "${RED}Error: 'numfmt' not found (install coreutils).${NC}" >&2
    exit 1
fi
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: '$TARGET_DIR' is not a directory.${NC}" >&2
    exit 1
fi

# ----- spinner (eye candy while scanning) -----
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while ps -p "$pid" >/dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "      \b\b\b\b\b\b"   # clear spinner
}

# ----- scan directory: collect all sizes (parallel sub‑shell) -----
scan_dir() {
    local dir="$1"
    # use du to get size in bytes for all items in dir (excluding '.' and '..')
    # we use -b for bytes, -0 to handle spaces, and we skip the total line.
    du -sb0 "$dir"/* 2>/dev/null | while IFS= read -r -d '' line; do
        # line format: size<tab>path
        size="${line%%$'\t'*}"
        path="${line#*$'\t'}"
        # output: size path
        printf "%s\t%s\n" "$size" "$path"
    done
}

# ----- recursive tree printer -----
print_tree() {
    local dir="$1"
    local depth="$2"
    local indent="$3"

    # if depth limit reached, stop recursion
    if [ "$depth" -ge "$MAX_DEPTH" ]; then
        return
    fi

    # get all items (files + dirs) with their sizes
    local items=()
    while IFS=$'\t' read -r size path; do
        items+=("$size" "$path")
    done < <(scan_dir "$dir")

    # if no items, skip
    [ ${#items[@]} -eq 0 ] && return

    # sort items by size descending if requested
    if $SORT_LEVELS; then
        # build a sorted list: we need to sort numerically by first field
        # we'll combine size and path with a delimiter, sort, then split
        local sorted=()
        for ((i=0; i<${#items[@]}; i+=2)); do
            printf "%020d\t%s\n" "${items[i]}" "${items[i+1]}"
        done | sort -nr | while IFS=$'\t' read -r size path; do
            # remove leading zeros from size
            size=$((10#$size))
            sorted+=("$size" "$path")
        done
        # replace items with sorted
        items=("${sorted[@]}")
    fi

    # iterate over all items
    for ((i=0; i<${#items[@]}; i+=2)); do
        local size="${items[i]}"
        local path="${items[i+1]}"
        local name="${path##*/}"          # basename

        # colour based on size (eye candy)
        local colour="$GREEN"
        if [ "$size" -gt 1073741824 ]; then   # > 1 GiB
            colour="$RED"
        elif [ "$size" -gt 104857600 ]; then  # > 100 MiB
            colour="$YELLOW"
        fi

        # human‑readable size (using numfmt)
        local hr_size
        hr_size=$(numfmt --to=iec --suffix=B "$size" 2>/dev/null || echo "$size")

        # print the line with indentation and colour
        printf "%s${colour}%s${NC}  %s\n" "$indent" "$hr_size" "$name"

        # if it's a directory, recurse into it
        if [ -d "$path" ]; then
            local new_indent="${indent}  "   # two spaces per level
            print_tree "$path" $((depth+1)) "$new_indent"
        fi
    done
}

# ----- main execution -----
echo -e "${BOLD}${BLUE}TreeSize for Bash${NC}"
echo "Scanning: $TARGET_DIR"
echo "Depth limit: $MAX_DEPTH"
echo "Sort levels: $SORT_LEVELS"
echo "----------------------------------------"

# get total size of target dir (background for spinner)
(
    total_size=$(du -sb "$TARGET_DIR" 2>/dev/null | cut -f1)
    echo "$total_size" > /tmp/treesize_total.$$  # temp file for parent
) &
spinner $!

# read total size from temp file
total_size=$(cat /tmp/treesize_total.$$ 2>/dev/null || echo 0)
rm -f /tmp/treesize_total.$$ 2>/dev/null

hr_total=$(numfmt --to=iec --suffix=B "$total_size" 2>/dev/null || echo "$total_size")
echo -e "${BOLD}Total size: ${CYAN}${hr_total}${NC}"

# print the tree (starting at depth 0, no indent)
print_tree "$TARGET_DIR" 0 ""

echo "----------------------------------------"
echo -e "${BOLD}${BLUE}Done.${NC}"
