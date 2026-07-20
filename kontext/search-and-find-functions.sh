#Add to ~/.bashrc:

#Usage:
#nsearch "TODO"              # search entire filesystem
#nsearch "API_KEY" /etc      # search a specific directory
#sudo nsearch "password"     # search with root privileges (needed for protected files)

function find_in_file() {
    local pattern="$1"
    local dir="${2:-/}"

    grep -rniI \
        --exclude-dir={.git,node_modules,vendor,venv,.cache,__pycache__,dist,build,proc,sys,dev,run,snap} \
        --exclude=*.{png,jpg,jpeg,gif,svg,ico,exe,bin,o,so,pdf,zip,tar,gz} \
        "$pattern" "$dir" 2>/dev/null
}


#nfind "config"               # uses locate if available, else falls back to find
#nfind "backup" /home         # search a specific directory (forces find, skips locate)

function find_files() {
    local pattern="$1"
    local dir="${2:-/}"

    if command -v locate &>/dev/null; then
        locate -i "*$pattern*" 2>/dev/null
        return
    fi

    find "$dir" \
        \( -path '*/.git' -o -path '*/node_modules' -o -path '*/vendor' \
           -o -path '*/venv' -o -path '*/__pycache__' -o -path '*/dist' \
           -o -path '*/build' -o -path '/proc' -o -path '/sys' \
           -o -path '/dev' -o -path '/run' -o -path '/snap' \) -prune -o \
        -type f -iname "*$pattern*" -print 2>/dev/null
}
