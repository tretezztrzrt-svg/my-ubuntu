# =============================================================================
# BASH SHELL FUNCTIONS
# Sammlung von Shell-Funktionen für interaktive Nutzung in Bash.
# =============================================================================

# --- NAVIGATION & DIRECTORY MANAGEMENT ------------------------------------

# Öffnet Ordner $1, zeigt Arbeitsverzeichnis (pwd) und listet Inhalt (ls -la).
# Nutzung: hello <ordnername>
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

# Erstellt einen Ordner (mkdir -p) und wechselt sofort hinein (cd).
# Nutzung: make-dir <ordnername>
function make-dir {  
  if [ -z "$1" ]; then
    echo "Verwendung: mkdircd <ordnername>"
    return 1
  fi
  mkdir -p -- "$1" && cd -- "$1" && pwd
}

# --- COMPRESSION & ARCHIVING -----------------------------------------------

# Entpacken von .7z/.7Z Archiven
# Nutzung: entpack /pfad/archiv.7z
# Benötigt: p7zip-full
function entpack() {
  if [ $# -ne 1 ]; then
    echo "Error: No file specified."
    return 1
  fi

  local archiv="$1"

  if [ ! -f "$archiv" ]; then
    echo "'$archiv' is not a valid file"
    return 1
  fi

  case "$archiv" in
    *.7z | *.7Z)
      7z x -y "$archiv"
      ;;
    *)
      echo "'$archiv' ist kein .7z Archiv"
      return 1
      ;;
  esac
}

