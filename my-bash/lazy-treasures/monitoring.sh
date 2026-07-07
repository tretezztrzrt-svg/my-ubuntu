#!/bin/bash
# =============================================================================
# System Monitoring Functions
# Funktionen zur Überwachung von Systemressourcen
# =============================================================================

# Memory hungry processes
function mem_hogs() {
    echo "=== Top 10 Memory Consumers ==="
    ps aux --sort=-%mem | awk 'NR<=11 {printf \"%-8s %5s %s\\n\", $3"%", $4"%", $11}' | column -t
}

# CPU intensive processes
function cpu_hogs() {
    echo "=== Top 10 CPU Consumers ==="
    ps aux --sort=-%cpu | awk 'NR<=11 {printf \"%-8s %8s %s\\n\", $3"%", $2, $11}' | column -t
}

# Network connections summary
function conn_summary() {
    echo "=== Active Connections ==="
    ss -tan | awk 'NR>1 {count[$2]++} END {for(s in count) print s": "count[s]}' | sort
    echo ""
    echo "=== Listening Ports ==="
    ss -tulpn
}

# Open file handles count per process
function open_files() {
    echo "=== Processes with most open files ==="
    lsof | awk '{print $1}' | sort | uniq -c | sort -rn | head -10 | awk '{print $2": "$1" files"}'
}
