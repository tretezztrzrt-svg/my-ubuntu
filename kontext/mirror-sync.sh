#!/bin/bash
# SmartMirrorSync - Nautilus Context Menu Script
# Mit grafischer Auswahl und hübscher Ausgabe
# Installation: Kopiere nach ~/.local/share/nautilus/scripts/ und chmod +x

# === KONFIGURATION ===
LOG_DIR="$HOME/.smart_mirror_logs"
MAX_LOG_DAYS=7
USE_ZENITY=true  # Für grafische Dialoge

# === FUNKTIONEN ===
show_banner() {
    clear
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                🌀 SMART MIRROR SYNC                          ║"
    echo "║                Intelligente Synchronisation                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
}

check_requirements() {
    # Prüfe ob alle Tools vorhanden sind
    local missing_tools=""
    
    for tool in rsync tree; do
        if ! command -v $tool &> /dev/null; then
            missing_tools="$missing_tools $tool"
        fi
    done
    
    if [ -n "$missing_tools" ]; then
        if $USE_ZENITY; then
            zenity --error --width=400 \
                --text="Folgende Tools fehlen:\n$missing_tools\n\nInstalliere mit:\nsudo apt install$missing_tools"
        else
            echo "❌ Fehlende Tools:$missing_tools"
            echo "   Installiere mit: sudo apt install$missing_tools"
        fi
        exit 1
    fi
}

select_target_folder() {
    # Zielordner auswählen (grafisch mit Zenity)
    if $USE_ZENITY; then
        TARGET=$(zenity --file-selection \
            --title="Zielordner für Mirror auswählen" \
            --directory \
            --filename="$HOME/")
        
        if [ -z "$TARGET" ]; then
            zenity --info --width=300 \
                --text="Kein Zielordner ausgewählt.\nVorgang abgebrochen."
            exit 0
        fi
    else
        echo -n "📁 Zielordner eingeben: "
        read -r TARGET
        [ -z "$TARGET" ] && exit 0
    fi
    
    # Zielordner existiert nicht? Erstellen fragen
    if [ ! -d "$TARGET" ]; then
        if $USE_ZENITY; then
            zenity --question --width=400 \
                --text="Zielordner existiert nicht:\n$TARGET\n\nSoll er erstellt werden?"
            
            if [ $? -eq 0 ]; then
                mkdir -p "$TARGET"
            else
                exit 0
            fi
        else
            echo "❌ Zielordner existiert nicht: $TARGET"
            exit 1
        fi
    fi
}

show_selection_summary() {
    # Zeige ausgewählte Ordner an
    show_banner
    
    echo "📋 AUSGEWÄHLTE QUELLORDNER:"
    echo "┌────────────────────────────────────────────┐"
    local count=1
    for folder in "${SELECTED_FOLDERS[@]}"; do
        folder_name=$(basename "$folder")
        echo "│ $count. $folder_name"
        echo "│    📍 $(echo "$folder" | sed 's|'$HOME'|~|')"
        count=$((count + 1))
    done
    echo "└────────────────────────────────────────────┘"
    echo ""
    
    echo "🎯 ZIELORDNER:"
    echo "   📍 $(echo "$TARGET" | sed 's|'$HOME'|~|')"
    echo ""
    
    if $USE_ZENITY; then
        zenity --question --width=500 \
            --title="Bestätigung" \
            --text="Sollen ${#SELECTED_FOLDERS[@]} Ordner nach\n'$TARGET' gespiegelt werden?\n\n⚠️  ACHTUNG: Existierende Dateien im Ziel werden überschrieben!"
        
        [ $? -ne 0 ] && exit 0
    else
        echo -n "Fortfahren? (j/N): "
        read -r confirm
        [[ ! $confirm =~ ^[JjYy]$ ]] && exit 0
    fi
}

create_log_file() {
    # Log-Verzeichnis erstellen
    mkdir -p "$LOG_DIR"
    
    # Log-Datei mit Zeitstempel
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    LOG_FILE="$LOG_DIR/mirror_${TIMESTAMP}.log"
    
    # ASCII-Art Header für Log
    cat > "$LOG_FILE" << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                SMART MIRROR SYNC LOG                         ║
╚══════════════════════════════════════════════════════════════╝
EOF
    
    echo "Datum: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
}

sync_folder() {
    local source="$1"
    local target="$2"
    local folder_name="$(basename "$source")"
    local start_time=$(date +%s)
    
    # Ziel-Pfad für diesen Ordner
    local dest_path="$target/$folder_name"
    
    echo -e "\n🔄 SYNCHRONISIERE: $folder_name" | tee -a "$LOG_FILE"
    echo "   Quelle: $source" >> "$LOG_FILE"
    echo "   Ziel:   $dest_path" >> "$LOG_FILE"
    echo "   Start:  $(date '+%H:%M:%S')" >> "$LOG_FILE"
    
    # rsync mit Progress-Bar und Details
    rsync -avh --delete --progress --stats \
        --info=progress2,name0 \
        "$source/" "$dest_path/" >> "$LOG_FILE" 2>&1
    
    local exit_code=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Statistik für diesen Ordner
    local source_count=$(find "$source" -type f 2>/dev/null | wc -l)
    local source_size=$(du -sh "$source" 2>/dev/null | cut -f1 || echo "N/A")
    
    echo "   Ende:   $(date '+%H:%M:%S')" >> "$LOG_FILE"
    echo "   Dauer:  ${duration}s" >> "$LOG_FILE"
    echo "   Status: $(if [ $exit_code -eq 0 ]; then echo '✅ Erfolg'; else echo '❌ Fehler'; fi)" >> "$LOG_FILE"
    
    return $exit_code
}

