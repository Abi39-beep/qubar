#!/bin/bash
export PATH=$PATH:/usr/bin:/usr/local/bin

while true; do
    # Safety feature: Kills script if Quickshell restarts
    if [ "$PPID" -eq 1 ]; then exit 0; fi

    # Read Battery
    bat=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1)
    stat=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1)
    [ -z "$bat" ] && bat=100
    [ -z "$stat" ] && stat="Unknown"
    
    # Read Wi-Fi strength (calculates percentage out of 70)
    wifi_raw=$(awk 'NR==3 {print $3}' /proc/net/wireless 2>/dev/null | tr -d '.')
    if [ -z "$wifi_raw" ]; then
        wifi=0
    else
        wifi=$(( wifi_raw * 100 / 70 ))
        [ "$wifi" -gt 100 ] && wifi=100
    fi
    
    # Send data to QML format: BatteryLevel|BatteryStatus|WifiLevel
    echo "$bat|$stat|$wifi"
    
    sleep 2
done
