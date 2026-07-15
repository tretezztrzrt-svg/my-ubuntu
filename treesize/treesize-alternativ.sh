#!/usr/bin/env bash
#
# TreeSize Bash Pro (Ubuntu/Linux)
#
# Beschreibung:
#   TreeSize-ähnlicher Überblick mit Disk-Summary, farbigen Größen,
#   Tiefen-Indentation und Balken proportional zur RICHTIGEN Gesamtgröße.
#
# Nutzung:
#   ./treesize.sh [Pfad] [Tiefe]
#
# Beispiele:
#   ./treesize.sh
#   ./treesize.sh /var/log 3
#
# Voraussetzungen:
#   Nur Bash, du, df, sort, awk. Keine externen Abhängigkeiten.
#

set -euo pipefail

TARGET="${1:-.}"
MAX_DEPTH="${2:-2}"

RED=$'\033[31m'
MAG=$'\033[35m'
YEL=$'\033[33m'
CYA=$'\033[36m'
GRN=$'\033[32m'
BLD=$'\033[1;37m'
RESET=$'\033[0m'

if ! [ -d "$TARGET" ]; then
    echo "Error: '$TARGET' is not a directory" >&2
    exit 1
fi

# ====================== DISK OVERVIEW ======================
read -r _ TOTAL_DISK USED_DISK FREE_DISK USE_PCT _ <<< "$(df -h "$TARGET" | awk 'NR==2')"

echo "${CYA}========================================================================${RESET}"
echo "${BLD} TreeSize Overview: $TARGET${RESET}"
echo "${CYA}========================================================================${RESET}"
echo "${GRN}Gesamt: $TOTAL_DISK${RESET} | ${RED}Belegt: $USED_DISK ($USE_PCT)${RESET} | ${CYA}Frei: $FREE_DISK${RESET}"
echo "${CYA}------------------------------------------------------------------------${RESET}"

# ====================== SCAN & AUSGABE ======================
# RAW_TOTAL = echte Gesamtgröße des Zielordners, EINMAL berechnet, nicht während
# der Ausgabe aufsummiert -> keine reihenfolge-abhängigen Prozent-Fehler.
RAW_TOTAL=$(du -sb "$TARGET" 2>/dev/null | awk '{print $1}')
[ -z "$RAW_TOTAL" ] || [ "$RAW_TOTAL" -eq 0 ] && RAW_TOTAL=1

DATA=$(du -b --max-depth="$MAX_DEPTH" "$TARGET" 2>/dev/null | sort -n -r)

echo "$DATA" | awk -v TARGET="$TARGET" -v TOTAL="$RAW_TOTAL" \
    -v RED="$RED" -v MAG="$MAG" -v YEL="$YEL" -v CYA="$CYA" -v GRN="$GRN" -v RESET="$RESET" '
function color(n) {
    if (n > 1073741824) return RED
    if (n > 536870912)  return MAG
    if (n > 134217728)  return YEL
    if (n > 33554432)   return CYA
    return GRN
}
function human(n) {
    if (n < 1024)        return sprintf("%d B", n)
    if (n < 1048576)     return sprintf("%.1f KB", n/1024)
    if (n < 1073741824)  return sprintf("%.1f MB", n/1048576)
    return sprintf("%.1f GB", n/1073741824)
}
{
    size = $1
    path = $2
    if (path == TARGET) next  # Root-Zeile selbst überspringen

    # Prozent IMMER relativ zur echten Gesamtgröße (RAW_TOTAL), fixer Bezugswert
    pct = int((size * 100) / TOTAL)

    bar_len = int((pct / 100) * 30)
    bar = ""
    for (i = 0; i < bar_len; i++) bar = bar "█"
    for (i = bar_len; i < 30; i++) bar = bar "░"

    # Tiefe anhand Slash-Differenz zum Zielpfad
    depth = gsub("/", "/", path) - gsub("/", "/", TARGET)
    indent = ""
    for (i = 1; i < depth; i++) indent = indent "    "
    if (depth > 0) indent = indent "└── "

    # Basename extrahieren
    n = split(path, parts, "/")
    name = parts[n]

    printf "%s%-10s%s [%s%s%s] %3d%%  %s%s\n",
           color(size), human(size), RESET, MAG, bar, RESET, pct, indent, name
}'

echo "${CYA}------------------------------------------------------------------------${RESET}"
