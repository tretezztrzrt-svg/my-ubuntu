# Ubuntu Package Cheat Sheet (apt / snap / flatpak / AppImage)

Ein kompakter Spickzettel für die wichtigsten Paket- und App-Formate unter Ubuntu sowie nützliche Befehle zur Verwaltung von Speicherplatz, Versionen und Diensten.

Kurz gesagt: Snap wird von vielen Nutzern eher kritisch gesehen, vor allem wegen Performance, Ressourcenverbrauch und etwas unflexibler Integration. Trotzdem ist es weiterhin praktisch, wenn man eine einfache, einheitliche Installation will.

## 1. Der direkte Vergleich: apt vs. snap vs. flatpak

| Aktion | apt | snap | flatpak |
| --- | --- | --- | --- |
| Suchen | `apt search <name>` | `snap find <name>` | `flatpak search <name>` |
| Installieren | `sudo apt install <name>` | `sudo snap install <name>` | `flatpak install flathub <name>` |
| Entfernen | `sudo apt remove <name>` | `sudo snap remove <name>` | `flatpak uninstall <name>` |
| Updates | `sudo apt update && sudo apt upgrade` | `sudo snap refresh` | `flatpak update` |
| Installiert | `apt list --installed` | `snap list` | `flatpak list` |
| Informationen | `apt show <name>` | `snap info <name>` | `flatpak info <name>` |
| Sandbox | Nein | Ja, stark isoliert | Ja, isoliert |

> AppImages sind in der Regel nicht sandboxed, sondern eher portable Einzeldateien.

## 2. Fortgeschrittene Snap-Befehle

### Versionen verwalten und Fehlerbehebung

- `snap refresh <app-name>`
- `snap revert <app-name>`

### Dienste (Daemons) steuern

- `snap services <app-name>`
- `sudo snap stop --disable <app-name>.<dienst>`
- `sudo snap start --enable <app-name>.<dienst>`

## 3. Flatpak-Befehle

### Flatpak zuerst installieren

- `sudo apt install flatpak`

### Flathub als Quelle hinzufügen

- `flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo`

### App installieren

- `flatpak install flathub <app-id>`

### App aktualisieren

- `flatpak update`

### App entfernen

- `flatpak uninstall <app-id>`

### Installierte Flatpaks auflisten

- `flatpak list`

## 4. Speicherplatz bereinigen

### Snap-Versionen begrenzen

- `sudo snap set system refresh.retain=2`

### Alle Snap-Versionen auflisten

- `snap list --all`

### Alte Versionen manuell löschen

- `sudo snap remove <app-name> --revision=<nummer>`

## 5. Berechtigungen (Interfaces) verwalten

### Aktuelle Berechtigungen ansehen

- `snap connections <app-name>`

### Berechtigung erlauben

- `sudo snap connect <app-name>:<interface>`

### Berechtigung entziehen

- `sudo snap disconnect <app-name>:<interface>`

## 6. AppImage-Hinweis

AppImages sind einzelne Portable-Apps mit der Endung `.appimage`.

### Ausführen unter Ubuntu

- `chmod +x dateiname.AppImage`
- `./dateiname.AppImage`

Wenn du willst, kannst du sie auch mit einem Doppelklick starten, sofern die Dateirechte korrekt gesetzt sind.
