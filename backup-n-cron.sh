#================================================================
# backup cron job examples (alle 24 stunden oder benutzerdefiniert)
# syntax-hilfe: minute stunde tagmonat monat wochentag befehl
#================================================================
# m h  dom mon dow   command
# 42 * * * * bash /home/alex/backup/backup-n-cron.sh /home/alex/.bash_function
# 42 * * * * bash /home/alex/backup/backup-n-cron.sh /home/alex/.bash_history
# 42 * * * * bash /home/alex/backup/backup-n-cron.sh /home/alex/.bashrc
# lesen: sund crontab -e 
# check: sudo crontab -l
#
# !/bin/bash
# backup-n-cron.sh
# FEHLERBEHANDLUNG & KONFIGURATION
set -e

# Pfad zum Backup-Ordner (wird im Home-Verzeichnis des ausführenden Users erstellt)
BACKUP_DIR="/home/alex/backup/"
mkdir -p "$BACKUP_DIR"

# Prüfen, ob ein Argument übergeben wurde
if [ -z "$1" ]; then
    echo "Fehler: Bitte gib eine Datei oder ein Verzeichnis an!"
    echo "Nutzung: $0 /pfad/zur/datei_oder_ordner"
    exit 1
fi

TARGET="$1"
TARGET_NAME=$(basename "$TARGET")
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DATE_DAY=$(date +"%Y-%m-%d")

# Namen für Backup und Log definieren
BACKUP_NAME="${TARGET_NAME}_${TIMESTAMP}"
LOG_FILE="${BACKUP_DIR}/${TARGET_NAME}_${DATE_DAY}.log"

# START LOGGING
echo "=== Backup-Start: $(date) ===" >> "$LOG_FILE"
echo "Zielobjekt: $TARGET" >> "$LOG_FILE"

# PRÜFUNG: Datei oder Verzeichnis?
if [ -d "$TARGET" ]; then
    echo "Typ: Verzeichnis" >> "$LOG_FILE"
    # Als komprimiertes Archiv speichern (schont Platz)
    tar -czf "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" -C "$(dirname "$TARGET")" "$TARGET_NAME"
    echo "Erfolgreich als ${BACKUP_NAME}.tar.gz gesichert." >> "$LOG_FILE"

elif [ -f "$TARGET" ]; then
    echo "Typ: Datei" >> "$LOG_FILE"
    cp "$TARGET" "${BACKUP_DIR}/${BACKUP_NAME}"
    echo "Erfolgreich als ${BACKUP_NAME} gesichert." >> "$LOG_FILE"

else
    echo "Fehler: '$TARGET' existiert nicht oder ist ungültig!" >> "$LOG_FILE"
    exit 2
fi

echo "=== Backup-Ende: $(date) ===" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
