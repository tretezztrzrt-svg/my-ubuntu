📁 DIE KURZE ORDNER-BIBEL (NUR DAS NÖTIGE)

| Pfad | Zweck | Besonderheit |
| :--- | :--- | :--- |
| `/` | Wurzel. | Darunter hängt alles. |
| `/etc/` | Die ganze System-Config. | Textdateien. Bei Ubuntu liegt hier 95 % aller Einstellungen. |
| `/var/` | Veränderliche Daten. | `/var/log/` (Logs), `/var/cache/apt/archives/` (Deb-Pakete). Frisst Speicher. |
| `/usr/` | Anwendungen & Bibliotheken. | Hier liegen Programme, die nicht zum Booten zwingend nötig sind (`/usr/bin/`). |
| `/home/` | User-Daten. | Normale Benutzer. |
| `/root/` | Home des Admin (root). | Liegt bewusst *nicht* unter `/home/` (falls `/home` nicht mountet). |
| `/boot/` | Kernel & Initramfs. | Wenn voll → System startet nicht mehr. |
| `/mnt/` & `/media/` | Einhängepunkte. | `/media/` = automatisch (USB), `/mnt/` = manuell (Admin). |

---

⚡ PRAXIS-CHEAT-SHEET (SO MACHT MAN ES WIRKLICH)

**1. Configs finden (nicht faul, sondern zielgerichtet):**

```bash
# So sucht man .conf-Dateien (NUR in /etc, nicht ganz /)
find /etc/ -type f -name "*.conf" 2>/dev/null

# Noch besser: Inhalt durchsuchen (z.B. nach "ListenAddress")
grep -r "ListenAddress" /etc/ --include="*.conf"
