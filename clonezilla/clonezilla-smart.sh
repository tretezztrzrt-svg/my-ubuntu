#!/bin/bash
# =================================================================
# CLONEZILLA SMART PARTITION BACKUP & RECOVERY SCRIPT
# =================================================================
# Dieses Skript führt dich sicher durch Backup und Wiederherstellung von PARTITIONEN.
# Es fragt alles ab, was wichtig ist, und warnt vor häufigen Fehlern.
# ================================================================
# KONFIGURATION (Hier kannst du Standardwerte anpassen)
# =================================================================
DEFAULT_COMPRESSION="zstd"    # zstd, gzip, lzma, oder none (zstd ist schnell & gut)
DEFAULT_SPLIT_SIZE="4000"     # Max. Dateigröße in MB (für FAT32-kompatible Backups)
DEFAULT_BACKUP_DIR="/home/partimag"  # Standard-Clonezilla-Image-Verzeichnis
MIN_PASSWORD_LENGTH=8         # Mindestlänge für das Passwort

# =================================================================
# HILFSFUNKTIONEN
# =================================================================
# Bildschirm leeren und Kopfzeile anzeigen
clear_screen() {
    clear
    echo -e " ============================================================ "
    echo -e "   CLONEZILLA SMART PARTITION BACKUP & RECOVERY TOOL "
    echo -e " ============================================================ "
}

# Auf Tastendruck warten
press_any_key() {
    echo -e " Drücke [ENTER] um fortzufahren... "
    read -r
}

# Festplatten und Partitionen übersichtlich anzeigen
show_disks() {
    echo -e " --- Vorhandene Festplatten & Partitionen --- "
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL 2>/dev/null || lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
    echo -e " Hinweis:  sda, sdb, nvme0n1 sind Festplatten (TYPE=disk)."
    echo -e "           Partitionen wie sda1, nvme0n1p2 haben TYPE=part."
    echo -e "           Du MUSST eine Partition angeben!"
}

