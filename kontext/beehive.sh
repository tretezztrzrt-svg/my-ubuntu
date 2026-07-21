#!/usr/bin/env bash
#
# BeeHive – TreeSize‑Optik mit Bienengruss
# Nutzung: ./beehive.sh [Pfad] [Tiefe] [--gui|--terminal]
#

# ---------- Sicherheitsoptionen ----------
# -e : bricht bei Fehlern ab
# -u : nicht gesetzte Variablen führen zu Fehler
# -o pipefail : Pipeline schlägt fehl, wenn ein Befehl fehlschlägt
set -euo pipefail

# ---------- Parameter einlesen ----------
TARGET="${1:-.}"           # Zielverzeichnis (Standard: aktuelles)
MAX_DEPTH="${2:-4}"        # Maximale Tiefe (Standard: 4)
MODE="auto"                # Ausgabemodus: auto, gui, terminal

# Schleife über alle Argumente, um --gui / --terminal zu erkennen
for arg in "$@"; do
    case "$arg" in
        --gui)      MODE="gui" ;;
        --terminal) MODE="terminal" ;;
    esac
done

# ---------- Hilfsfunktionen ----------
# Prüft, ob die Standardausgabe ein Terminal ist (d.h. interaktiv)
is_terminal() { [ -t 1 ]; }

# Prüft, ob yad oder zenity installiert sind (GUI-Fähigkeit)
has_gui() { command -v yad &>/dev/null || command -v zenity &>/dev/null; }

# Funktion zur Anzeige der Ausgabe in einem GUI-Fenster (yad bevorzugt, sonst zenity)
show_gui() {
    local content="$1"
    local title="🐝 BeeHive – $TARGET"
    if command -v yad &>/dev/null; then
        echo -e "$content" | yad --text-info --title="$title" \
            --width=1100 --height=700 --fontname="Monospace 10" \
            --button="Schließen":0 --window-icon="utilities-terminal"
    elif command -v zenity &>/dev/null; then
        echo -e "$content" | zenity --text-info --title="$title" \
            --width=1100 --height=700 --font="Monospace 10" \
            --ok-label="Schließen"
    else
        # Fallback: Ausgabe in der Konsole, falls keine GUI verfügbar
        echo "$content"
    fi
}

# ---------- Daten sammeln ----------
# Prüfen, ob das Ziel ein Verzeichnis ist
if [ ! -d "$TARGET" ]; then
    echo "Fehler: '$TARGET' ist kein Verzeichnis" >&2
    exit 1
fi

# du sammelt die Größen (in Bytes) bis zur angegebenen Tiefe.
# sort -h -r sortiert nach menschlesbaren Größen absteigend.
DATA=$(du -b --max-depth="$MAX_DEPTH" "$TARGET" 2>/dev/null | sort -h -r)

# Falls keine Daten (z.B. bei leerem Verzeichnis) -> Abbruch
[ -z "$DATA" ] && { echo "Keine Daten" >&2; exit 1; }

# Gesamtgröße über alle Einträge (Summe der ersten Spalte)
TOTAL_SIZE=$(echo "$DATA" | awk '{sum+=$1} END {print sum}')
# Anzahl der gefundenen Zeilen (Verzeichnisse + Dateien)
FILE_COUNT=$(echo "$DATA" | wc -l)
# Größte Einzelgröße (max der ersten Spalte)
MAX_SIZE=$(echo "$DATA" | awk '{print $1}' | head -n1)

# ---------- Hilfsfunktion für menschenlesbare Größen (für die Kopfzeile) ----------
human() {
    awk 'function h(n) {
        if (n < 1024) return n " B";
        if (n < 1048576) return sprintf("%.1f KB", n/1024);
        if (n < 1073741824) return sprintf("%.1f MB", n/1048576);
        return sprintf("%.1f GB", n/1073741824);
    } {print h($1)}'
}

# ---------- Ausgabe (plain) für GUI (ohne Farben) ----------
# Kopfzeile mit Statistiken
HEADER=$(cat <<EOF
🐝 BeeHive – TreeSize-Analyse
==============================
Ziel: $TARGET
Tiefe: $MAX_DEPTH
Einträge: $FILE_COUNT
Gesamtgröße: $(echo $TOTAL_SIZE | human)
Max. Größe: $(echo $MAX_SIZE | human)

Pfad                                                 Größe       %   ███ Balken

EOF
)

