#!/bin/bash

# VM Health Check Script for Ubuntu
# Analyzes CPU, Memory, and Disk usage to determine VM health
# Usage: ./vm-health-check.sh [explain]

THRESHOLD=60

# Parse command line arguments
EXPLAIN=false
if [[ "$1" == "explain" ]]; then
    EXPLAIN=true
fi

# Function to calculate CPU usage percentage
get_cpu_usage() {
    # Get CPU statistics from /proc/stat
    local cpu_line=$(head -n 1 /proc/stat)
    local cpu_values=($cpu_line)

    # Extract values: user, nice, system, idle, iowait, irq, softirq, steal
    local user=${cpu_values[1]}
    local nice=${cpu_values[2]}
    local system=${cpu_values[3]}
    local idle=${cpu_values[4]}
    local iowait=${cpu_values[5]}
    local irq=${cpu_values[6]}
    local softirq=${cpu_values[7]}
    local steal=${cpu_values[8]}

    # Calculate total and idle times
    local total=$((user + nice + system + idle + iowait + irq + softirq + steal))

    # Sleep briefly to get a second reading
    sleep 0.5

    local cpu_line2=$(head -n 1 /proc/stat)
    local cpu_values2=($cpu_line2)

    local user2=${cpu_values2[1]}
    local nice2=${cpu_values2[2]}
    local system2=${cpu_values2[3]}
    local idle2=${cpu_values2[4]}
    local iowait2=${cpu_values2[5]}
    local irq2=${cpu_values2[6]}
    local softirq2=${cpu_values2[7]}
    local steal2=${cpu_values2[8]}

    local total2=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2 + steal2))

    # Calculate differences
    local total_diff=$((total2 - total))
    local idle_diff=$((idle2 - idle))

    # Calculate CPU usage percentage
    if [[ $total_diff -gt 0 ]]; then
        local used=$((total_diff - idle_diff))
        echo $(( (used * 100) / total_diff ))
    else
        echo 0
    fi
}

# Function to calculate Memory usage percentage
get_memory_usage() {
    # Parse /proc/meminfo for memory statistics
    local total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    local available=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)

    # If MemAvailable not present, calculate from free + buffers + cache
    if [[ -z "$available" ]]; then
        local free=$(awk '/MemFree/ {print $2}' /proc/meminfo)
        local buffers=$(awk '/Buffers/ {print $2}' /proc/meminfo)
        local cached=$(awk '/^Cached/ {print $2}' /proc/meminfo)
        available=$((free + buffers + cached))
    fi

    # Calculate used memory
    local used=$((total - available))

    # Calculate usage percentage
    if [[ $total -gt 0 ]]; then
        echo $(( (used * 100) / total ))
    else
        echo 0
    fi
}

# Function to calculate Disk usage percentage
get_disk_usage() {
    # Get root filesystem usage
    local disk_info=$(df / | tail -n 1)
    local usage_percent=$(echo "$disk_info" | awk '{print $5}' | tr -d '%')

    echo "$usage_percent"
}

# Collect metrics
CPU_USAGE=$(get_cpu_usage)
MEMORY_USAGE=$(get_memory_usage)
DISK_USAGE=$(get_disk_usage)

# Determine health status
HEALTHY=true

if [[ $CPU_USAGE -gt $THRESHOLD ]]; then
    HEALTHY=false
fi

if [[ $MEMORY_USAGE -gt $THRESHOLD ]]; then
    HEALTHY=false
fi

if [[ $DISK_USAGE -gt $THRESHOLD ]]; then
    HEALTHY=false
fi

# Output results
if [[ "$HEALTHY" == true ]]; then
    echo "Health Status: Healthy"

    if [[ "$EXPLAIN" == true ]]; then
        echo ""
        echo "All system resources are within acceptable limits (below ${THRESHOLD}%):"
        echo "  - CPU Usage:   ${CPU_USAGE}%"
        echo "  - Memory Usage: ${MEMORY_USAGE}%"
        echo "  - Disk Usage:   ${DISK_USAGE}%"
    fi
    exit 0
else
    echo "Health Status: Not Healthy"

    if [[ "$EXPLAIN" == true ]]; then
        echo ""
        echo "One or more system resources have exceeded the ${THRESHOLD}% threshold:"
        echo "  - CPU Usage:   ${CPU_USAGE}% $([[ $CPU_USAGE -gt $THRESHOLD ]] && echo "[ABOVE THRESHOLD]" || echo "[OK]")"
        echo "  - Memory Usage: ${MEMORY_USAGE}% $([[ $MEMORY_USAGE -gt $THRESHOLD ]] && echo "[ABOVE THRESHOLD]" || echo "[OK]")"
        echo "  - Disk Usage:   ${DISK_USAGE}% $([[ $DISK_USAGE -gt $THRESHOLD ]] && echo "[ABOVE THRESHOLD]" || echo "[OK]")"
        echo ""
        echo "Actions recommended:"
        [[ $CPU_USAGE -gt $THRESHOLD ]] && echo "  - Reduce CPU load by stopping unnecessary processes"
        [[ $MEMORY_USAGE -gt $THRESHOLD ]] && echo "  - Free up memory by closing applications or adding swap space"
        [[ $DISK_USAGE -gt $THRESHOLD ]] && echo "  - Clean up disk space by removing unused files"
    fi
    exit 1
fi
