#!/bin/bash
# =============================================================================
# System Monitoring Functions (Solid Core)
# Funktionen zur Überwachung von Systemressourcen
# =============================================================================

# Memory hungry processes
function mem_hogs() {
    ps aux --sort=-%mem | awk 'NR<=11 {
        if(NR==1) next;
        printf "%-8s %5s %s\n", $3"%", $4"%", $11
    }' | column -t
}

# CPU intensive processes  
function cpu_hogs() {
    ps aux --sort=-%cpu | awk 'NR<=11 {
        if(NR==1) next;
        printf "%-8s %8s %s\n", $3"%", $2, $11
    }' | column -t
}

# Network connections summary
function conn_summary() {
    ss -tan | awk 'NR>1 {count[$2]++} END {for(s in count) print s": "count[s]}' | sort
    echo ""
    ss -tulpn | head -10
}

# Open file handles count per process
function open_files() {
    lsof | awk '{print $1}' | sort | uniq -c | sort -rn | head -10 | awk '{print $2": "$1" files"}'
}

# Quick all-in-one check
function syscheck() {
    echo "=== $(date '+%H:%M:%S') ==="
    echo ""
    echo "CPU top:"
    ps aux --sort=-%cpu | awk 'NR<=4 && NR>1 {printf "  %-6s %s\n", $3"%", $11}'
    echo ""
    echo "MEM top:"  
    ps aux --sort=-%mem | awk 'NR<=4 && NR>1 {printf "  %-6s %s\n", $4"%", $11}'
    echo ""
    echo "Connections: $(ss -tan | awk 'NR>1 && $2=="ESTAB" {count++} END {print count}")"
    echo "Load: $(uptime | sed 's/.*load average: //')"
}
