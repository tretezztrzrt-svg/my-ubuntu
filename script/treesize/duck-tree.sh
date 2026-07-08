#!/usr/bin/env bash
# duck-tree.sh — TreeSize-ish overview (bash-only)

set -euo pipefail

START_DIR="${1:-$HOME}"
START_DIR="${START_DIR/#\~/$HOME}"

if [[ ! -d "$START_DIR" ]]; then
  echo "Start dir is not a directory: $START_DIR" >&2
  exit 1
fi

EXCLUDE_DIRS=(
  "$HOME/.cache"
  "/proc"
  "/sys"
  "/dev"
)

FIND_PRUNE=()
for ex in "${EXCLUDE_DIRS[@]}"; do
  FIND_PRUNE+=( -path "$ex" -prune -o )
done

# Terminal size (fixed)
if command -v tput >/dev/null 2>&1; then
  TERM_W="$(tput cols 2>/dev/null || echo 80)"
  TERM_H="$(tput lines 2>/dev/null || echo 24)"
else
  TERM_W=80
  TERM_H=24
fi

# Color helpers (fixed)
if [[ -t 1 ]]; then
  RED=$'\e[31m'; GRN=$'\e[32m'; YEL=$'\e[33m'; BLU=$'\e[34m'
  MAG=$'\e[35m'; CYN=$'\e[36m'; DIM=$'\e[2m'; BOLD=$'\e[1m'; RST=$'\e[0m'
else
  RED=""; GRN=""; YEL=""; BLU=""; MAG=""; CYN=""; DIM=""; BOLD=""; RST=""
fi

human() {
  awk -v b="$1" '
    BEGIN{
      if (b < 1024) { print b " B"; exit }
      units[0]="B"; units[1]="KiB"; units[2]="MiB"; units[3]="GiB"; units[4]="TiB"; units[5]="PiB"
      u=0; v=b
      while (v>=1024 && u<5){ v/=1024; u++ }
      if (u<=1) printf "%.1f %s\n", v, units[u]
      else printf "%.2f %s\n", v, units[u]
    }'
}

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

DIRLIST="$TMP_ROOT/dirs.txt"
SIZES_RAW="$TMP_ROOT/sizes_raw.tsv"
SIZES_SORTED="$TMP_ROOT/sizes_sorted.tsv"
DETAILS="$TMP_ROOT/details.txt"
DETAILS_HUMAN="$TMP_ROOT/details_human.txt"

echo "${DIM}Scanning directories...${RST}"

find "$START_DIR" \
  "${FIND_PRUNE[@]}" \
  -type d -print 2>/dev/null | sort -u > "$DIRLIST"

echo "${DIM}Measuring sizes (bytes)...${RST}"
: > "$SIZES_RAW"

while IFS= read -r d; do
  [[ -z "$d" ]] && continue
  size="$(LC_ALL=C du -sb -- "$d" 2>/dev/null | awk '{print $1}' || true)"
  [[ -z "${size:-}" ]] && size=0
  printf "%s\t%s\n" "$size" "$d" >> "$SIZES_RAW"
done < "$DIRLIST"

sort -nr -k1,1 "$SIZES_RAW" > "$SIZES_SORTED"

TOTAL_LINES="$(wc -l < "$SIZES_SORTED" | awk '{print $1}')"
if [[ "$TOTAL_LINES" -le 0 ]]; then
  echo "No directories found under: $START_DIR" >&2
  exit 1
fi

cursor=0

LEFT_W=$(( TERM_W * 55 / 100 ))
RIGHT_W=$(( TERM_W - LEFT_W - 1 ))
LIST_H=$(( TERM_H - 5 ))
[[ "$LIST_H" -lt 8 ]] && LIST_H=8

get_line() {
  local idx="$1"
  sed -n "$((idx+1))p" "$SIZES_SORTED"
}

