#!/usr/bin/env bash

# 1. Explicitly set the PATH so Quickshell can find 'awww'!
export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin

wall_path="$1"
[ -z "$wall_path" ] && exit 1

CACHE_DIR="$HOME/.cache"
current_theme=$(cat "$CACHE_DIR/current_theme" 2>/dev/null)
lock_image="$CACHE_DIR/current_wallpaper_${current_theme}"

# 2. Apply instantly with awww
awww img "$wall_path" --transition-type outer --transition-duration 1.5

# 3. Update symlinks for your lock screen
ln -sfn "$wall_path" "$lock_image"
ln -sfn "$wall_path" "$CACHE_DIR/current_wallpaper"
