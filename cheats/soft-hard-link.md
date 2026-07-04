# Soft- vs. Hardlink — Kurz & Praxis

Kurz: Symlinks sind Verweise auf Pfade, Hardlinks sind zusätzliche Dateinamen, die auf dieselbe Inode zeigen.

## Unterschied
- Symbolischer Link (Symlink)
  - Enthält einen Pfad‑String, kann auf Dateien oder Verzeichnisse und über Dateisysteme hinweg zeigen.
  - Wird broken, wenn das Ziel gelöscht wird.
- Hard Link
  - Zweiter Name für dieselbe Inode — identische Daten, andere Namen.
  - Nur im selben Dateisystem möglich; erst gelöscht, wenn alle Links entfernt sind.

## Kompakte Praxis‑Beispiele
- Release‑Switch (Symlink, atomar):

  mkdir -p ~/deploy/releases/2026-07-04
  ln -sfn ~/deploy/releases/2026-07-04 ~/deploy/current

- Globalen Befehl verlinken (Symlink):

  sudo ln -s /opt/myapp/version-x.y.z/bin/myapp /usr/local/bin/myapp

- Platz sparen (Hardlink):

  mkdir -p ~/linktest && cd ~/linktest
  echo "daten" > file-original.txt
  ln file-original.txt file-hardlink.txt
  stat -c '%n -> inode=%i, links=%h' file-original.txt file-hardlink.txt

  # rm file-original.txt — file-hardlink.txt bleibt lesbar.

## Erkennen / Debug
- Symlinks finden (Home, 3 Ebenen):
  find ~ -maxdepth 3 -type l -ls
- Ziel eines Symlinks anzeigen:
  readlink -f ~/deploy/current
- Dateien mit mehreren Hardlinks:
  find ~ -type f -links +1 -ls
- Alle Pfade zu einer Inode:
  find /path -samefile /path/to/file -ls
- Inode & Link‑Count:
  stat -c '%n -> inode=%i, links=%h, size=%s' /path/to/file

## Kurzreferenz
- ln -s <ziel> <linkname>
- ln <ziel> <linkname>
- readlink -f <link>
- stat -c '%n -> inode=%i, links=%h' <datei>

---
Kleines Sandbox‑Test: siehe Abschnitt "Platz sparen" — sicher in /tmp testen.
