#!/usr/bin/env bash
set -euo pipefail

# ================================================================
# STEP 1 – Frische Ubuntu-Installation (26.04+)
# - System-Update, Git, VeraCrypt, VMware
# - Repository klonen
# - GNOME: Dunkelmodus, Nachtmodus, Dock unten
# - Statische IP aus aktueller DHCP-Lease
# - sudo timeout auf 60 Minuten
# - Bash-History vergrößern
# - Eigene Aliase/Funktionen kopieren
# ================================================================
# ---------- Schritt 1: Installationen ----------
echo ""
echo "[1/10] System-Update, Git, VeraCrypt & VMware installieren ..."
sudo apt update -qq
sudo apt install -y git
mkdir -p downloads && cd downloads
DEB_URL="https://launchpad.net/veracrypt/trunk/1.26.29/+download/veracrypt-1.26.29-Ubuntu-26.04-amd64.deb"
VMWARE_URL="https://archive.org/download/vmware-workstation-pro-full-26h1-25388281.x86_64/VMware-Workstation-Full-26H1-25388281.x86_64.bundle"
wget -q --show-progress "$DEB_URL"
wget -q --show-progress "$VMWARE_URL"
DEB_FILE="$(basename "$DEB_URL")"
VMWARE_FILE="$(basename "$VMWARE_URL")"
sudo apt-get install -y ./"$DEB_FILE"
sudo apt-get -f install -y
chmod +x "$VMWARE_FILE"
sudo ./"$VMWARE_FILE"   # ggf. interaktiv – Lizenz akzeptieren
cd ..
rm -rf downloads
sudo apt-get autoremove -y -qq && sudo apt-get clean -y -qq
echo "   ✅ [1/10] Fertig."


echo ""
echo "[2/10] Klone Repository 'ubuntu-learning' ..."
git clone https://github.com/tretezztrzrt-svg/ubuntu-learning
cd ubuntu-learning
echo "   ✅ [2/10] Fertig."

# ---------- Schritt 3: GNOME – Dunkelmodus ----------
echo ""
echo "[3/10] Aktiviere Dunkelmodus ..."
gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || \
    gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark 2>/dev/null || true
echo "   ✅ [3/10] Fertig."

# ---------- Schritt 4: GNOME – Nachtmodus ----------
echo ""
echo "[4/10] Aktiviere Nachtmodus (4000K) ..."
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000 2>/dev/null || true
echo "   ✅ [4/10] Fertig."

# ---------- Schritt 5: GNOME – Dock unten ----------
echo ""
echo "[5/10] Verschiebe Dock an den unteren Rand ..."
if gsettings list-schemas | grep -q "org.gnome.shell.extensions.dash-to-dock"; then
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
    echo "   ✅ [5/10] Fertig."
else
    echo "   ⚠️  [5/10] 'dash-to-dock' nicht gefunden – übersprungen."
fi



# ---------- Schritt 7: Statische IP ----------
echo ""
echo "[7/10] Übernehme aktuelle IP als statische Adresse ..."
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
if [ -z "$INTERFACE" ]; then
    echo "   ❌ [7/10] Kein aktives Interface – übersprungen."