clip_path() {
  local p="$1"
  local w="$2"
  if (( ${#p} > w )); then
    echo "…${p: -$((w-1))}"
  else
    echo "$p"
  fi
}

render_details() {
  local d="$1"
  : > "$DETAILS"

  {
    echo "Directory: $d"
    echo
    # Immediate children sizes (depth 1), then human formatting
    du -sb --max-depth=1 -- "$d" 2>/dev/null | sort -nr | head -n 25
  } > "$DETAILS"

  awk -v w="$RIGHT_W" '
    function human(b){
      split("B KiB MiB GiB TiB PiB", u, " ")
      i=0; v=b
      while (v>=1024 && i<5){ v/=1024; i++ }
      if(i<=1) return sprintf("%.1f %s", v, u[i+2])
      return sprintf("%.2f %s", v, u[i+2])
    }
    BEGIN{ }
    NR<=2 { next }  # skip "Directory:" and blank line
    {
      size=$1
      # rebuild path from 2..NF
      path=""
      for(i=2;i<=NF;i++){
        path = path (i==2?"":" ") $i
      }
      if(length(path) > w-12){
        path = "…" substr(path, length(path)-(w-13))
      }
      printf "%-10s %s\n", human(size), path
    }
  ' "$DETAILS" > "$DETAILS_HUMAN"
}

draw() {
  clear 2>/dev/null || printf "\e[H\e[2J"

  local line cur_size cur_dir
  line="$(get_line "$cursor" 2>/dev/null || true)"
  cur_size="$(awk -F'\t' '{print $1}' <<< "$line")"
  cur_dir="$(awk -F'\t' '{print $2}' <<< "$line")"

  echo -e "${BOLD}${CYN}TreeSize-ish overview${RST}  ${DIM}(bash-only)${RST}"
  echo -e "${DIM}Start:${RST} ${cur_dir:+$(clip_path "$START_DIR" $((TERM_W-8))))}  ${DIM}Selected:${RST} $(human "${cur_size:-0}")"
  echo -e "${DIM}Keys:${RST} ↑/↓ or j/k move, Enter details, q quit"

  local view_top="$cursor"
  if (( cursor >= view_top + LIST_H )); then
    view_top=$((cursor - LIST_H + 1))
  fi
  if (( cursor < view_top )); then
    view_top="$cursor"
  fi

  render_details "$cur_dir" >/dev/null 2>&1 || true

  for ((row=0; row<LIST_H; row++)); do
    local i size dir hsz clipped rline
    i=$((view_top + row))
    (( i >= TOTAL_LINES )) && break

    local l
    l="$(get_line "$i" 2>/dev/null || true)"
    size="$(awk -F'\t' '{print $1}' <<< "$l")"
    dir="$(awk -F'\t' '{print $2}' <<< "$l")"

    if (( i == cursor )); then
      left_prefix="${GRN}>${RST}"
    else
      left_prefix=" ${DIM}>${RST}"
    fi

    hsz="$(human "$size" | tr -d '\n')"
    clipped="$(clip_path "$dir" "$LEFT_W")"

    rline="$(sed -n "$((row+1))p" "$DETAILS_HUMAN" 2>/dev/null || true)"
    printf "%s %-12s %s%-*s | %s\n" \
      "$left_prefix" "$hsz" "$clipped" 0 "" "$rline"
  done
}

echo "${DIM}Ready. Use keys in the terminal window.${RST}"
draw

while true; do
  IFS= read -rsn1 key || true

  if [[ "$key" == "q" ]]; then
    clear 2>/dev/null || true
    exit 0
  fi

  if [[ "$key" == $'\n' ]]; then
    draw
    continue
  fi

  if [[ "$key" == "j" ]]; then
    (( cursor < TOTAL_LINES - 1 )) && cursor=$((cursor+1))
    draw
    continue
  fi

  if [[ "$key" == "k" ]]; then
    (( cursor > 0 )) && cursor=$((cursor-1))
    draw
    continue
  fi

  if [[ "$key" == $'\e' ]]; then
    # read the rest of escape sequence
    IFS= read -rsn1 _ || true
    IFS= read -rsn1 key3 || true
    if [[ "$_" == "[" ]]; then
      if [[ "$key3" == "A" ]]; then (( cursor > 0 )) && cursor=$((cursor-1)); draw; fi
      if [[ "$key3" == "B" ]]; then (( cursor < TOTAL_LINES - 1 )) && cursor=$((cursor+1)); draw; fi
    fi
  fi
done