# Die eigentlichen Datenzeilen: Pfad, Größe, Prozent, Balken
# Verarbeitung mit awk – alle Berechnungen erfolgen hier
CONTENT=$(echo "$DATA" | awk -v MAX="$MAX_SIZE" -v TOTAL="$TOTAL_SIZE" -v TARGET="$TARGET" '
# Hilfsfunktion für menschenlesbare Größe (gleiche Logik wie oben)
function h(n) {
    if (n < 1024) return n " B";
    if (n < 1048576) return sprintf("%.1f KB", n/1024);
    if (n < 1073741824) return sprintf("%.1f MB", n/1048576);
    return sprintf("%.1f GB", n/1073741824);
}
{
    size = $1;          # Größe in Bytes
    path = $2;          # voller Pfad (absolut oder relativ)

    # Entferne den Zielpfad aus dem Pfad, um relative Darstellung zu erhalten
    gsub(TARGET "/?", "", path);
    if (path == "") path = "/";  # Root des Ziels

    # Tiefe zählen (Anzahl der Schrägstriche) für Einrückung
    depth = split(path, parts, "/");
    indent = "";
    for (i=1; i<depth; i++) indent = indent "  ";   # zwei Leerzeichen pro Ebene

    # Prozentualer Anteil an der Gesamtgröße
    percent = (size / TOTAL) * 100;
    percent_str = sprintf("%5.1f", percent);

    # Balkenlänge: proportional zur maximalen Größe, auf 30 Zeichen begrenzt
    bar_len = int((size / MAX) * 30);
    if (bar_len < 1) bar_len = 1;   # mindestens ein Block
    bar = "";
    for (i=0; i<bar_len; i++) bar = bar "█";
    bar = sprintf("%-30s", bar);    # rechts mit Leerzeichen auffüllen

    # Größe rechtsbündig in 10 Zeichen
    size_str = sprintf("%10s", h(size));

    # Pfad auf maximal 55 Zeichen kürzen, um die Tabelle nicht zu sprengen
    path_display = indent path;
    if (length(path_display) > 55) {
        path_display = substr(path_display, 1, 52) "...";
    }

    # Ausgabe: Pfad (linksbündig, 55 Zeichen), Größe, Prozent, Balken
    printf "%-55s  %s  %s  %s\n", path_display, size_str, percent_str, bar;
}')

# Gesamte Ausgabe (ohne Farben) für GUI
OUTPUT_PLAIN="${HEADER}${CONTENT}"

# ---------- Entscheidung: GUI oder Terminal? ----------
if [ "$MODE" = "terminal" ]; then
    USE_GUI=false
elif [ "$MODE" = "gui" ]; then
    USE_GUI=true
else
    # Automatik:
    # Wenn wir in einem Terminal sind und keine GUI installiert ist -> Terminal
    # Wenn GUI verfügbar ist (und nicht explizit Terminal erzwungen) -> GUI
    # Wenn weder Terminal noch GUI -> Terminal (Fallback)
    if is_terminal && ! has_gui; then
        USE_GUI=false
    elif has_gui; then
        USE_GUI=true
    else
        USE_GUI=false
    fi
fi

# ---------- Ausgabe ----------
if [ "$USE_GUI" = true ]; then
    # GUI-Ausgabe (ohne Farben, aber mit Monospace)
    show_gui "$OUTPUT_PLAIN"
else
    # ---------- Terminal-Ausgabe mit ANSI-Farben ----------
    # Farbdefinitionen (ANSI Escape-Codes)
    RED=$'\033[31m'
    MAG=$'\033[35m'
    YEL=$'\033[33m'
    CYA=$'\033[36m'
    GRN=$'\033[32m'
    RESET=$'\033[0m'
    BOLD=$'\033[1m'

    # Kopfzeile fett und mit Bienen-Emoji
    echo -e "${BOLD}🐝 BeeHive – TreeSize-Analyse${RESET}"
    echo "=============================="
    echo "Ziel: $TARGET"
    echo "Tiefe: $MAX_DEPTH"
    echo "Einträge: $FILE_COUNT"
    echo "Gesamtgröße: $(echo $TOTAL_SIZE | human)"
    echo "Max. Größe: $(echo $MAX_SIZE | human)"
    echo ""
    # Spaltenüberschriften
    printf "%-55s  %-10s  %5s  %s\n" "Pfad" "Größe" "%" "███ Balken"
    printf "%-55s  %-10s  %5s  %s\n" "--" "-" "--" "-"

    # Datenausgabe mit Farben für die Größe
    echo "$DATA" | awk -v MAX="$MAX_SIZE" -v TOTAL="$TOTAL_SIZE" -v TARGET="$TARGET" \
        -v RED="$RED" -v MAG="$MAG" -v YEL="$YEL" -v CYA="$CYA" -v GRN="$GRN" -v RESET="$RESET" '
    # Gleiche Hilfsfunktionen wie oben
    function h(n) {
        if (n < 1024) return n " B";
        if (n < 1048576) return sprintf("%.1f KB", n/1024);
        if (n < 1073741824) return sprintf("%.1f MB", n/1048576);
        return sprintf("%.1f GB", n/1073741824);
    }
    # Farbauswahl basierend auf Größe (TreeSize-typisch)
    function color(n) {
        if (n > 1073741824) return RED;        # > 1 GB
        if (n > 536870912)  return MAG;        # > 512 MB
        if (n > 134217728)  return YEL;        # > 128 MB
        if (n > 33554432)   return CYA;        # > 32 MB
        return GRN;                            # <= 32 MB
    }
    {
        size = $1;
        path = $2;
        gsub(TARGET "/?", "", path);
        if (path == "") path = "/";

        depth = split(path, parts, "/");
        indent = "";
        for (i=1; i<depth; i++) indent = indent "  ";

        percent = (size / TOTAL) * 100;
        percent_str = sprintf("%5.1f", percent);

        bar_len = int((size / MAX) * 30);
        if (bar_len < 1) bar_len = 1;
        bar = "";
        for (i=0; i<bar_len; i++) bar = bar "█";
        bar = sprintf("%-30s", bar);

        # Größe mit Farbe umgeben
        size_str = h(size);
        colored_size = color(size) size_str RESET;

        path_display = indent path;
        if (length(path_display) > 55) {
            path_display = substr(path_display, 1, 52) "...";
        }

        printf "%-55s  %s  %s  %s\n", path_display, colored_size, percent_str, bar;
    }'
fi
