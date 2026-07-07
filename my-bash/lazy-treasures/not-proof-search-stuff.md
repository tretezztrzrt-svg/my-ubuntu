| Alias | Befehl | Nutzung |
| :--- | :--- | :--- |
| `diff_files` | `diff --suppress-common-lines -y` | `diff_files datei1 datei2` |
| `compare` | `sdiff` | `compare datei1 datei2` |
| `patch_apply` | `patch` | `patch_apply < patchfile` |
| `txt_search` | `grep -rnw . -e` | `txt_search "pattern"` |
| `text_find` | `grep -ril` | `text_find "pattern" .` |
| `clean_find` | `find . -type f ! -name '*.png' ! -name '*.jpg' ! -name '*.exe' ! -name '*.o'` | `clean_find` |

| Funktion | Befehl | Nutzung |
| :--- | :--- | :--- |
| `search` | `egrep -roi "$1" . 2>/dev/null \| cut -d: -f2- \| sort \| uniq -c \| sort -rn` | `search "pattern"` |
| `findfile` | `find . -type f -iname "*$1*" 2>/dev/null \| head -30` | `findfile datei` |
| `findbig` | `find . -type f -size +100M -exec du -h {} \; \| sort -hr \| head -20` | `findbig` |
| `findchanged` | `find . -type f -mtime -7 -exec ls -lt {} \;` | `findchanged` |
| `configsearch` | `find /etc -type f \( -name "*.conf" -o -name "*.cfg" -o -name "*.ini" \) -exec grep -l "$1" {} \;` | `configsearch "pattern"` |
