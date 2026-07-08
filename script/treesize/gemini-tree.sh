#!/bin/bash

TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "\e[31mFehler: Verzeichnis $TARGET_DIR existiert nicht.\e[0m"
    exit 1
fi

TOTAL_DISK=$(df -h "$TARGET_DIR" | awk 'NR==2 {print $2}')
USED_DISK=$(df -h "$TARGET_DIR" | awk 'NR==2 {print $3}')
FREE_DISK=$(df -h "$TARGET_DIR" | awk 'NR==2 {print $4}')
USE_PCT=$(df -h "$TARGET_DIR" | awk 'NR==2 {print $5}')

echo -e "\e[36m========================================================================\e[0m"
echo -e "\e[1;37m TreeSize Core-Overview: $TARGET_DIR\e[0m"
echo -e "\e[36m========================================================================\e[0m"
echo -e "\e[32mGesamt: $TOTAL_DISK \e[0m| \e[31mBelegt: $USED_DISK ($USE_PCT) \e[0m| \e[34mFrei: $FREE_DISK\e[0m"
echo -e "\e[36m------------------------------------------------------------------------\e[0m"
echo -e "\e[1;30m%-10s %-15s %s\e[0m" "Größe" "Verteilung" "Pfad"
echo -e "\e[36m------------------------------------------------------------------------\e[0m"

raw_total=$(du -sb "$TARGET_DIR" 2>/dev/null | awk '{print $1}')
if [ -z "$raw_total" ] || [ "$raw_total" -eq 0 ]; then
    raw_total=1
fi

du -b --max-depth=2 "$TARGET_DIR" 2>/dev/null | sort -n -r | while read -r bytes path; do
    [ "$path" == "$TARGET_DIR" ] && continue

    readable_size=$(numfmt --to=iec-binary --suffix=B "$bytes")
    
    pct=$(( bytes * 100 / raw_total ))
    
    bar_width=$(( pct / 5 ))
    bar=$(printf "%-${bar_width}s" "#" | tr ' ' '#')
    empty=$(printf "%-$((20 - bar_width))s" " " | tr ' ' '.')
    
    depth=$(tr -cd '/' <<< "$path" | wc -c)
    target_depth=$(tr -cd '/' <<< "$TARGET_DIR" | wc -c)
    indent_level=$(( depth - target_depth ))
    
    indent=""
    if [ $indent_level -gt 1 ]; then
        indent="$(printf '%*s' $(( (indent_level - 1) * 4 )) '')└── "
    fi

    if [ $pct -gt 50 ]; then
        color="\e[31m" # Rot
    elif [ $pct -gt 20 ]; then
        color="\e[33m" # Gelb
    else
        color="\e[32m" # Grün
    fi

    printf "${color}%-10s\e[0m [\e[35m%-20s\e[0m] %3d%%  %s%s\n" "$readable_size" "${bar}${empty}" "$pct" "$indent" "$(basename "$path")"
done

echo -e "\e[36m------------------------------------------------------------------------\e[0m"
