## 📁 Ordnerstruktur und deren Inhalte

Die meisten Ordner sind thematisch sortiert und enthalten Skripte oder Konfigurationsdateien für bestimmte Aufgabenbereiche.

- **`backup/`**: Enthält vermutlich Skripte oder Konfigurationen für **Backup-Routinen**, z.B. um wichtige Ordner zu sichern oder zu komprimieren.

- **`check-info/`**: Hier liegen Skripte, die **Systeminformationen** abrufen, wie z.B. Hardware-Daten (`hwinfo`), Netzwerkstatus (`net-tools`) oder Speicherbelegung (`df`, `free`). Passt zu deinen Aliases `diskinfo`, `ram` oder `platz`.

- **`lazy-treasures/`**: Der Name deutet auf eine Sammlung von **"Schätzen für Faule"** hin. Das sind wahrscheinlich sehr spezifische, komplexe Befehle oder Skripte, die du oft brauchst, aber nicht jedes Mal neu tippen möchtest – der Kern deiner "Bash-Toolbox".

- **`my-bash/`**: Der zentrale Ordner für deine **Bash-Konfiguration**. Hier liegt vermutlich deine Haupt-`.bashrc` oder andere Dateien, in denen all deine Aliases und Funktionen definiert sind (wie sie in der Tabelle in der `README.md` aufgelistet sind).

- **`read-my-stuff/`**: Enthält wahrscheinlich Skripte, um **Logs oder Textdateien schnell zu durchsuchen oder anzuzeigen**, z.B. mit `grep`, `cat` oder `less`. Der Name ist eine direkte Anspielung auf deine Aliases `log` oder `logs`.

- **`script/`**: Ein allgemeiner Ordner für **eigene, größere Shell-Skripte**, die über einfache Aliases hinausgehen. Hier landen komplexere Automatisierungen.

- **`trash/`**: Ein Ordner für **temporäre Dateien oder Skripte**, die du testest oder die noch nicht fertig sind. Er dient als eine Art "Ablage" für Ideen.

- **`treesize/`**: Hier geht es um **Speicherplatz-Analyse**. Enthält Skripte, die die Ordnerstruktur nach Größe durchsuchen (`du`, `ncdu`), ähnlich deinem Alias `platz`.

---

## 📈 Wohin die Reise geht (Trends & Ziele)

Anhand der Dateien und deiner Notizen am Ende der `README.md` lassen sich einige Hauptziele und Richtungen erkennen:

1. **Zentralisierung und Standardisierung**  
   Du baust dir ein modulares, persönliches Toolkit, das du auf jedem Ubuntu-System schnell einsetzen kannst. Die Ordner sind thematisch sauber getrennt.

2. **Maximale Effizienz im Terminal**  
   Im Fokus steht, wiederkehrende Aufgaben mit kürzestmöglichen Befehlen (`alex`, `c`, `update`) oder mächtigen Tools (`btop`, `ncdu`, `micro`) zu erledigen.

3. **GUI-Verwaltung für Server**  
   Du testest und integrierst Web-GUIs wie **Cockpit** und **Webmin**, um Server auch über eine grafische Oberfläche verwalten zu können – besonders nützlich für komplexe Einstellungen.

4. **Lokale KI und Entwicklung**  
   Der letzte Punkt ("todo") zeigt dein Interesse an **lokalen KI-Modellen** (mit LM Studio) und **alternativen Code-Editoren** (OpenCode, Roo Code). Das Ziel ist, unabhängiger von Cloud-APIs zu werden und mehr Kontrolle über die Entwicklungsumgebung zu haben.






# 🧰 Meine Bash-Toolbox – Vollständige Edition

## 📂 Aliases – Alle Schnellbefehle im Überblick

