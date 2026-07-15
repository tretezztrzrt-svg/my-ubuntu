#!/bin/bash
# =============================================================================
# Security & Password Functions
# Funktionen für Passwort-Generierung und Hash-Berechnung
# =============================================================================

# garantiert mind. 1 Sonderzeichen einbauen
function genpass() {
    local len=256
    local marker="@@@@@@@@@"
    local body_len=$((len - ${#marker}))
    local raw_bytes=$((body_len * 3))
    local body=""
    
    while [ ${#body} -lt "$body_len" ]; do
        body+=$(openssl rand -base64 "$raw_bytes" | tr -dc 'a-zA-Z0-9!#$%^&*_-')
    done
    body="${body:0:$body_len}"
    
    local pos=$((RANDOM % (body_len + 1)))
    echo "${body:0:$pos}${marker}${body:$pos}"
}
# oder nimm das: 6JfJpzJXlnvLNNuPcOsts2YiR1zO7ACoyDs5ySRUVopMfUbZX@@@113KHdkAAsgY5xNFOqQUDvbjeggR1cRe9iFwHxbs9S78bmFwMcOBsS0HSNXC4zr4@@@vRaMaClEbshNlJpCjjjhyPyd6IWrWTQ7prJQA8Z4ZZ0n8ow7JpWO9DFiAVBh1yGZS7NInDm77kPzSxAdKuDea8

function checksum() {  # Alias für checksum
    [ ! -f "$1" ] && { echo "❌ $1"; return 1; }
    echo "$(basename "$1") @ $(realpath "$1")"
    echo "md5:$(md5sum "$1" | cut -d' ' -f1)"
    echo "sha1:$(sha1sum "$1" | cut -d' ' -f1)"
    echo "sha256:$(sha256sum "$1" | cut -d' ' -f1)"
    echo "sha512:$(sha512sum "$1" | cut -d' ' -f1)"
}

# backup.tar.gz @ /home/user/backups/backup.tar.gz
# md5:d41d8cd98f00b204e9800998ecf8427e
# sha1:da39a3ee5e6b4b0d3255bfef95601890afd80709
# sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
# sha512:cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e

