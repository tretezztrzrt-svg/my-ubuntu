# Bash Aliases & Functions

## 📁 Navigation

| Alias | Befehl |
|-------|--------|
| `alex` | `cd /home/alex/` |
| `home` | `cd /home/alex/` |
| `vera` | `cd /media/veracrypt1/` |
| `dvd` / `cd2` | `cd .. && ls -la` |
| `var` | `cd /var/` |
| `log` / `logs` | `cd /var/log/` |
| `etc` | `cd /etc/` |

**Funktionen:**
- `hello <ordner>` - Öffnet Ordner, zeigt pwd und ls -la
- `back` - cd .., pwd, ls -la
- `make-dir <name>` - mkdir -p + cd

## 📦 Compression

**Funktionen:**
- `entpack <file.7z>` - Entpackt .7z Archive
- `pack <quelle> [ziel]` - Packt zu .7z (Standard)
- `pack-harder <quelle> [ziel]` - Packt zu .7z (-mx=9)
- `tarfix <archiv.tar.gz> <datei...>` - Erstellt tar.gz
- `untar <archiv.tar.gz>` - Entpackt tar.gz

## 💾 Backup

**Funktionen:**
- `backup <pfad>` - Backup zu ~/backup (getrennt: dir/file), mit Log
- `trash <pfad>` - Verschiebt zu ~/trash, mit Log

## 🔧 System

| Alias | Befehl |
|-------|--------|
| `c` | `clear` |
| `q` | `exit` |
| `h` | `history` |
| `x` | `chmod +x` |
| `reboot` | `shutdown -r now` |

**Funktionen:**
- `service {start\|stop\|restart\|status\|enable\|disable} <service>` - systemctl wrapper
- `please [!!]` / `pls` - Letzter Befehl mit sudo
- `fuck` - Alternative zu please
- `killforce <PID...>` - kill -9
- `who-to-kill` - Top 10 RAM/CPU Verbraucher

## 💻 System Info

| Alias | Befehl |
|-------|--------|
| `systemstatus` | `top -b -n 1 \| head -n 20` |
| `uptime_p` | `uptime -p` |
| `ram` | `free -h --si` |
| `platz` | `df -hPT \| column -t` |
| `platte` | `df -h` |
| `diskinfo` | `lsblk` |

## 📥 Package Manager

| Alias | Befehl |
|-------|--------|
| `install` | `sudo apt install` |
| `uninstall` | `sudo apt remove` |
| `upgrade` | `sudo apt update && sudo apt upgrade -y` |
| `upgrade-full` | `sudo apt update && sudo apt full-upgrade -y` |
| `update` | `sudo apt update && sudo apt full-upgrade -y && sudo snap refresh && sudo flatpak update -y` |
| `install-common` | `sudo apt install cmatrix micro less mc btop htop p7zip-full brasero make git meld curl net-tools hwinfo gedit` |

## ⚔️ Task Manager

| Alias | Befehl |
|-------|--------|
| `killforce` / `exorzist` | `kill -9` |
| `psaux` / `psax` | `ps aux` |
| `top` | `htop` |
| `btop` | `htop` |
| `htop` | `btop` |

## 🎨 Colors & Files

| Alias | Befehl |
|-------|--------|
| `grep` / `egrep` / `fgrep` | Mit `--color=auto` |
| `ls` / `l` / `sl` | `ls -la --color=auto` |
| `cp` / `copy` | `cp -i` |
| `mv` / `move` | `mv -i` |
| `rm` / `remove` | `rm -i` |

## 📊 Disk Space

**Funktionen:**
- `ordner [pfad]` - du sortiert
- `sortiert` - Dateigröße aktuelles Verzeichnis sortiert
- `bigfiles [pfad]` - Top 10 größte Dateien
- `profile_me [n]` - Top n häufigste Befehle (default: 10)

## 💬 History

| Alias | Befehl |
|-------|--------|
| `hg` | `history \| grep` |
| `bitte` / `pls` | `sudo $(history -p !!)` |

## 🎬 Sonstiges

| Alias | Befehl |
|-------|--------|
| `matrix` / `rabbithole` | `cmatrix -b` |
| `warum` / `why` | Admin-Trost Echo |
| `date_now` | `date '+%Y-%m-%d %H:%M:%S'` |
| `schleife` | Zeigt while-loop Beispiel |