| Alias | Befehl | Beschreibung |
| :--- | :--- | :--- |
| `alex` / `home` | `cd /home/alex/` | Wechselt in das Home-Verzeichnis von Alex |
| `vera` | `cd /media/veracrypt1/` | Wechselt in den VeraCrypt-Mountpoint |
| `var` | `cd /var/` | Wechselt ins Verzeichnis für variable Daten (Logs etc.) |
| `log` / `logs` | `cd /var/log/` | Wechselt direkt in die Logs |
| `etc` | `cd /etc/` | Wechselt ins Systemkonfigurations-Verzeichnis |
| `dvd` / `cd2` | `cd .. && ls -la` | Eine Ebene höher mit automatischer Auflistung |
| `c` | `clear` | Terminal leeren |
| `q` | `exit` | Terminal mit einem Buchstaben beenden |
| `h` | `history` | Befehlshistorie anzeigen |
| `x` | `chmod +x` | Skriptdatei schnell ausführbar machen |
| `reboot` | `shutdown -r now` | System sofort neu starten |
| `systemstatus` | `top -b -n 1 \| head -n 20` | Schneller Überblick über die Top-Prozesse |
| `uptime_p` | `uptime -p` | Zeigt an, wie lange das System bereits läuft |
| `ram` | `free -h --si` | Übersicht über belegten/freien RAM |
| `platz` | `df -hPT \| column -t` | Festplattenplatz als saubere Tabelle |
| `platte` | `df -h` | Festplattenplatz in GB/MB anzeigen |
| `diskinfo` | `lsblk` | Blockgeräte und Partitionen als Baum anzeigen |
| `install` | `sudo apt install` | Kurzer Shortcut für Paketinstallationen |
| `uninstall` | `sudo apt remove` | Paket deinstallieren |
| `update` | `sudo apt update && sudo apt full-upgrade -y && sudo snap refresh && sudo flatpak update -y` | **All-in-One Update** für apt, snap & flatpak |
| `upgrade` | `sudo apt update && sudo apt upgrade -y` | System-Update ausführen |
| `upgrade-full` | `sudo apt update && sudo apt full-upgrade -y` | Vollständiges Ubuntu-Systemupgrade |
| `killforce` / `exorzist` | `kill -9` | Prozess sofort und unnachgiebig beenden (SIGKILL) |
| `psaux` / `psax` | `ps -aux` | Alle laufenden Prozesse anzeigen |
| `top` / `btop` / `htop` | `btop` | **Try this:** `btop` ist der moderne Systemmonitor |
| `grep` | `grep --color=auto` | Suchtreffer farblich hervorheben |
| `egrep` | `egrep --color=auto` | Suchtreffer farblich hervorheben (erweiterte Regex) |
| `install-common` | `sudo apt install cmatrix micro less mc btop p7zip-full brasero make git meld curl net-tools hwinfo gedit` | **Try this:** Meine Must-Have-Pakete auf einen Schlag |
| `cockpit-install` | `sudo apt install cockpit` | **Try this:** Cockpit per Shortcut installieren |
| **Cockpit** | Moderne, schlanke Weboberfläche – perfekt für den schnellen Überblick | `sudo apt install cockpit`<br>Zugang: `https://<server-ip>:9090` |
| **Webmin** | Der Klassiker – extrem viele Einstellungsmöglichkeiten über eine GUI | `curl -o webmin-setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh && sudo sh webmin-setup-repo.sh && sudo apt-get install webmin --install-recommends`<br>Zugang: `https://<server-ip>:10000` |

---

## 🛠️ Funktionen – Die echten Helfer im Alltag

| Funktion | Nutzung | Beschreibung |
| :--- | :--- | :--- |
| `hello <ordner>` | `hello /etc` | Öffnet Ordner, zeigt Arbeitsverzeichnis (`pwd`) und listet Inhalt (`ls -la`) |
| `back` | `back` | Geht eine Ebene zurück (`cd ..`), zeigt `pwd` und listet Inhalt (`ls -la`) |
| `make-dir <name>` | `make-dir projekt` | Erstellt Ordner (`mkdir -p`) und wechselt sofort hinein (`cd`) |
| `entpack <datei.7z>` | `entpack archiv.7z` | Entpackt `.7z`-Archive (benötigt `p7zip-full`) |
| `pack <quelle> <ziel>` | `pack ordner backup` | Packt Ordner/Datei als `.7z` (Standardkompression) |
| `pack-harder <quelle> <ziel>` | `pack-harder ordner backup` | Packt mit maximaler Kompression (`-mx=9`) |
| `tarfix <name.tar.gz> <dateien...>` | `tarfix backup.tar.gz datei1 datei2` | Erstellt `.tar.gz`-Archive |
| `untar <archiv.tar.gz>` | `untar backup.tar.gz` | Entpackt `.tar.gz`-Archive |

---

## 🔥 Kurzübersicht – Was wann?

| Situation | Tool |
| :--- | :--- |
| **Schnell Config-Datei editieren** | `micro` |
| **Dateien verwalten (Terminal)** | `mc` oder `ranger` oder `nnn` |
| **Superschnell durch Verzeichnisse navigieren** | `nnn` |
| **Systemlast checken** | `glances` oder `btop` |
| **Speicherfresser finden** | `ncdu` | 'treesize ersatz?'
| **Befehl nicht parat?** | `tldr <befehl>` |
| **Server per GUI verwalten** | `cockpit` oder `webmin` |



---


## todo


o stupid copilot on github, dont care about, so


o 1. Use Opencode (CLI or VS Code Extension) nope


o 2. Use Roo Code (VS Code Extension), should try


o 3. Use LM Studio + Local Models (Optional Hybrid), working on github can reveal that damn apis...so local is the king
