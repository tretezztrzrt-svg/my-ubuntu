# paar kurzepumpgun action
alias c='clear' # Terminal leeren
alias q='exit' # Beendet das Terminal mit einem Buchstaben
alias h='history' # Zeigt die Befehlshistorie an
alias x='chmod +x' # Macht eine Skriptdatei schnell ausführbar
# alias r='shutdown -r now' # System sofort neu starten
 

# verzeichnisse ----------------------------------------------------------------
  alias alex='cd /home/alex/' # Wechselt in das Verzeichnis von Benutzer Alex
  alias home='cd /home/alex/' # Wechselt in das Home-Verzeichnis von Alex
  alias vera='cd /media/veracrypt1/' # Wechselt in den VeraCrypt-Mountpoint
  
   alias var='cd /var/' # Wechselt in das Verzeichnis für variable Daten (Logs etc.)
  alias logs='cd /var/log/' # Wechselt in das Verzeichnis für variable Daten (Logs etc.)
   alias doc='cd ~/Documents/' # Wechselt in den Dokumente-Ordner
  alias down='cd ~/Downloads/' # Wechselt in den Down-Ordner
   alias etc='cd /etc/' # Wechselt in das Systemkonfigurations-Verzeichnis

# ------------------------------------------------------------------------------
# cpu hardware os
alias osinfo='lsb_release -a || cat /etc/os-release' # Ermittelt die genaue Linux-Distribution  # ubuntu-proofed
alias cpuinfo='lscpu' # Zeigt detaillierte CPU-Architekturdaten  # ubuntu-proofed
alias hardware='lshw -short' # Generiert eine kompakte Hardware-Übersicht  # ubuntu-proofed

# sys
alias systemstatus='top -b -n 1 | head -n 20' # Schneller Überblick über die Top-Prozesse  # ubuntu-proofed
# doch wieder wer ist zombie als commando?
alias uptime_p='uptime -p' # Zeigt an, wie lange das System bereits läuft  # ubuntu-proofed

# ram
alias free='free -h --si' # Übersicht über belegten/freien RAM-Speicher (SI-Einheiten)
# alias raminfo='free -h' # Zeigt den RAM- und Swap-Verbrauch im lesbaren Format # gleicht oben
# klappt nicht als alias;
# ps aux --sort=-%mem | awk 'NR<=20 {print $2, $3, $4, $11}' | column -t'
# Wer frisst den RAM? column -t weil eh schon awk  # ubuntu-proofed

# hdd platz
alias platz='df -hPT | column -t' # Formatiert Festplattenplatz als saubere Tabelle
alias df='df -h' # Zeigt den freien Festplattenplatz aller Partitionen an
alias dfc='df -hPT | column -t' # Formatiert den Festplattenplatz als sauber ausgerichtete Tabelle
alias platte='df -h' # Festplattenplatz in GB/MB anzeigen
alias space='df -h' # Schnelle Abfrage des freien Festplattenplatzes
alias diskinfo='lsblk' # Listet Blockgeräte und Partitionen als Baum auf
# mess # alias mount='mount | column -t' # Formatiert gemountete Laufwerke lesbar
alias path='echo -e ${PATH//:/\\n}' # Gibt den System-PATH Zeile für Zeile sauber aus

# DAS IST ALLES BUGGY ordner-größen
# alias ordner='du -h' # Zeigt die Größe von Verzeichnissen im lesbaren Format an
# alias sortiert='du -sh * | sort -h' # Zählt Ordnergrößen mit und sortiert sie aufsteigend
# alias bigfiles='du -ah . | sort -rh | head -n 10' # Listet die Top 10 der größten Dateien im aktuellen Ordner
# alias lsize='du -sh * 2>/dev/null | sort -hr | head -n 10' # Top 10 der größten Dateien/Ordner im Verzeichnis

# paket-manager
alias install='sudo apt install ' # Bestätigender Shortcut für Paketinstallation
alias install-alex-start='sudo apt install micro less mc btop htop p7zip-full brasero make git meld'
# alias install-packer-pack='sudo apt install'
alias update='sudo apt update && sudo apt full-upgrade -y && sudo snap refresh && sudo flatpak update -y' # All-in-One Update
alias upgrade="sudo apt update && sudo apt upgrade -y" # System-Update ausführen
alias upgrade-full='sudo apt update && sudo apt full-upgrade -y' # Vollständiges Ubuntu-Systemupgrade
alias autoclean='sudo apt autoremove && sudo apt autoclean' # Bereinigt alte Pakete
alias uninstall='sudo apt remove' # Deinstalliert ein Paket
alias cleanup='sudo apt autoremove -y && sudo apt clean' # Bereinigt ungenutzte Pakete vollständig

# taskmanager
alias killforce='kill -9' # Beendet einen Prozess sofort und unnachgiebig (SIGKILL)
alias exorzist='kill -9' # Sendet das Standard-Beendigungssignal an eine PID (SIGTERM) -> Hinweis: Nutzt SIGKILL (-9)
alias psaux='ps aux' # Zeigt alle laufenden Prozesse im System an

# logs
# journalctl -xe                         # Die neuesten Systemd-Fehlermeldungen analysiert
  alias journal='sudo journalctl -xe'
#buggy# alias all-logs='sudo find / -type f -size 1G -name "*log*" ! -path "*/ *log* /*" -exec grep -Iq . {} \; -print'
# log im namen aber nicht im path quaso VERSTECKTE Logs

