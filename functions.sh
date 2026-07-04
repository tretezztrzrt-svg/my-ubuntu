# ------- todo
# Nutzung: search "suchbegriff"
#function search() {
#    if [ -z "$1" ]; then
#        echo "Verwendung: search <suchbegriff>"
#        return 1
#    fi
#}
# nautilius kontext-menü --> könnt functions ersetzen
# cat > ~/.local/share/nautilus/scripts/echo-selection.sh <<'EOF'
# echo "Auswahl:"
# echo "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS"
# EOF
# chmod +x ~/.local/share/nautilus/scripts/echo-selection.sh
# sudo apt update
# sudo apt install nautilus-extension-gnome-terminal
# nautilus -q

# --- Functions ----------------------------------------------------------------
# Öffnet Ordner $1, zeigt Arbeitsverzeichnis (pwd) und listet Inhalt (ls -la).
# Erwartet: 1 Argument = Ordnername/-pfad
function hello() {
  if [ -z "$1" ]; then
    echo "Verwendung: hello <ordnername>"
    return 1
  fi
  cd -- "$1" || return
  pwd
  ls -la
}

# Geht eine Ebene zurück (cd ..), zeigt pwd und listet Inhalt (ls -la).
function back() {
  cd .. || return
  pwd
  ls -la
}
# Sammlung von Shell-Funktionen (für interaktive Nutzung in Bash).

# Erstellt einen Ordner (mkdir -p) und wechselt sofort hinein (cd).
# Erwartet: 1 Argument = Ordnername/-pfad
function make-dir {  
  if [ -z "$1" ]; then
    echo "Verwendung: mkdircd <ordnername>"
    return 1
  fi
  mkdir -p -- "$1" && cd -- "$1" && pwd
}

# --- Universal entpacken/packen/packenhard ------------------------------------------
# alias packen-tarfix='tar -czvf' # Komprimiert einen Ordner zu .tar.gz , vorherige kurzversion
# alias packen-untar='tar -zxvf' # Entpackt eine .tar.gz Datei , vorherige kurzversion
# sudo apt install p7zip-full required oder eben oben alias nutzen, oder beides, was weiß ich
# Hinweis:
# - benötigt: p7zip-full (für 7z)
# - mögliche Kommandos:
#     entpack <archiv.7z>
#     pack <quelle> [zielname]
#     pack-harder <quelle> [zielname]

# Entpacken von .7z/.7Z
# Nutzung: entpack /pfad/archiv.7z
function entpack() {
  # 1 Argument erforderlich
  if [ $# -ne 1 ]; then
    echo "Error: No file specified."
    return 1
  fi

  local archiv="$1"

  # Datei existiert?
  if [ ! -f "$archiv" ]; then
    echo "'$archiv' is not a valid file"
    return 1
  fi

  # Nur .7z/.7Z unterstützen
  case "$archiv" in
    *.7z | *.7Z)
      7z x -y "$archiv"  # -y: automatisch "yes" für Overwrite/Fragen
      ;;
    *)
      echo "'$archiv' ist kein .7z Archiv"
      return 1
      ;;
  esac
}

# Packen zu .7z (Standardkompression)
# Nutzung:
#   pack <datei_oder_ordner> [zielname]
# Zielname optional:
#   default: <basename(quelle)>.7z
function pack() {
  # Mindestens 2 Argumente erwartet (Quelle + Ziel optional),
  # dein Code verlangt aktuell aber $# -lt 2 => Quelle + optional zweites.
  if [ $# -lt 2 ]; then
    echo "Verwendung: packen <datei_oder_ordner> [zielname]"
    return 1
  fi

  local quelle="$1"
  local ziel="${2:-$(basename "$quelle").7z}"

  # Falls ziel keine .7z Endung hat, ergänzen
  case "$ziel" in
    *.7z) ;;
    *) ziel="${ziel}.7z" ;;
  esac

  # Quelle existiert?
  if [ ! -e "$quelle" ]; then
    echo "Fehler: Quelle existiert nicht: $quelle"
    return 1
  fi

  # Ziel darf nicht existieren
  if [ -e "$ziel" ]; then
    echo "Fehler: $ziel existiert bereits!"
    return 1
  fi

  # Erstellen des .7z Archivs
  7z a -t7z "$ziel" "$quelle"

  # Alternative Varianten (Kommentar aus deinem Original behalten):
  # 7z a -t7z -mx=9 "$ziel" "$quelle"
  # 7z a "$ziel" "$quelle" - war der vorherige vorschlag
  # (Kommentar: "hat geklappt" ist nicht wirklich Teil einer Funktion)
}

