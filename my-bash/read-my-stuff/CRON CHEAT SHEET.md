# ⏰ Ubuntu CRON Cheat Sheet

Dein praktischer Leitfaden für die Planung und Automatisierung von Aufgaben unter Ubuntu mit Cron.

---

## 1️⃣ Die wichtigsten CRON-Befehle

| Befehl | Beschreibung |
|--------|-------------|
| `crontab -l` | Listet alle aktiven Cron-Jobs des aktuellen Benutzers auf (List) |
| `crontab -e` | Öffnet die Cron-Tabelle zum Bearbeiten (Edit) — wähle deinen Editor |
| `crontab -r` | Löscht die komplette Cron-Tabelle des aktuellen Benutzers ⚠️ |
| `sudo crontab -u <user> -e` | Bearbeitet die Cron-Tabelle eines anderen Benutzers (benötigt root) |
| `sudo crontab -e` | Bearbeitet die Cron-Tabelle des root-Benutzers (für Systemaufgaben) |

---

## 2️⃣ Der Aufbau einer CRON-Zeile (Syntax)

```
Minute   Stunde   Tag   Monat   Wochentag   Befehl
  0       18      *      *         *       bash /home/alex/backup/backup-n-cron.sh /home/alex/backup/
```

**Format:**
```
┌─────────────── Minute (0-59)
│ ┌───────────── Stunde (0-23)
│ │ ┌─────────── Tag des Monats (1-31)
│ │ │ ┌───────── Monat (1-12)
│ │ │ │ ┌─────── Wochentag (0-7, 0 und 7 = Sonntag)
│ │ │ │ │
* * * * * Befehl
```

---

## 3️⃣ Operatoren & Sonderzeichen

| Zeichen | Beschreibung | Beispiel |
|---------|-------------|----------|
| `*` | Jede/s/n (Wildcard) | `* * * * *` (jede Minute, jede Stunde...) |
| `,` | Liste von Werten | `15,30,45 * * * *` (Minute 15, 30, 45) |
| `-` | Bereich (Range) | `0 9-17 * * *` (Stunde 9 bis 17) |
| `/` | Intervalle (Schritte) | `*/5 * * * *` (alle 5 Minuten) |

---

## 4️⃣ Praktische Beispiele

| Eintrag | Bedeutung |
|---------|-----------|
| `0 4 * * * /backup.sh` | Täglich um 04:00 Uhr morgens ausführen |
| `0 0 * * 1 /script.sh` | Jeden Montag um 00:00 Uhr ausführen |
| `*/15 9-17 * * 1-5 /check.sh` | Mo-Fr, zwischen 9-17 Uhr, alle 15 Minuten |
| `0 12 1 * * /monatsbericht.sh` | Am 1. Tag des Monats um 12:00 Uhr |

---

## 5️⃣ CRON-Shortcuts (Makros)

Anstelle der 5 Felder kannst du auch diese praktischen Abkürzungen nutzen:

| Shortcut | Entspricht | Beschreibung |
|----------|-----------|-------------|
| `@reboot` | — | Einmalig direkt beim Systemstart ausführen |
| `@hourly` | `0 * * * *` | Einmal pro Stunde (immer zur Minute 0) |
| `@daily` | `0 0 * * *` | Einmal täglich (um 00:00 Uhr nachts) |
| `@weekly` | `0 0 * * 0` | Einmal pro Woche (Sonntag um 00:00 Uhr) |
| `@monthly` | `0 0 1 * *` | Einmal im Monat (am 1. Tag um 00:00 Uhr) |

---

## 🔧 Fehlerbehebung & Tipps

### ⚠️ Absolute Pfade nutzen

Cron kennt deine normale System-Umgebung (`$PATH`) nicht. Nutze **IMMER** absolute Pfade für Befehle und Skripte!

**Falsch:**
```bash
python script.py
```

**Richtig:**
```bash
/usr/bin/python3 /home/user/script.py
```

### 📝 Log-Dateien schreiben

Da Cron im Hintergrund läuft, siehst du keine Fehler. Leite Ausgaben in eine Log-Datei um:

```bash
* * * * * /home/user/skript.sh >> /home/user/cron.log 2>&1
```

### 🔍 Cron-Status prüfen

```bash
sudo systemctl status cron
```

### 🔄 Cron-Dienst neu starten (falls notwendig)

```bash
sudo systemctl restart cron
```

---

*Viel Erfolg mit deinen automatisierten Aufgaben! 🚀*