#buggy alias all-logs='sudo find / -type f -size -4G \( -name "*log*" -o -path "*/ *log* /*" \) -exec grep -Iq . {} \; -print'
#Log im datei oder ordnernamen #buggy
  alias tailf='tail -f'
  alias tailn='tail -n 50'
  alias cat='less'
  alias more='less'

# kleine Suchen - function suchen gibt es auch ---------------------------------------------------
# alias fh='find . -name' # Schnelle Dateisuche im aktuellen Verzeichnis
 alias fh='find . -type f -exec grep -Iq . {} \; -name' # ohne binär-dateien
alias ftext='grep -rnw . -e' # Sucht rekursiv nach Text in Dateien: ftext "Suchwort"
# alias fh='find . -type f ! -name "*.png" ! -name "*.jpg" ! -name "*.exe" ! -name "*.o" -name' # ohne Binärdateien





# bisschen color
alias grep='grep --color=auto' # Hebt grep-Suchtreffer farblich hervor
alias egrep='egrep --color=auto' # Hebt egrep-Suchtreffer farblich hervor
alias fgrep='fgrep --color=auto' # Hebt fgrep-Suchtreffer farblich hervor
alias dir='dir --color=auto' # Aktiviert Farben für dir
alias vdir='vdir --color=auto' # Aktiviert Farben für vdir
alias l='ls -la --color=auto' # Standard-Spalten-Auflistung für schnelle Orientierung
alias sl='ls -la --color=auto' # Korrigiert Dreher bei 'ls'
alias ls='ls -la --color=auto' # Aktiviert Farben für ls

# korrektur
alias bitte='sudo $(history -p !!)' # Führt den letzten Befehl noch einmal mit Root-Rechten aus
alias fuck='sudo $(history -p !!)' # Wiederholt den letzten Befehl als Root bei vergessenen Rechten
alias please='sudo $(history -p !!)' # Führt letzten Befehl direkt als sudo aus
alias pls='sudo $(fc -ln -1)' # Alternative zur Korrektur bei vergessenem sudo
alias root='su -s' # 'su -i'? 'su -' ?

alias ..='cd .. && ls -la' # Eine Ebene höher navigieren mit automatischer Auflistung
alias cd..='cd .. && ls -la' # Fängt fehlendes Leerzeichen ab und listet Inhalt auf
alias ...='cd ../../ && ls -la' # Zwei Ebenen höher navigieren mit automatischer Auflistung
alias ....='cd ../../../ && ls -la' # Drei Ebenen höher navigieren mit automatischer Auflistung

alias cp='cp -i' # Interaktives Kopieren (Schutz vor Überschreiben)
alias copy='cp -i' # Fragt vor dem Überschreiben beim Kopieren nach

alias mv='mv -i' # Interaktives Verschieben (Schutz vor Überschreiben)
alias move='mv -i' # Fragt vor dem Überschreiben beim Verschieben nach

alias rm='rm -i' # Fragt vor jedem Löschen um Bestätigung
alias remove='rm -i' # Fragt vor dem Löschen nach



# Misc -------------------------------------------------------------------
alias warum='echo "Weil du der Admin bist. Atme tief durch."' # Trost bei Frust
alias why='echo "Weil du der Admin bist. Atme tief durch und prüfe die Logs."' # Bereitstellung von Administrator-Trost

alias pw="openssl rand -base64 16" # Generiert ein sicheres Zufallspasswort

alias matrix='cmatrix -b' # Aktiviert den Matrix-Bildschirmschoner im Terminal # ubuntu-proofed
alias rabbithole='cmatrix -b' # Matrix-Effekt im Terminal (erfordert cmatrix) # ubuntu-proofed

alias hg='history | grep' # Durchsucht den Befehlsverlauf nach Begriffen  # ubuntu-proofed
alias profile_me="history | awk '{print \$2}' | sort | uniq -c | sort -rn | head -n 10" # Analysiert die Top 10 Befehle # ubuntu-proofed

# Schleifen Sammlung
# while true; do clear; ls -la; sleep 1; done # macht es so lange bis unendlich

alias packen-tarfix='tar -czvf' # Komprimiert einen Ordner zu .tar.gz
alias packen-untar='tar -zxvf' # Entpackt eine .tar.gz Datei







# so absuloete systemctl -----gibt es alles schon als service statt systemctl--------------------------------
#alias ctl-dis='sudo systemctl disable' # Deaktiviert einen Dienst für den Systemstart
#alias sys-dis='sudo systemctl disable' # Deaktiviert einen Dienst für den Systemstart

#alias ctl-ena='sudo systemctl enable' # Aktiviert einen Dienst für den Systemstart
#alias sys-ena='sudo systemctl enable' # Aktiviert einen Dienst für den Systemstart

#alias ctl-re='sudo systemctl restart' # Startet einen systemd-Dienst neu
#alias ctl-start='sudo systemctl start' # Startet einen systemd-Dienst
#alias sys-start='sudo systemctl start' # Startet einen systemd-Dienst
#alias ctl-status='sudo systemctl status' # Zeigt den detaillierten Dienst-Status an
#alias sys-status='sudo systemctl status' # Zeigt den detaillierten Dienst-Status an
#alias ctl-stop='sudo systemctl stop' # Stoppt einen laufenden systemd-Dienst
#alias sys-stop='sudo systemctl stop' # Stoppt einen laufenden systemd-Dienst