else
    CURRENT_IP=$(ip -4 addr show "$INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}/\d+' | head -1)
    if [ -z "$CURRENT_IP" ]; then
        echo "   ❌ [7/10] Keine IPv4 auf $INTERFACE – übersprungen."
    else
        IP_ADDR=$(echo "$CURRENT_IP" | cut -d'/' -f1)
        PREFIX=$(echo "$CURRENT_IP" | cut -d'/' -f2)
        GATEWAY=$(ip route | grep default | awk '{print $3}')
        DNS=$(nmcli dev show "$INTERFACE" 2>/dev/null | grep 'IP4.DNS' | awk '{print $2}' | head -1)
        [ -z "$DNS" ] && DNS=$(grep -v '^#' /etc/resolv.conf | grep nameserver | awk '{print $2}' | head -1)
        [ -z "$DNS" ] && DNS="8.8.8.8"

        if systemctl is-active --quiet NetworkManager; then
            CONN_NAME=$(nmcli -t -f NAME,DEVICE con show --active | grep ":$INTERFACE$" | cut -d: -f1)
            if [ -n "$CONN_NAME" ]; then
                nmcli con mod "$CONN_NAME" ipv4.method manual
                nmcli con mod "$CONN_NAME" ipv4.addresses "$IP_ADDR/$PREFIX"
                nmcli con mod "$CONN_NAME" ipv4.gateway "$GATEWAY"
                nmcli con mod "$CONN_NAME" ipv4.dns "$DNS"
                nmcli con mod "$CONN_NAME" ipv4.ignore-auto-dns yes
                nmcli con down "$CONN_NAME" && nmcli con up "$CONN_NAME"
                echo "   ✅ [7/10] Statische IP $IP_ADDR/$PREFIX gesetzt."
            else
                echo "   ⚠️  [7/10] Keine NM-Verbindung für $INTERFACE – manuell anpassen."
            fi
        else
            echo "   ⚠️  [7/10] NetworkManager nicht aktiv – Netplan manuell."
        fi
    fi
fi

# ---------- Schritt 8: Bash-History ----------
echo ""
echo "[8/10] Erhöhe Historiengröße in ~/.bashrc ..."
BASHRC="$HOME/.bashrc"
if grep -q '^HISTSIZE=' "$BASHRC"; then
    sed -i 's/^HISTSIZE=.*/HISTSIZE=10001/' "$BASHRC"
else
    echo 'HISTSIZE=10001' >> "$BASHRC"
fi
if grep -q '^HISTFILESIZE=' "$BASHRC"; then
    sed -i 's/^HISTFILESIZE=.*/HISTFILESIZE=20001/' "$BASHRC"
else
    echo 'HISTFILESIZE=20001' >> "$BASHRC"
fi
echo "   ✅ [8/10] HISTSIZE=10001, HISTFILESIZE=20001."

# ---------- Schritt 9: sudo timestamp_timeout auf 60 Minuten ----------
echo ""
echo "[9/10] Setze sudo timestamp_timeout auf 60 Minuten ..."
SUDOERS="/etc/sudoers"
# Ersetze "Defaults env_reset" durch "Defaults env_reset, timestamp_timeout=60"
if grep -q '^Defaults\s\+env_reset\s*$' "$SUDOERS"; then
    sudo sed -i 's/^Defaults\s\+env_reset\s*$/Defaults env_reset, timestamp_timeout=60/' "$SUDOERS"
elif grep -q '^Defaults\s\+env_reset,' "$SUDOERS"; then
    if ! grep -q '^Defaults\s\+env_reset,.*timestamp_timeout' "$SUDOERS"; then
        sudo sed -i 's/^Defaults\s\+env_reset\s*,*/Defaults env_reset, timestamp_timeout=60, /' "$SUDOERS"
    fi
else
    echo "Defaults env_reset, timestamp_timeout=60" | sudo tee -a "$SUDOERS" > /dev/null
fi

# Syntax prüfen
if sudo visudo -c; then
    echo "   ✅ [9/10] sudo timeout auf 60 Minuten gesetzt."
else
    echo "   ❌ [9/10] Fehler in sudoers-Datei – bitte manuell prüfen."
    exit 1
fi

# ---------- Schritt 10: Aliase & Funktionen kopieren ----------
echo ""
echo "[10/10] Kopiere Aliase/Funktionen aus ./my-bash/ nach ~/ ..."
MY_BASH_DIR="./my-bash"
if [ -d "$MY_BASH_DIR" ]; then
    [ -f "$MY_BASH_DIR/.bash_aliases.sh" ] && cp -f "$MY_BASH_DIR/.bash_aliases.sh" "$HOME/" && echo "   ✅ .bash_aliases.sh überschrieben."
    [ -f "$MY_BASH_DIR/.bash_functions" ] && cp -f "$MY_BASH_DIR/.bash_functions" "$HOME/" && echo "   ✅ .bash_functions überschrieben."
else
    echo "   ⚠️  [10/10] Verzeichnis '$MY_BASH_DIR' nicht gefunden – nichts kopiert."
fi

# ---------- Abschluss ----------
echo "📋 Zusammenfassung:"
echo "   • Dunkelmodus:                AKTIV"
echo "   • Nachtmodus:                 AKTIV"
echo "   • Dock-Position:              Unten"
echo "   • RDP-Server:                 AKTIV (Port 3389)"
echo "   • Statische IP:               ${IP_ADDR:-nicht gesetzt}/${PREFIX:-}"
echo "   • sudo timeout:               60 Minuten"
echo "   • HISTSIZE:                   10001"
echo "   • HISTFILESIZE:               20001"
echo "   • Aliase/Funktionen:          ~/.bash_aliases.sh und ~/.bash_functions (überschrieben)"
echo ""
echo "💡 Jetzt REBOOT durchführen – danach mit Schritt 2 fortfahren."
echo "   (Die Bash-Änderungen werden erst nach einem neuen Terminal sichtbar.)"
echo ""
