#!/usr/bin/env bash
set -euo pipefail

cd ~

shopt -s dotglob nullglob

# 1) Ordner "Music, Videos, Templates, Pictures" entfernen (falls vorhanden)
for d in Music Videos Templates Pictures; do
  rm -rf -- "$d"
done

# 2) Alle Ordner im aktuellen Verzeichnis (ohne versteckte wie .ssh) in Kleinbuchstaben umbenennen
for dir in */; do
  # dir endet mit /
  base="${dir%/}"

  # versteckte Ordner auslassen (starten mit .)
  [[ "$base" == .* ]] && continue

  lower="$(printf '%s' "$base" | tr '[:upper:]' '[:lower:]')"

  # nur umbenennen, wenn wirklich nötig
  if [[ "$base" != "$lower" ]]; then
    # Ziel-Ordner kollidiert? -> abkürzen statt überschreiben
    if [[ -e "$lower" ]]; then
      echo "SKIP: '$base' -> '$lower' (Ziel existiert bereits)" >&2
      continue
    fi
    mv -- "$base" "$lower"
  fi
done



cp -f -- /home/ubuntu/ubuntu-learning/my-bash/.bash_aliases.sh ~/.bash_aliases
cp -f -- /home/ubuntu/ubuntu-learning/my-bash/.bash_aliases.sh ~/.bash_aliases
