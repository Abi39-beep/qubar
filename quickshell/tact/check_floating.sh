#!/bin/bash
export PATH=$PATH:/usr/bin:/usr/local/bin

while true; do
    # Safety feature: If Quickshell is killed, this script kills itself
    if [ "$PPID" -eq 1 ]; then
        exit 0
    fi

    ws=$(hyprctl activeworkspace -j | jq '.id')
    
    # Fallback just in case hyprctl takes a millisecond too long to respond
    if [ -z "$ws" ] || [ "$ws" == "null" ]; then
        ws="-1"
    fi

    count=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == $ws and (.floating == false or .fullscreen == true))] | length")
    echo "$count"
    
    sleep 0.5
done
