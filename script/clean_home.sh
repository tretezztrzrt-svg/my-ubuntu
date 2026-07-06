#!/usr/bin/env bash
set -euo pipefail

cd ~

shopt -s dotglob nullglob

# 1) Ordner "Music, Videos, Templates, Pictures" entfernen (falls vorhanden)
for d in Music Videos Templates Pictures; do
  rm -rf -- "$d"
done


for dir in */; do
  base="${dir%/}"                     # Ordner ohne abschließenden Schrägstrich

  # Versteckte Ordner (beginnen mit .) überspringen
  [[ "$base" == .* ]] && continue

  # Ausnahme für den Desktop-Ordner (Ubuntu/GNOME)
  # hier muss für ubuntu leider eine ausnahme eingabut werden,
  # wenn Desktop zu desktop umbennat wird, dann erscheint auf dem 
  # desktop selbst der inhalt vom home verzeinis und das ist nicht gewollt
  [[ "$base" == "Desktop" ]] && continue

  lower="$(printf '%s' "$base" | tr '[:upper:]' '[:lower:]')"

  if [[ "$base" != "$lower" ]]; then
    if [[ -e "$lower" ]]; then
      echo "SKIP: '$base' -> '$lower' (Ziel existiert bereits)" >&2
      continue
    fi
    mv -- "$base" "$lower"
  fi
done


cp -f -- "/home/$USER/ubuntu-learning/my-bash/.bash_aliases.sh" "$HOME/.bash_aliases"
cp -f -- "/home/$USER/ubuntu-learning/my-bash/.bash_functions.sh" "$HOME/.bash_functions"

mv -- "/home/$USER/ubuntu-learning/backup/"* "$HOME/backup/"
mv -- "/home/$USER/ubuntu-learning/trash/"* "$HOME/trash/"
mv -- "/home/$USER/ubuntu-learning/script/"* "$HOME/script/"

echo "fertsch"
sleep 22
