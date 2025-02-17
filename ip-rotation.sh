#!/bin/bash

# Define file paths
ALL_IPS_FILE="all_ips.txt"
SELECTED_IP_FILE="selected_ip.txt"
MAILIPS_FILE="/etc/mailips"
LOG_FILE="rotate_ips.log"

# Check if the all_ips.txt file exists
if [[ ! -f "$ALL_IPS_FILE" ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: $ALL_IPS_FILE not found." | tee -a "$LOG_FILE"
    exit 1
fi

# Read all IPs into an array
mapfile -t IPS < "$ALL_IPS_FILE"

# Check if there are any IPs
if [[ ${#IPS[@]} -eq 0 ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: No IPs available in $ALL_IPS_FILE." | tee -a "$LOG_FILE"
    exit 1
fi

# Get the last used IP (if exists)
if [[ -f "$SELECTED_IP_FILE" ]]; then
    LAST_IP=$(cat "$SELECTED_IP_FILE")
else
    LAST_IP=""
fi

# Find the next IP in the list
NEXT_IP="${IPS[0]}"  # Default to first IP
for i in "${!IPS[@]}"; do
    if [[ "${IPS[$i]}" == "$LAST_IP" ]]; then
        NEXT_INDEX=$(( (i + 1) % ${#IPS[@]} ))
        NEXT_IP="${IPS[$NEXT_INDEX]}"
        break
    fi
done

# Save the new selected IP
echo "$NEXT_IP" > "$SELECTED_IP_FILE"

# Append to /etc/mailips
echo "*: $NEXT_IP" | sudo tee "$MAILIPS_FILE"

# Log the change
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Rotated IP: $LAST_IP → $NEXT_IP" | tee -a "$LOG_FILE"

echo "Updated $MAILIPS_FILE with IP: $NEXT_IP"