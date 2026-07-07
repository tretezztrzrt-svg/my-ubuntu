#!/bin/bash
# =============================================================================
# Security & Password Functions
# Funktionen für Passwort-Generierung und Hash-Berechnung
# =============================================================================

# Generate secure password
function genpass() {
    local len="${1:-32}"
    openssl rand -base64 "$len" | tr -dc 'a-zA-Z0-9!@#$%^&*_-' | head -c "$len"
    echo ""
}

# Hash string with various algorithms
function hashit() {
    if [ -z "$1" ]; then
        read -sp "Enter string to hash: " input
        echo ""
    else
        input="$1"
    fi
    
    echo "MD5:     $(echo -n "$input" | md5sum | cut -d' ' -f1)"
    echo "SHA1:    $(echo -n "$input" | sha1sum | cut -d' ' -f1)"
    echo "SHA256:  $(echo -n "$input" | sha256sum | cut -d' ' -f1)"
    echo "SHA512:  $(echo -n "$input" | sha512sum | cut -d' ' -f1)"
}

# File checksum
function checksum() {
    if [ -z "$1" ]; then
        echo "Usage: checksum <file>"
        return 1
    fi
    
    if [ ! -f "$1" ]; then
        echo "❌ File not found: $1"
        return 1
    fi
    
    echo "Checksums for: $1"
    md5sum "$1"
    sha1sum "$1"
    sha256sum "$1"
}