# Packen zu .7z (höhere Kompression: -mx=9)
# Nutzung: pack-harder <datei_oder_ordner> [zielname]
function pack-harder() {
  if [ $# -lt 2 ]; then
    echo "Verwendung: packen <datei_oder_ordner> [zielname]"
    return 1
  fi

  local quelle="$1"
  local ziel="${2:-$(basename "$quelle").7z}"

  # .7z Endung sicherstellen
  case "$ziel" in
    *.7z) ;;
    *) ziel="${ziel}.7z" ;;
  esac

  if [ ! -e "$quelle" ]; then
    echo "Fehler: Quelle existiert nicht: $quelle"
    return 1
  fi

  if [ -e "$ziel" ]; then
    echo "Fehler: $ziel existiert bereits!"
    return 1
  fi

  # Kompression maximal
  7z a -t7z -mx=9 "$ziel" "$quelle"
}
# --- backup -------------------------------------------------------------------
# Legt ein Backup unter $HOME/backup an und unterscheidet zwischen
#   - Ordnern: ~/backup/dir/<TIMESTAMP>_<TARGETNAME>.tar.gz
#   - Dateien: ~/backup/file/<TIMESTAMP>_<TARGETNAME>
# Logfile:
#   - liegt unter ~/backup/
#   - Name: <YYYY-MM-DD>_func_.log
#
# Nutzung:
#   backup <pfad/zur/datei_oder_ordner>
function backup() {
  # erwartete Parameterzahl
  # Ziel prüfen & sammeln
  local target backup_dir log_file target_name timestamp date_day backup_name
  backup_dir="$HOME/backup"

  # Argument prüfen
  if [[ $# -ne 1 ]]; then
    echo "Fehler: Bitte gib eine Datei oder ein Verzeichnis an!" >&2
    return 1
  fi

  target="$1"

  # Existenz prüfen (Datei oder Ordner)
  if [[ ! -e "$target" ]]; then
    echo "Fehler: '$target' existiert nicht oder ist ungültig!" >&2
    return 2
  fi

  # Zielordner anlegen (falls nicht vorhanden)
  mkdir -p -- "$backup_dir" "$backup_dir/dir" "$backup_dir/file"

  # Basis-Namen/Zeiten
  target_name="$(basename -- "$target")"
  timestamp="$(date +"%Y-%m-%d_%H-%M-%S")"
  date_day="$(date +"%Y-%m-%d")"

  # Backup-Name: Timestamp soll vor dem gesicherten Ziel stehen
  backup_name="${timestamp}_${target_name}"

  # Logfile: im Backup-Ordner, Kennung "_func_"
  log_file="${backup_dir}/${date_day}_func_.log"

  # Alles protokollieren (inkl. Ausgabe von Fehlern)
  {
    echo "=== Backup-Start: $(date) ==="
    echo "Zielobjekt: $target"
    echo "Backup-Name: $backup_name"

    # Datei oder Verzeichnis: unterschiedlich sichern
    if [[ -d "$target" ]]; then
      echo "Typ: Verzeichnis"

      # Verzeichnis komprimieren:
      # -C auf den Parent setzen
      # - nur den Ordnernamen ins Archiv aufnehmen
      tar -czf "${backup_dir}/dir/${backup_name}.tar.gz" \
        -C "$(dirname -- "$target")" "$target_name"

      echo "Erfolgreich als ${backup_name}.tar.gz gesichert."
    else
      echo "Typ: Datei"

      # Datei kopieren in file/ mit Backupnamen
      cp -- "$target" "${backup_dir}/file/${backup_name}"

      echo "Erfolgreich als ${backup_name} gesichert."
    fi

    echo "=== Backup-Ende: $(date) ==="
    echo
  } >> "$log_file" 2>&1
}
# --- trash -------------------------------------------------------------------
# Verschiebt Dateien/Ordner in den Papierkorb unter $HOME/trash und unterscheidet zwischen
#   - Ordnern: ~/trash/dir/<TIMESTAMP>_<TARGETNAME>
#   - Dateien: ~/trash/file/<TIMESTAMP>_<TARGETNAME>
# Logfile:
#   - liegt unter ~/trash/
#   - Name: <YYYY-MM-DD>_func_.log
#
# Nutzung:
#   trash <pfad/zur/datei_oder_ordner>
function trash() {
  # erwartete Parameterzahl
  # Ziel prüfen & sammeln
  local target trash_dir log_file target_name timestamp date_day trash_name
  trash_dir="$HOME/trash"

  # Argument prüfen
  if [[ $# -ne 1 ]]; then
    echo "Fehler: Bitte gib eine Datei oder ein Verzeichnis an!" >&2
    return 1
  fi

  target="$1"

  # Existenz prüfen (Datei oder Ordner)
  if [[ ! -e "$target" ]]; then
    echo "Fehler: '$target' existiert nicht oder ist ungültig!" >&2
    return 2
  fi

  # Zielordner anlegen (falls nicht vorhanden)
  mkdir -p -- "$trash_dir" "$trash_dir/dir" "$trash_dir/file"

  # Basis-Namen/Zeiten
  target_name="$(basename -- "$target")"
  timestamp="$(date +"%Y-%m-%d_%H-%M-%S")"
  date_day="$(date +"%Y-%m-%d")"

  # Trash-Name: Timestamp soll vor dem gelöschten Ziel stehen
  trash_name="${timestamp}_${target_name}"

  # Logfile: im Trash-Ordner, Kennung "_func_"
  log_file="${trash_dir}/${date_day}_func_.log"

  # Alles protokollieren (inkl. Ausgabe von Fehlern)
  {
    echo "=== Trash-Start: $(date) ==="
    echo "Zielobjekt: $target"
    echo "Trash-Name: $trash_name"

    # Datei oder Verzeichnis: unterschiedlich verschieben
    if [[ -d "$target" ]]; then
      echo "Typ: Verzeichnis"

      # Verzeichnis verschieben
      mv -- "$target" "${trash_dir}/dir/${trash_name}"

      echo "Erfolgreich als ${trash_name} in Trash verschoben."
    else
      echo "Typ: Datei"

      # Datei verschieben
      mv -- "$target" "${trash_dir}/file/${trash_name}"

      echo "Erfolgreich als ${trash_name} in Trash verschoben."
    fi

    echo "=== Trash-Ende: $(date) ==="
    echo
  } >> "$log_file" 2>&1
}