# Sichere Passwortabfrage
get_password() {
    local PW1=""
    local PW2=""
    while true; do
        echo -e " Verschlüsselungspasswort: "
        echo -e " Hinweis: Mindestens $MIN_PASSWORD_LENGTH Zeichen, kein Leerzeichen. "
        read -s -p "Passwort eingeben: " PW1
        echo ""
        read -s -p "Passwort wiederholen: " PW2
        echo ""
        if [ ${#PW1} -lt $MIN_PASSWORD_LENGTH ]; then
            echo -e " Fehler: Passwort muss mindestens $MIN_PASSWORD_LENGTH Zeichen lang sein! "
        elif [ "$PW1" != "$PW2" ]; then
            echo -e " Fehler: Passwörter stimmen nicht überein! "
        else
            echo "$PW1"
            return 0
        fi
    done
}

# Prüfen, ob eine Partition gemountet ist und ggf. aushängen
check_and_unmount() {
    local DEVICE="$1"
    local MOUNTS=$(mount | grep "^$DEVICE" | awk '{print $3}')
    if [ -n "$MOUNTS" ]; then
        echo -e " Warnung: $DEVICE ist noch gemountet auf: "
        echo "$MOUNTS"
        echo -e " Eine gemountete Partition kann nicht für die Wiederherstellung verwendet werden! "
        read -p "Soll ich die Mounts automatisch aushängen? (j/n): " UNMOUNT_ANSWER
        if [[ "$UNMOUNT_ANSWER" =~ ^[Jj]$ ]]; then
            for M in $MOUNTS; do
                echo "Hänge $M aus..."
                umount "$M" 2>/dev/null || echo -e " Konnte $M nicht aushängen! "
            done
            sleep 2
        else
            echo -e " Abbruch. Bitte hänge die Partitionen manuell aus. "
            exit 1
        fi
    fi
}

# Ziel- oder Quellpartition auswählen mit Sicherheitsabfragen
select_target_partition() {
    local PROMPT="$1"
    local EXCLUDE_PART="$2"
    local PART=""
    while true; do
        echo -e "$PROMPT"
        echo -e " Gib den Partitionsnamen ein (z.B. sda1, sda2, nvme0n1p2): "
        read -r PART
        PART=$(echo "$PART" | sed 's|^/dev/||')  # /dev/ entfernen falls vorhanden
        
        # Prüfen ob Gerät existiert
        if [ ! -b "/dev/$PART" ]; then
            echo -e " Fehler: /dev/$PART existiert nicht! "
            continue
        fi
        
        # 🔥 NEUER SICHERHEITSGURT: Prüfen, ob es sich wirklich um eine Partition handelt
        local DEV_TYPE=$(lsblk -nod TYPE "/dev/$PART" 2>/dev/null)
        if [ "$DEV_TYPE" != "part" ]; then
            echo -e " Fehler: /dev/$PART ist eine Festplatte ($DEV_TYPE) und keine Partition! "
            echo -e " Bitte gib eine Partition an (z.B. sda1 statt sda). "
            continue
        fi
        
        # Prüfen ob es die Backup-Partition ist
        if [ -n "$EXCLUDE_PART" ] && [ "$PART" = "$EXCLUDE_PART" ]; then
            echo -e " Fehler: Das ist deine Backup-Partition ($EXCLUDE_PART)! Bitte wähle eine andere. "
            continue
        fi
        
        # Zusätzliche Sicherheitsabfrage für die Wiederherstellung
        if [[ "$MODE" == "restore" ]]; then
            echo -e " ⚠️  ACHTUNG: /dev/$PART wird KOMPLETT überschrieben! "
            echo -e "     Alle Daten auf DIESER PARTITION gehen verloren! "
            read -p "Bist du dir SICHER, dass du /dev/$PART überschreiben willst? (j/n): " CONFIRM
            if [[ ! "$CONFIRM" =~ ^[Jj]$ ]]; then
                echo -e " Abgebrochen. Wähle eine andere Partition. "
                continue
            fi
        fi
        
        echo "$PART"
        return 0
    done
}

# =================================================================
# HAUPTMENÜ
# =================================================================
clear_screen
echo -e " Wähle den Modus: "
echo "  1) Partition sichern (saveparts)"
echo "  2) Partition wiederherstellen (restoreparts)"
echo "  3) Nur Laufwerke anzeigen"
echo "  0) Beenden"
read -p "Deine Wahl [0-3]: " MODE_CHOICE
case $MODE_CHOICE in
    0)
        echo "Auf Wiedersehen!"
        exit 0
        ;;
    3)
        clear_screen
        show_disks
        press_any_key
        exit 0
        ;;
    1)
        MODE="backup"
        ;;
    2)
        MODE="restore"
        ;;
    *)
        echo -e " Ungültige Auswahl! "
        exit 1
        ;;
esac

# =================================================================
# STEP 1: Backup-Laufwerk finden und mounten
# =================================================================
clear_screen
echo -e " --- Schritt 1: Backup-Laufwerk mounten --- "
show_disks
echo -e " Wähle die Partition, auf der das Backup gespeichert wird: "
echo -e "   (Das ist deine EXTERNE Partition auf Festplatte oder USB-Stick)"
read -p "Backup-Partition (z.B. sdb1): " BACKUP_PART
BACKUP_PART=$(echo "$BACKUP_PART" | sed 's|^/dev/||')
if [ ! -b "/dev/$BACKUP_PART" ]; then
    echo -e " Fehler: /dev/$BACKUP_PART existiert nicht! "
    exit 1
fi

# Mount-Verzeichnis erstellen
mkdir -p "$DEFAULT_BACKUP_DIR" 2>/dev/null
# Prüfen ob schon gemountet
if mount | grep -q "$DEFAULT_BACKUP_DIR"; then
    echo -e " Warnung: $DEFAULT_BACKUP_DIR ist bereits gemountet. "
    read -p "Soll ich es neu mounten? (j/n): " REMOUNT
    if [[ "$REMOUNT" =~ ^[Jj]$ ]]; then
        umount "$DEFAULT_BACKUP_DIR" 2>/dev/null
        mount "/dev/$BACKUP_PART" "$DEFAULT_BACKUP_DIR" || {
            echo -e " Fehler beim Mounten von /dev/$BACKUP_PART auf $DEFAULT_BACKUP_DIR "
            exit 1
        }
    fi
else
    mount "/dev/$BACKUP_PART" "$DEFAULT_BACKUP_DIR" || {
        echo -e " Fehler beim Mounten von /dev/$BACKUP_PART auf $DEFAULT_BACKUP_DIR "
        exit 1
    }