#!/bin/bash
# SmartMirrorSync - Nautilus Context Menu Script
# [Vorheriger Code bleibt gleich...]

# [Hier fortfahren wo der vorherige Code aufgehört hat...]

show_progress() {
    # Grafischen Fortschrittsbalken anzeigen
    if $USE_ZENITY; then
        (
            local total=${#SELECTED_FOLDERS[@]}
            local current=0
            
            for folder in "${SELECTED_FOLDERS[@]}"; do
                current=$((current + 1))
                percentage=$((current * 100 / total))
                
                folder_name=$(basename "$folder")
                echo "$percentage"
                echo "# Synchronisiere: $folder_name ($current/$total)"
                
                # Eigentliche Synchronisation (im Hintergrund)
                sync_folder "$folder" "$TARGET" &
                SYNC_PID=$!
                
                # Warten auf Abschluss
                wait $SYNC_PID
                
                if [ $? -ne 0 ]; then
                    echo "100"
                    echo "# Fehler bei $folder_name"
                    return 1
                fi
            done
        ) | zenity --progress \
            --title="Smart Mirror Sync" \
            --text="Starte Synchronisation..." \
            --percentage=0 \
            --auto-close \
            --width=400
            
        return $?
    else
        # Textbasierter Fortschritt
        local total=${#SELECTED_FOLDERS[@]}
        local current=0
        
        for folder in "${SELECTED_FOLDERS[@]}"; do
            current=$((current + 1))
            folder_name=$(basename "$folder")
            
            echo -e "\n📦 [$current/$total] $folder_name"
            echo "   └─▶ Starte Mirror..."
            
            sync_folder "$folder" "$TARGET"
            
            if [ $? -eq 0 ]; then
                echo "   └─✅ Erfolgreich"
            else
                echo "   └─❌ Fehler"
            fi
        done
    fi
}

show_result() {
    # Ergebnisse schön anzeigen
    show_banner
    
    # Baumansicht des Ziels
    echo "🌳 ZIELSTRUKTUR NACH SYNCHRONISATION:"
    echo "┌────────────────────────────────────────────┐"
    
    if command -v tree &> /dev/null; then
        tree "$TARGET" --dirsfirst -L 2 2>/dev/null || \
            find "$TARGET" -maxdepth 2 -type d | sed 's|^|    |'
    else
        find "$TARGET" -maxdepth 2 -type d | sed 's|^|    |'
    fi
    
    echo "└────────────────────────────────────────────┘"
    echo ""
    
    # Zusammenfassung
    echo "📊 ZUSAMMENFASSUNG:"
    echo "┌────────────────────────────────────────────┐"
    echo "│ Gesamte Ordner: ${#SELECTED_FOLDERS[@]}"
    echo "│ Zielpfad:       $(echo "$TARGET" | sed 's|'$HOME'|~|')"
    echo "│ Log-Datei:      $(echo "$LOG_FILE" | sed 's|'$HOME'|~|')"
    echo "│ Zeit:           $(date '+%H:%M:%S')"
    echo "└────────────────────────────────────────────┘"
    echo ""
    
    # rsync Statistik extrahieren
    if [ -f "$LOG_FILE" ]; then
        echo "📈 DETAILS AUS LOG:"
        echo "┌────────────────────────────────────────────┐"
        grep -A5 "Number of files\|Total transferred\|sent\|received" "$LOG_FILE" | \
            sed 's/^/│ /'
        echo "└────────────────────────────────────────────┘"
    fi
    
    # Grafische Erfolgsmeldung
    if $USE_ZENITY; then
        zenity --info --width=500 \
            --title="Synchronisation abgeschlossen" \
            --text="✅ Mirror-Synchronisation erfolgreich!\n\n• ${#SELECTED_FOLDERS[@]} Ordner gespiegelt\n• Ziel: $TARGET\n• Log: $(basename "$LOG_FILE")\n\nDas Terminal bleibt für Details geöffnet."
    fi
}

cleanup_old_logs() {
    # Alte Log-Dateien löschen
    find "$LOG_DIR" -name "mirror_*.log" -type f -mtime +$MAX_LOG_DAYS -delete 2>/dev/null
}

# === HAUPT PROGRAMM ===
main() {
    # Prüfe, ob Ordner ausgewählt wurden
    if [ $# -eq 0 ]; then
        if $USE_ZENITY; then
            zenity --error --width=400 \
                --text="Keine Ordner ausgewählt!\n\nBitte im Nautilus Ordner auswählen,\ndann Rechtsklick → Scripts → SmartMirrorSync"
        else
            echo "❌ Keine Ordner ausgewählt!"
            echo "   Wähle im Nautilus Ordner aus, dann Rechtsklick → Scripts → SmartMirrorSync"
        fi
        exit 1
    fi
    
    # Ausgewählte Ordner speichern
    SELECTED_FOLDERS=("$@")
    
    # Banner zeigen
    show_banner
    
    # Voraussetzungen prüfen
    check_requirements
    
    # Zielordner auswählen
    select_target_folder
    
    # Auswahl bestätigen
    show_selection_summary
    
    # Log-Datei erstellen
    create_log_file
    
    # Synchronisation starten
    echo "🚀 STARTE SYNCHRONISATION..." | tee -a "$LOG_FILE"
    show_progress
    SYNC_RESULT=$?
    
    # Ergebnisse anzeigen
    show_result
    
    # Aufräumen
    cleanup_old_logs
    
    # Terminal offen halten (optional)
    if ! $USE_ZENITY; then
        echo ""
        echo -n "Drücke Enter zum Beenden..."
        read -r
    fi
    
    exit $SYNC_RESULT
}

# Skript ausführen
main "$@"
