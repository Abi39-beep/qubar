pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: themeRoot
    signal backRequested

    property string activeTheme: ""
    property var themeData: []
    property string pendingTheme: ""

    // ==========================================
    // 1. AUTOMATIC EXTERNAL APP ENGINE
    // ==========================================
    Timer {
        id: applyTimer
        interval: 1000
        running: true
        onTriggered: {
            themeRoot.applyGtk();
            themeRoot.applyZed();
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
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        if pacman -Qs adw-gtk3 > /dev/null 2>&1; then
            gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
        else
            gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
        fi
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

    // ==========================================
    // 2. THEME DATA ENGINE (One-Time Startup Fetch)
    // ==========================================
    Process {
        id: getActiveProc
        command: ["bash", "-c", "cat ~/.cache/current_theme || echo 'Unknown'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                themeRoot.activeTheme = data.trim();
            }
        }
    }

    Process {
        id: scanThemesProc
        command: ["bash", "-c", "for d in ~/.config/color-scheme/*/; do name=$(basename \"$d\"); bg=$(grep 'readonly property color bg2' \"$d/quickshell/Colors.qml\" 2>/dev/null | cut -d'\"' -f2); acc=$(grep 'readonly property color aqua' \"$d/quickshell/Colors.qml\" 2>/dev/null | cut -d'\"' -f2); echo \"$name|${bg:-#152a26}|${acc:-#3dd1b0}\"; done"]
        running: true

        property string themeBuffer: ""

        stdout: SplitParser {
            onRead: data => {
                scanThemesProc.themeBuffer += data + "\n";
            }
        }

        // qmllint disable signal-handler-parameters
        onExited: {
            let lines = scanThemesProc.themeBuffer.split("\n");
            let tempArr = [];
            for (let i = 0; i < lines.length; i++) {
                let line = lines[i].trim();
                if (!line)
                    continue;

                let parts = line.split("|");
                if (parts.length === 3) {
                    tempArr.push({
                        name: parts[0],
                        bgHex: parts[1],
                        accHex: parts[2]
                    });
                }
            }
            themeRoot.themeData = tempArr;
            scanThemesProc.themeBuffer = ""; // Clear memory
        }
    }

    // ==========================================
    // 3. UI LAYOUT
    // ==========================================
    Column {
        anchors.fill: parent
        spacing: 16

        // --- HEADER ---
        Item {
            width: parent.width
            height: 36

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: backArea.containsMouse ? Colors.bg2 : Colors.bg1
                    border.color: Colors.bg3
                    border.width: 1

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰁍"
                        font.family: Config.fontName
                        font.pixelSize: 18
                        color: Colors.fg0
                    }
                    MouseArea {
                        id: backArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: themeRoot.backRequested()
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Themes"
                    font.family: Config.fontName
                    font.pixelSize: 16
                    font.bold: true
                    color: Colors.fg0
                }
            }
        }

        // --- DYNAMIC THEME GRID ---
        Flickable {
            width: parent.width
            height: parent.height - 53
            contentHeight: grid.height
            clip: true

            Grid {
                id: grid
                width: parent.width
                columns: 3
                spacing: 12

                Repeater {
                    model: themeRoot.themeData

                    Rectangle {
                        id: delegateRect
                        required property int index
                        required property var modelData

                        width: (parent.width - 24) / 3
                        height: 72
                        radius: 12
                        clip: true

                        property bool isSelected: themeRoot.activeTheme === modelData.name
                        property bool isApplying: themeRoot.pendingTheme === modelData.name

                        color: modelData.bgHex
                        border.color: isSelected ? modelData.accHex : "transparent"
                        border.width: 2

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 12
                            color: mouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 12

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "󰑐"
                                font.family: Config.fontName
                                font.pixelSize: 18
                                color: delegateRect.modelData.accHex
                                visible: delegateRect.isApplying

                                RotationAnimation on rotation {
                                    loops: Animation.Infinite
                                    from: 0
                                    to: 360
                                    duration: 1000
                                    running: delegateRect.isApplying
                                }
                            }

                            Rectangle {
                                width: 28
                                height: 6
                                radius: 3
                                color: delegateRect.modelData.accHex
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: !delegateRect.isApplying
                            }

                            Text {
                                text: delegateRect.modelData.name
                                color: delegateRect.isSelected ? delegateRect.modelData.accHex : Colors.fg1
                                font.family: Config.fontName
                                font.pixelSize: 13
                                font.bold: delegateRect.isSelected
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: !delegateRect.isApplying
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (themeRoot.activeTheme === delegateRect.modelData.name || themeRoot.pendingTheme !== "")
                                    return;

                                themeRoot.pendingTheme = delegateRect.modelData.name;
                                Quickshell.execDetached(["bash", "-c", "bash $HOME/.config/quickshell/scripts/theme.sh " + delegateRect.modelData.name]);
                            }
                        }
                    }
                }
            }
        }
    }
}
