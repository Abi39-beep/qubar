import QtQuick
import Quickshell

Item {
    id: engineRoot

    Timer {
        id: applyTimer
        interval: 1000
        running: true
        onTriggered: {
            engineRoot.applyGtk();
            engineRoot.applyZed();
        }
    }

    function applyGtk() {
        let css = `
    @define-color accent_color ${Colors.blue};
    @define-color accent_bg_color ${Colors.blue};
    @define-color window_bg_color ${Colors.bg0};
    @define-color window_fg_color ${Colors.fg};
    @define-color view_bg_color ${Colors.bg0};
    @define-color view_fg_color ${Colors.fg};
    @define-color headerbar_bg_color ${Colors.bg1};
    @define-color headerbar_fg_color ${Colors.fg};
    @define-color sidebar_bg_color ${Colors.bg1};
    @define-color sidebar_fg_color ${Colors.fg};
    @define-color sidebar_backdrop_color ${Colors.bg1};
    @define-color secondary_sidebar_bg_color ${Colors.bg2};
    @define-color secondary_sidebar_fg_color ${Colors.fg};
    @define-color secondary_sidebar_backdrop_color ${Colors.bg2};
    @define-color popover_bg_color ${Colors.bg2};
    @define-color popover_fg_color ${Colors.fg};
    @define-color card_bg_color ${Colors.bg1};
    @define-color card_fg_color ${Colors.fg};
    @define-color dialog_bg_color ${Colors.bg0};
    @define-color dialog_fg_color ${Colors.fg};
    @define-color success_color ${Colors.green};
    @define-color warning_color ${Colors.yellow};
    @define-color error_color ${Colors.red};
    `;

        let cmd = `export PATH=$PATH:/usr/bin:/bin:/usr/local/bin; mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0 && echo "${css}" > ~/.config/gtk-3.0/gtk.css && echo "${css}" > ~/.config/gtk-4.0/gtk.css`;
        Quickshell.execDetached(["bash", "-c", cmd]);

        let reloadCmd = `
            export PATH=$PATH:/usr/bin:/bin:/usr/local/bin;
            if pacman -Qs adw-gtk3 > /dev/null 2>&1; then TARGET_THEME='adw-gtk3-dark'; else TARGET_THEME='Adwaita-dark'; fi
            gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
            sleep 0.1
            gsettings set org.gnome.desktop.interface gtk-theme "$TARGET_THEME"
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
            killall -q xdg-desktop-portal-gtk xdg-desktop-portal-gnome || true
            `;

        Quickshell.execDetached(["bash", "-c", reloadCmd]);
    }

    function applyZed() {
        let zedJson = `{
  "name": "Quickshell Sync",
  "author": "Auto Generated",
  "themes":[
    {
      "name": "Quickshell Sync",
      "appearance": "dark",
      "style": {
        "background": "${Colors.bg0}",
        "foreground": "${Colors.fg}",
        "text": "${Colors.fg}",
        "text.muted": "${Colors.grey1}",
        "text.accent": "${Colors.blue}",
        "border": "${Colors.bg2}",
        "border.focused": "${Colors.blue}",
        "element.background": "${Colors.bg1}",
        "element.hover": "${Colors.bg2}",
        "element.active": "${Colors.bg3}",
        "element.selected": "${Colors.bg2}",
        "title_bar.background": "${Colors.bg0}",
        "title_bar.inactive_background": "${Colors.bg0}",
        "status_bar.background": "${Colors.bg0}",
        "tab_bar.background": "${Colors.bg1}",
        "tab.inactive_background": "${Colors.bg1}",
        "tab.active_background": "${Colors.bg0}",
        "panel.background": "${Colors.bg0}",
        "toolbar.background": "${Colors.bg0}",
        "surface.background": "${Colors.bg0}",
        "elevated_surface.background": "${Colors.bg1}",
        "scrollbar.thumb.background": "${Colors.bg2}80",
        "scrollbar.thumb.hover_background": "${Colors.bg3}",
        "scrollbar.track.background": "${Colors.bg0}00",
        "editor.background": "${Colors.bg0}",
        "editor.foreground": "${Colors.fg}",
        "editor.line_number": "${Colors.grey0}",
        "editor.active_line_number": "${Colors.fg}",
        "editor.active_line.background": "${Colors.bg1}",
        "editor.gutter.background": "${Colors.bg0}",
        "editor.selection.background": "${Colors.bg3}80",
        "editor.highlighted_line.background": "${Colors.bg1}",
        "diagnostic.error": "${Colors.red}",
        "diagnostic.warning": "${Colors.yellow}",
        "diagnostic.info": "${Colors.blue}",
        "diagnostic.hint": "${Colors.aqua}",
        "error.background": "${Colors.red}25",
        "warning.background": "${Colors.yellow}25",
        "info.background": "${Colors.blue}25",
        "hint.background": "${Colors.aqua}25",
        "terminal.background": "${Colors.bg0}",
        "terminal.foreground": "${Colors.fg}",
        "terminal.ansi.black": "${Colors.bg1}",
        "terminal.ansi.red": "${Colors.red}",
        "terminal.ansi.green": "${Colors.green}",
        "terminal.ansi.yellow": "${Colors.yellow}",
        "terminal.ansi.blue": "${Colors.blue}",
        "terminal.ansi.magenta": "${Colors.purple}",
        "terminal.ansi.cyan": "${Colors.aqua}",
        "terminal.ansi.white": "${Colors.fg}",
        "syntax": {
          "keyword": { "color": "${Colors.purple}" },
          "control": { "color": "${Colors.purple}" },
          "boolean": { "color": "${Colors.orange}" },
          "function": { "color": "${Colors.blue}" },
          "string": { "color": "${Colors.green}" },
          "number": { "color": "${Colors.orange}" },
          "property": { "color": "${Colors.aqua}" },
          "attribute": { "color": "${Colors.aqua}" },
          "type": { "color": "${Colors.yellow}" },
          "constructor": { "color": "${Colors.yellow}" },
          "comment": { "color": "${Colors.grey1}", "font_style": "italic" },
          "variable": { "color": "${Colors.fg}" },
          "constant": { "color": "${Colors.orange}" },
          "punctuation": { "color": "${Colors.fg2}" },
          "operator": { "color": "${Colors.aqua}" },
          "tag": { "color": "${Colors.red}" }
        }
      }
    }
  ]
}`;

        let cmd1 = `export PATH=$PATH:/usr/bin:/bin; mkdir -p ~/.config/zed/themes && cat << 'EOF' > ~/.config/zed/themes/quickshell-sync.json\n${zedJson}\nEOF`;
        Quickshell.execDetached(["bash", "-c", cmd1]);
        let cmd2 = `export PATH=$PATH:/usr/bin:/bin; sed -i 's/"theme":.*/"theme": "Quickshell Sync",/' ~/.config/zed/settings.json || sed -i '1s/{/{\\n  "theme": "Quickshell Sync",/' ~/.config/zed/settings.json`;
        Quickshell.execDetached(["bash", "-c", cmd2]);
    }

    function applyTheme(themeName) {
        let home = Quickshell.env("HOME");

        let script = `
                THEME_DIR="${home}/.config/quickshell/themes/${themeName}"

                # 1. Standard configs
                cp "$THEME_DIR/kitty/"*.conf "${home}/.config/kitty/color.conf" 2>/dev/null || true
                cp "$THEME_DIR/foot/"*.ini "${home}/.config/foot/color.ini" 2>/dev/null || true
                cp "$THEME_DIR/hyprlock/"*.conf "${home}/.config/hypr/color.conf" 2>/dev/null || true
                cp "$THEME_DIR/nvim/"*.lua "${home}/.config/nvim/lua/color.lua" 2>/dev/null || true
                cp "$THEME_DIR/hyprland/"*.lua "${home}/.config/hypr/Colors.lua" 2>/dev/null || true
                cp "$THEME_DIR/quickshell/Colors.qml" "${home}/.config/quickshell/new/Colors.qml" 2>/dev/null || true
                cp "$THEME_DIR/quickshell/Colors.qml" "${home}/.config/quickshell/tact/Colors.qml" 2>/dev/null || true

                # --- ZEN BROWSER FIX ---
                pkill -x zen || true
                ZEN_CHROME_DIR="${home}/.config/zen/rcasz579.Default (release)/chrome"
                mkdir -p "$ZEN_CHROME_DIR"
                cp "$THEME_DIR/zen/"*.css "$ZEN_CHROME_DIR/userChrome.css" 2>/dev/null || true

                # --- KITTY LIVE RELOAD FIX ---
                # Sending SIGUSR1 forces Kitty to naturally reload its config file instantly!
                killall -SIGUSR1 kitty 2>/dev/null || true

                echo "${themeName}" > "${home}/.cache/current_theme"

                # 3. Random Wallpaper
                WALL=$(find "$THEME_DIR" -maxdepth 1 -type f \\( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \\) 2>/dev/null | shuf -n 1)
                if [ -n "$WALL" ]; then
                    echo "$WALL" > "${home}/.cache/current_wallpaper"
                fi

                # Force Restart Quickshell
                if [ -f "${home}/.config/quickshell/reload.sh" ]; then
                    bash "${home}/.config/quickshell/reload.sh" &
                else
                    killall quickshell && quickshell &
                fi
            `;

        Quickshell.execDetached(["bash", "-c", script]);
    }
}