# Packen zu .7z (Standardkompression)
# Nutzung: pack <datei_oder_ordner> [zielname]
function pack() {
  if [ $# -lt 2 ]; then
    echo "Verwendung: packen <datei_oder_ordner> [zielname]"
    return 1
  fi

  local quelle="$1"
  local ziel="${2:-$(basename "$quelle").7z}"

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

  7z a -t7z "$ziel" "$quelle"
}

# Packen zu .7z mit höherer Kompression (-mx=9)
# Nutzung: pack-harder <datei_oder_ordner> [zielname]
function pack-harder() {
  if [ $# -lt 2 ]; then
    echo "Verwendung: packen <datei_oder_ordner> [zielname]"
    return 1
  fi

  local quelle="$1"
  local ziel="${2:-$(basename "$quelle").7z}"

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

  7z a -t7z -mx=9 "$ziel" "$quelle"
}

# Erstellt .tar.gz Archive
# Nutzung: tarfix <archiv.tar.gz> <datei1> [datei2 ...]
function tarfix() {
  if [ $# -lt 2 ]; then
    echo "Usage: tarfix <archiv.tar.gz> <datei1> [datei2 ...]"
    return 1
  fi
  tar -czvf "$1" "${@:2}"
}

# Entpackt .tar.gz Archive
# Nutzung: untar <archiv.tar.gz>
function untar() {
  if [ $# -ne 1 ]; then
    echo "Usage: untar <archiv.tar.gz>"
    return 1
  fi
  tar -xzvf "$1"
}

# --- BACKUP & RESTORE -------------------------------------------------------

# Legt ein Backup unter $HOME/backup an (Ordner/Dateien getrennt)
# Log-Datei: ~/backup/<YYYY-MM-DD>_func_.log
# Nutzung: backup <pfad/zur/datei_oder_ordner>
function backup() {
  local target backup_dir log_file target_name timestamp date_day backup_name
  backup_dir="$HOME/backup"

  if [[ $# -ne 1 ]]; then
    echo "Fehler: Bitte gib eine Datei oder ein Verzeichnis an!" >&2
    return 1
  fi

  target="$1"

  if [[ ! -e "$target" ]]; then
    echo "Fehler: '$target' existiert nicht oder ist ungültig!" >&2
    return 2
  fi

  mkdir -p -- "$backup_dir" "$backup_dir/dir" "$backup_dir/file"

  target_name="$(basename -- "$target")"
  timestamp="$(date +"%Y-%m-%d_%H-%M-%S")"
  date_day="$(date +"%Y-%m-%d")"
  backup_name="${timestamp}_${target_name}"
  log_file="${backup_dir}/${date_day}_func_.log"

  {
    echo "=== Backup-Start: $(date) ==="
    echo "Zielobjekt: $target"
    echo "Backup-Name: $backup_name"

    if [[ -d "$target" ]]; then
      echo "Typ: Verzeichnis"
      tar -czf "${backup_dir}/dir/${backup_name}.tar.gz" \
        -C "$(dirname -- "$target")" "$target_name"
      echo "Erfolgreich als ${backup_name}.tar.gz gesichert."
    else
      echo "Typ: Datei"
      cp -- "$target" "${backup_dir}/file/${backup_name}"
      echo "Erfolgreich als ${backup_name} gesichert."
    fi

    echo "=== Backup-Ende: $(date) ==="
    echo
  } >> "$log_file" 2>&1
}

# Verschiebt Dateien/Ordner in den Papierkorb ($HOME/trash)
# Log-Datei: ~/trash/<YYYY-MM-DD>_func_.log
# Nutzung: trash <pfad/zur/datei_oder_ordner>
function trash() {
  local target trash_dir log_file target_name timestamp date_day trash_name
  trash_dir="$HOME/trash"

  if [[ $# -ne 1 ]]; then
    echo "Fehler: Bitte gib eine Datei oder ein Verzeichnis an!" >&2
    return 1
  fi

  target="$1"

  if [[ ! -e "$target" ]]; then
    echo "Fehler: '$target' existiert nicht oder ist ungültig!" >&2
    return 2
  fi

  mkdir -p -- "$trash_dir" "$trash_dir/dir" "$trash_dir/file"

  target_name="$(basename -- "$target")"
  timestamp="$(date +"%Y-%m-%d_%H-%M-%S")"
  date_day="$(date +"%Y-%m-%d")"
  trash_name="${timestamp}_${target_name}"
  log_file="${trash_dir}/${date_day}_func_.log"

  {
    echo "=== Trash-Start: $(date) ==="
    echo "Zielobjekt: $target"
    echo "Trash-Name: $trash_name"

    if [[ -d "$target" ]]; then
      echo "Typ: Verzeichnis"
      mv -- "$target" "${trash_dir}/dir/${trash_name}"
      echo "Erfolgreich als ${trash_name} in Trash verschoben."
    else
      echo "Typ: Datei"
      mv -- "$target" "${trash_dir}/file/${trash_name}"
      echo "Erfolgreich als ${trash_name} in Trash verschoben."
    fi

    echo "=== Trash-Ende: $(date) ==="
    echo
  } >> "$log_file" 2>&1
}

# --- SYSTEM & SERVICES -------------------------------------------------------

# Wrapper für systemctl mit sudo
# Nutzung: service {start|stop|restart|status|enable|disable} <service>
function service() {
  local action=$1
  shift
  case "$action" in
    start|stop|restart|status|enable|disable)
      sudo systemctl "$action" "$@"
      ;;
    *)
      echo "Usage: service {start|stop|restart|status|enable|disable} <service>"
      return 1
      ;;
  esac
}

# Führt letzten Befehl mit sudo aus oder sudo für gegebene Argumente
# Nutzung: please [!!] oder please <befehl>
function please() {
  if [ $# -eq 0 ] || [ "$1" = "!!" ]; then
    echo "oh honey..."
    sudo $(fc -ln -1)
  else
    sudo "$@"
  fi
}

# Führt letzten Befehl mit sudo aus (alias für please)
# Nutzung: fuck
function fuck() {
  if [ $# -eq 0 ]; then
    echo "oh oh..."
    local lastcmd=$(fc -ln -1)
    if [ -z "$lastcmd" ]; then
      echo "Kein vorheriger Befehl in der Historie, honey" >&2
      return 1
    fi
    eval "sudo $lastcmd"
  else
    echo "Kein vorheriger Befehl in der Historie, honey" >&2
  fi
}

# Beendet Prozesse mit kill -9
# Nutzung: killforce <PID1> [PID2 ...]
function killforce() {
  if [ $# -eq 0 ]; then
    echo "Usage: killforce <PID1> [PID2 ...]"
    return 1
  fi
  kill -9 "$@"
}

# --- DISK SPACE & FILE ANALYSIS -----------------------------------------------

# Zeigt Verzeichnisgröße mit du und sortiert Ergebnis
# Nutzung: ordner [pfad]
function ordner() {
  du -h "$@" | sort -h
}

# Zeigt Größen aller Dateien/Ordner im aktuellen Verzeichnis, sortiert
# Nutzung: sortiert
function sortiert() {
  du -sh * 2>/dev/null | sort -h
}

# Zeigt die 10 größten Dateien/Ordner
# Nutzung: bigfiles [pfad]
function bigfiles() {
  du -ah "$@" 2>/dev/null | sort -rh | head -n 10
}

# --- HISTORY & PROFILING -------------------------------------------------------

# Zeigt die häufigsten Shell-Befehle
# Nutzung: profile_me [n] (default: 10)
function profile_me() {
  if ! command -v history &>/dev/null; then
    echo "Fehler: 'history' ist nicht verfügbar (nicht-interaktive Shell?)" >&2
    return 1
  fi
  local lines=${1:-10}
  history | awk '{print $2}' | sort | uniq -c | sort -rn | head -n "$lines"
}