fi
echo -e " ✅ Backup-Laufwerk erfolgreich gemountet auf $DEFAULT_BACKUP_DIR "
# Freien Speicherplatz anzeigen
FREE_SPACE=$(df -h "$DEFAULT_BACKUP_DIR" | tail -1 | awk '{print $4}')
echo -e " Freier Speicherplatz: $FREE_SPACE "
press_any_key

# =================================================================
# STEP 2: Backup-Name festlegen
# =================================================================
clear_screen
echo -e " --- Schritt 2: Backup-Name --- "
echo -e " Gib einen eindeutigen Namen für dein Backup ein. "
echo -e "    (Der Ordner wird unter $DEFAULT_BACKUP_DIR erstellt)"
echo -e "     Vorschlag: parts-backup-$(date +%Y-%m-%d) "
read -p "Backup-Name: " BACKUP_NAME
# Leeren Namen verhindern
while [ -z "$BACKUP_NAME" ]; do
    echo -e " Der Name darf nicht leer sein! "
    read -p "Backup-Name: " BACKUP_NAME
done
# Prüfen ob Backup schon existiert
if [ -d "$DEFAULT_BACKUP_DIR/$BACKUP_NAME" ]; then
    echo -e " Warnung: Ein Backup mit diesem Namen existiert bereits! "
    read -p "Soll ich es überschreiben? (j/n): " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Jj]$ ]]; then
        echo "Bitte wähle einen anderen Namen."
        exit 1
    fi
fi

# =================================================================
# STEP 3: Quelle oder Ziel auswählen (je nach Modus)
# =================================================================
clear_screen
echo -e " --- Schritt 3: Partition auswählen --- "
show_disks
if [ "$MODE" = "backup" ]; then
    echo -e " --- Backup-Modus --- "
    echo -e "Wähle die QUELL-Partition (die, die gesichert werden soll):"
    echo -e " ⚠️  Wähle NICHT die Backup-Partition ($BACKUP_PART)! "
    SOURCE_PART=$(select_target_partition "Quell-Partition wählen:" "$BACKUP_PART")
    TARGET_PART=""  # Wird beim Backup nicht benötigt
else
    echo -e " --- Wiederherstellungs-Modus --- "
    echo -e "Wähle die ZIEL-Partition (die, die überschrieben werden soll):"
    echo -e " ⚠️  ALLE DATEN auf dieser Partition werden gelöscht! "
    echo -e " ⚠️  Wähle NICHT die Backup-Partition ($BACKUP_PART)! "
    TARGET_PART=$(select_target_partition "Ziel-Partition wählen:" "$BACKUP_PART")
    SOURCE_PART=""  # Wird beim Restore nicht benötigt
    
    # Vor der Wiederherstellung prüfen, ob das Ziel noch gemountet ist
    check_and_unmount "/dev/$TARGET_PART"
fi

# =================================================================
# STEP 4: Passwort festlegen
# =================================================================
clear_screen
echo -e " --- Schritt 4: Verschlüsselungspasswort --- "
PASSWORD=$(get_password)

# =================================================================
# STEP 5: Erweiterte Optionen
# =================================================================
clear_screen
echo -e " --- Schritt 5: Erweiterte Optionen (optional) --- "
echo -e " Möchtest du erweiterte Optionen einstellen? "
read -p "Erweiterte Optionen? (j/n) [n]: " ADVANCED
COMPRESSION="$DEFAULT_COMPRESSION"
SPLIT_SIZE="$DEFAULT_SPLIT_SIZE"
CHECKSUM="j"
if [[ "$ADVANCED" =~ ^[Jj]$ ]]; then
    clear_screen
    echo -e " --- Erweiterte Optionen --- "
    echo -e "1) Komprimierung:"
    echo -e "    zstd   = Standard (schnell & gut)"
    echo -e "    gzip   = Langsamer, kleiner"
    echo -e "    lzma   = Sehr langsam, sehr klein"
    echo -e "    none   = Keine Komprimierung"
    read -p "Komprimierung [zstd]: " COMPRESSION
    [ -z "$COMPRESSION" ] && COMPRESSION="zstd"
    echo -e "2) Max. Dateigröße (MB):"
    read -p "Max. Dateigröße [4000]: " SPLIT_SIZE
    [ -z "$SPLIT_SIZE" ] && SPLIT_SIZE="4000"
    echo -e "3) Prüfsumme nach Backup erstellen?"
    read -p "Prüfsumme erstellen? (j/n) [j]: " CHECKSUM
    [ -z "$CHECKSUM" ] && CHECKSUM="j"
