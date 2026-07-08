#!/usr/bin/env bash
#
# Copilot‑TreeSize PRO (Linux)
#
# Beschreibung:
#   TreeSize‑ähnlicher Überblick für Ubuntu mit farbigen Größen,
#   Tiefen‑Indentation und dynamischen Balken (█) proportional zur Größe.
#
# Nutzung:
#   ./copilot-treesize-pro.sh [Pfad] [Tiefe]
#
# Beispiele:
#   ./copilot-treesize-pro.sh .
#   ./copilot-treesize-pro.sh /var/log 3
#
# Hinweise:
#   Nur Bash, du, sort, awk.
#   Balkenlänge passt sich automatisch an die größte Ordnergröße an.
#

set -euo pipefail

TARGET="${1:-.}"
MAX_DEPTH="${2:-4}"

RED=$'\033[31m'
MAG=$'\033[35m'
YEL=$'\033[33m'
CYA=$'\033[36m'
GRN=$'\033[32m'
RESET=$'\033[0m'

if ! [ -d "$TARGET" ]; then
  echo "Error: '$TARGET' is not a directory" >&2
  exit 1
fi

DATA=$(du -b --max-depth="$MAX_DEPTH" "$TARGET" 2>/dev/null | sort -h -r)
MAX_SIZE=$(echo "$DATA" | awk '{print $1}' | head -n1)

echo "$DATA" | awk -F'\t' -v MAX="$MAX_SIZE" \
  -v RED="$RED" -v MAG="$MAG" -v YEL="$YEL" -v CYA="$CYA" -v GRN="$GRN" -v RESET="$RESET" '
function color(n) {
  if (n > 1073741824) return RED
  if (n > 536870912) return MAG
  if (n > 134217728) return YEL
  if (n > 33554432) return CYA
  return GRN
}
function human(n) {
  if (n < 1024) return n " B"
  if (n < 1048576) return sprintf("%.1f KB", n/1024)
  if (n < 1073741824) return sprintf("%.1f MB", n/1048576)
  return sprintf("%.1f GB", n/1073741824)
}
{
  size=$1
  path=$2
  depth=gsub("/", "/", path)

  indent=""
  for (i=1; i<depth; i++) indent=indent "  "

  bar_len = int((size / MAX) * 40)
  bar=""
  for (i=0; i<bar_len; i++) bar=bar "█"

  printf "%s%s%-10s%s  %-40s %s\n",
         indent, color(size), human(size), RESET, bar, path
}
'
