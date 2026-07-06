#!/usr/bin/env bash

CHOICE="$1"
if [ -z "$CHOICE" ]; then
    exit 1
fi

QUICKSHELL_DIR="$HOME/.config/quickshell"
TARGET_FILE="$QUICKSHELL_DIR/reload.sh"
SOURCE_FILE="$QUICKSHELL_DIR/switch/$CHOICE/reload.sh"

if [ ! -f "$SOURCE_FILE" ]; then
    SOURCE_FILE="$QUICKSHELL_DIR/switcher/$CHOICE/reload.sh"
fi

if [ -f "$SOURCE_FILE" ]; then
    cp "$SOURCE_FILE" "$TARGET_FILE"
    echo "${CHOICE,,}" > ~/.cache/current_bar
    cd "$QUICKSHELL_DIR" || exit
    setsid bash reload.sh >/dev/null 2>&1 &
else
    notify-send "Error" "Could not find $SOURCE_FILE"
fi