fi

# =================================================================
# STEP 6: Befehl zusammenbauen und ausführen
# =================================================================
clear_screen
echo -e " --- Schritt 6: Zusammenfassung & Ausführung --- "
# Parameter für ocs-sr zusammenbauen
OCS_CMD="ocs-sr"
OCS_CMD="$OCS_CMD -z$COMPRESSION"
OCS_CMD="$OCS_CMD -c"
[ "$SPLIT_SIZE" -gt 0 ] && OCS_CMD="$OCS_CMD -k -s $SPLIT_SIZE"
OCS_CMD="$OCS_CMD -enc -pe \"$PASSWORD\""

# 🔥 HIER DIE ÄNDERUNG: saveparts / restoreparts statt savedisk / restoredisk
if [ "$MODE" = "backup" ]; then
    OCS_CMD="$OCS_CMD saveparts \"$BACKUP_NAME\" \"$SOURCE_PART\""
else
    OCS_CMD="$OCS_CMD restoreparts \"$BACKUP_NAME\" \"$TARGET_PART\""
fi

# Zusammenfassung anzeigen
echo -e " Modus:        $MODE (PARTITION)"
if [ "$MODE" = "backup" ]; then
    echo -e " Quelle:       /dev/$SOURCE_PART"
else
    echo -e " Ziel:         /dev/$TARGET_PART"
fi
echo -e " Backup-Name:  $BACKUP_NAME"
echo -e " Backup-Pfad:  $DEFAULT_BACKUP_DIR/$BACKUP_NAME"
echo -e " Komprimierung: $COMPRESSION"
[ "$SPLIT_SIZE" -gt 0 ] && echo -e " Dateigröße:    $SPLIT_SIZE MB"
echo -e " Verschlüsselung: Aktiviert"
echo -e " Ausführender Befehl: "
echo -e " $OCS_CMD "
if [ "$MODE" = "restore" ]; then
    echo -e " ⚠️  WARNUNG: Dies löscht ALLE Daten auf /dev/$TARGET_PART! "
fi
echo -e " Bist du sicher, dass du fortfahren möchtest? "
read -p "(j/n): " FINAL_CONFIRM
if [[ ! "$FINAL_CONFIRM" =~ ^[Jj]$ ]]; then
    echo -e " Abgebrochen. "
    exit 1
fi

# =================================================================
# AUSFÜHRUNG
# =================================================================
echo -e " Starte Backup/Recovery... "
cd "$DEFAULT_BACKUP_DIR" || {
    echo -e " Fehler: Kann nicht nach $DEFAULT_BACKUP_DIR wechseln "
    exit 1
}
eval "$OCS_CMD"

# =================================================================
# NACHBEREINIGUNG
# =================================================================
echo -e " ============================================================ "
echo -e " ✅ Vorgang abgeschlossen! "
echo -e " ============================================================ "
if [[ "$CHECKSUM" =~ ^[Jj]$ ]] && [ "$MODE" = "backup" ]; then
    echo -e " Erstelle Prüfsumme für das Backup... "
    cd "$DEFAULT_BACKUP_DIR/$BACKUP_NAME" 2>/dev/null
    sha256sum * > checksum.sha256
    echo -e " Prüfsumme gespeichert in: checksum.sha256 "
fi
if [ "$MODE" = "backup" ]; then
    BACKUP_SIZE=$(du -sh "$DEFAULT_BACKUP_DIR/$BACKUP_NAME" 2>/dev/null | awk '{print $1}')
    echo -e " Backup-Größe: $BACKUP_SIZE "
fi
echo -e " Möchtest du das Backup-Laufwerk aushängen? "
read -p "(j/n) [n]: " UMOUNT
if [[ "$UMOUNT" =~ ^[Jj]$ ]]; then
    umount "$DEFAULT_BACKUP_DIR" 2>/dev/null
    echo -e " Backup-Laufwerk ausgehängt. "
fi
echo -e " Fertig! Du kannst Clonezilla jetzt beenden. "
press_any_key
exit 0
