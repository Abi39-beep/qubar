#!/usr/bin/env bash

# THE FIX: Explicitly define the system path so Quickshell can find kitty and killall!
export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin

selected_theme="$1"
[ -z "$selected_theme" ] && exit 1

THEME_DIR="$HOME/.config/color-scheme"
CONF_DIR="$HOME/.config"
CACHE_DIR="$HOME/.cache"
ACTIVE_THEME_FILE="$CACHE_DIR/current_theme"
theme_path="$THEME_DIR/$selected_theme"
lock_image="$CACHE_DIR/current_wallpaper_${selected_theme}"

mkdir -p "$CACHE_DIR"

# 1. Register the Active Theme
printf '%s\n' "$selected_theme" > "$ACTIVE_THEME_FILE"

# 2. Push Configs to system apps
echo "@import \"$THEME_DIR/$selected_theme/rofi/$selected_theme.rasi\"" > "$CONF_DIR/rofi/color.rasi" 2>/dev/null
echo "include $THEME_DIR/$selected_theme/kitty/$selected_theme.conf" > "$CONF_DIR/kitty/color.conf" 2>/dev/null
echo "source = $THEME_DIR/$selected_theme/hyprlock/$selected_theme.conf" > "$CONF_DIR/hypr/color.conf" 2>/dev/null
echo "include=$THEME_DIR/$selected_theme/foot/$selected_theme.ini" > "$CONF_DIR/foot/color.ini" 2>/dev/null
cp "$THEME_DIR/$selected_theme/nvim/color.lua" "$HOME/.config/nvim/lua/color.lua" 2>/dev/null
cp "$THEME_DIR/$selected_theme/firefox/userChrome.css" "$HOME/.config/mozilla/firefox/14qna8yw.default-release/chrome/userChrome.css" 2>/dev/null
cp "$THEME_DIR/$selected_theme/zen/$selected_theme.css" "$HOME/.config/zen/rcasz579.Default (release)/chrome/userChrome.css" 2>/dev/null
cp "$THEME_DIR/$selected_theme/hyprland/Colors.lua" "$HOME/.config/hypr/Modules/Colors.lua" 2>/dev/null

# 3. Copy QML Colors EVERYWHERE
cp "$THEME_DIR/$selected_theme/quickshell/Colors.qml" "$HOME/.config/quickshell/Colors.qml" 2>/dev/null
cp "$THEME_DIR/$selected_theme/quickshell/Colors.qml" "$HOME/.config/quickshell/qubar/Colors.qml" 2>/dev/null
cp "$THEME_DIR/$selected_theme/quickshell/Colors.qml" "$HOME/.config/quickshell/OSD/Colors.qml" 2>/dev/null
cp "$THEME_DIR/$selected_theme/quickshell/Colors.qml" "$HOME/.config/quickshell/tact/Colors.qml" 2>/dev/null
cp "$THEME_DIR/$selected_theme/quickshell/Colors.qml" "$HOME/.config/quickshell/new/Colors.qml" 2>/dev/null

# 4. Nuke the QML Cache
find "$HOME/.config/quickshell" -type d -name ".qmlc" -exec rm -rf {} + 2>/dev/null
find "$HOME/.config/quickshell" -name "*.qmlc" -delete 2>/dev/null
rm -rf "$HOME/.cache/quickshell" 2>/dev/null

# 5. Spicetify Integration
spicetify_tracker="$THEME_DIR/$selected_theme/spotify/spicetify.txt"
if [ -f "$spicetify_tracker" ]; then
    mapfile -t spice_config < <(tr -d '\r' < "$spicetify_tracker")
    spice_theme="${spice_config[0]:-}"
    spice_scheme="${spice_config[1]:-}"

    if command -v spicetify >/dev/null 2>&1 && [ -n "$spice_theme" ] && [ -d "$HOME/.config/spicetify/Themes/$spice_theme" ]; then
        (
            spicetify config current_theme "$spice_theme"
            if [ -n "$spice_scheme" ]; then
                spicetify config color_scheme "$spice_scheme"
            else
                spicetify config color_scheme ""
            fi

            spicetify apply -n >/dev/null 2>&1
            if pgrep -x spotify >/dev/null; then
                pkill -x spotify
                sleep 0.5
                spotify >/dev/null 2>&1 &
            fi
        ) & disown
    fi
fi

# 6. Apply Random Theme Wallpaper
wallpaper_list() {
    find "$1" -maxdepth 1 -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.svg" -o -iname "*.jfif" \) \
        2>/dev/null | sort
}

mapfile -t wallpapers < <(wallpaper_list "$theme_path")
if [ "${#wallpapers[@]}" -gt 0 ]; then
    auto_wall="${wallpapers[$((RANDOM % ${#wallpapers[@]}))]}"
    awww img "$auto_wall" --transition-type outer --transition-duration 1.5
    ln -sfn "$auto_wall" "$lock_image"
else
    rm -f "$lock_image" 2>/dev/null
fi

# ==========================================
# 7. LIVE RELOAD OPEN APPLICATIONS
# ==========================================

# --- KITTY TERMINAL ---
if pgrep -x kitty > /dev/null; then
    # Strategy A: Update the file timestamp so Kitty's internal engine detects the change!
    touch "$HOME/.config/kitty/kitty.conf" 2>/dev/null || true
    killall -SIGUSR1 kitty 2>/dev/null || true

    # Strategy B: Directly inject the colors via sockets (catches any stubborn windows)
    for socket in /tmp/kitty-*; do
        if [ -e "$socket" ]; then
            kitty @ --to "unix:$socket" set-colors -a "$THEME_DIR/$selected_theme/kitty/$selected_theme.conf" 2>/dev/null || true
        fi
    done
fi

# --- FOOT TERMINAL ---
if pgrep -x foot > /dev/null || pgrep -x footd > /dev/null; then
    # THE FIX: 'sed -i' physically creates a new file inode.
    # This acts as a hard change and 100% forces Foot's file-watcher to auto-reload!
    sed -i -e '$a\' "$HOME/.config/foot/foot.ini" 2>/dev/null || true

    # Send the manual signals just as a backup
    pkill -USR1 -x foot 2>/dev/null || true
    pkill -USR1 -x footd 2>/dev/null || true
fi

# --- HYPRLAND ---
# Using the native hyprctl command to reload configs (bypassing the dispatch error)
hyprctl reload 2>/dev/null || true

# --- QUICKSHELL ---
# THE MAGIC FIX: We completely bypass 'hyprctl dispatch exec'.
# 'nohup' and 'disown' perfectly detach Quickshell so it restarts cleanly in the background!
nohup bash "$HOME/.config/quickshell/reload.sh" >/dev/null 2>&1 & disown
