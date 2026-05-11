import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "."

Item {
    id: tplRoot
    width: parent ? parent.width : 400
    height: 40

    signal closeMainPanel()

    property bool gtkEnabled: false
    property bool zedEnabled: false

    Process {
        id: checkFlags
        command: [
            "bash", 
            "-c", 
            "[[ -f ~/.cache/qs_gtk_enabled ]] && echo 'gtk'; [[ -f ~/.cache/qs_zed_enabled ]] && echo 'zed'"
        ]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data === "gtk") {
                    tplRoot.gtkEnabled = true 
                }
                if (data === "zed") {
                    tplRoot.zedEnabled = true 
                }
            }
        }
    }

    Timer {
        id: applyTimer
        interval: 1000 
        running: true
        onTriggered: {
            if (tplRoot.gtkEnabled) {
                tplRoot.applyGtk()
            }
            if (tplRoot.zedEnabled) {
                tplRoot.applyZed()
            }
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
@define-color popover_bg_color ${Colors.bg2};
@define-color popover_fg_color ${Colors.fg};
@define-color card_bg_color ${Colors.bg1};
@define-color card_fg_color ${Colors.fg};
@define-color dialog_bg_color ${Colors.bg0};
@define-color dialog_fg_color ${Colors.fg};
`
        let cmd = `mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0 && echo "${css}" > ~/.config/gtk-3.0/gtk.css && echo "${css}" > ~/.config/gtk-4.0/gtk.css && touch ~/.cache/qs_gtk_enabled`
        Quickshell.execDetached(["bash", "-c", cmd])

        let reloadCmd = `
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        if pacman -Qs adw-gtk3 > /dev/null; then
            gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
        else
            gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
        fi
        `
        Quickshell.execDetached(["bash", "-c", reloadCmd])
    }
    
    function removeGtk() { 
        Quickshell.execDetached(["bash", "-c", "rm -f ~/.config/gtk-3.0/gtk.css ~/.config/gtk-4.0/gtk.css ~/.cache/qs_gtk_enabled"]) 
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
        "status_bar.background": "${Colors.bg0}",
        "tab_bar.background": "${Colors.bg1}",
        "tab.inactive_background": "${Colors.bg1}",
        "tab.active_background": "${Colors.bg0}",
        "panel.background": "${Colors.bg0}",
        "editor.background": "${Colors.bg0}",
        "editor.foreground": "${Colors.fg}",
        "editor.line_number": "${Colors.grey0}",
        "editor.active_line_number": "${Colors.fg}",
        "editor.active_line.background": "${Colors.bg1}",
        "editor.gutter.background": "${Colors.bg0}",
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
          "punctuation": { "color": "${Colors.grey0}" },
          "operator": { "color": "${Colors.aqua}" },
          "tag": { "color": "${Colors.red}" }
        }
      }
    }
  ]
}`
        let cmd1 = `mkdir -p ~/.config/zed/themes && cat << 'EOF' > ~/.config/zed/themes/quickshell-sync.json\n${zedJson}\nEOF\ntouch ~/.cache/qs_zed_enabled`
        Quickshell.execDetached(["bash", "-c", cmd1])
        
        let cmd2 = `sed -i 's/"theme":.*/"theme": "Quickshell Sync",/' ~/.config/zed/settings.json || sed -i '1s/{/{\\n  "theme": "Quickshell Sync",/' ~/.config/zed/settings.json`
        Quickshell.execDetached(["bash", "-c", cmd2])
    }
    
    function removeZed() { 
        Quickshell.execDetached(["bash", "-c", "rm -f ~/.cache/qs_zed_enabled"]) 
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Colors.bg1
        border.width: 1
        border.color: Colors.bg2
        
        Row {
            anchors.centerIn: parent
            spacing: 10
            Text { 
                text: "󰏘"
                color: Colors.aqua
                font.pixelSize: 16
                font.family: "JetBrainsMono Nerd Font"
                anchors.verticalCenter: parent.verticalCenter 
            }
            Text { 
                text: "External App Templates"
                color: Colors.fg
                font.bold: true
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter 
            }
        }
        
        MouseArea { 
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: { 
                tplRoot.closeMainPanel()
                themerWindow.visible = true 
            } 
        }
    }

    PanelWindow {
        id: themerWindow
        anchors { 
            top: true
            bottom: true
            left: true
            right: true 
        }
        color: "transparent"
        visible: false
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea { 
            anchors.fill: parent
            hoverEnabled: true
            onClicked: { 
                themerWindow.visible = false 
            } 
        }

        Rectangle {
            anchors.centerIn: parent
            width: 320
            height: 140
            color: Qt.alpha(Colors.bg0, 0.98)
            radius: 12
            border.color: Colors.bg2
            border.width: 1

            MouseArea { 
                anchors.fill: parent 
            }

            focus: true
            Keys.onEscapePressed: { 
                themerWindow.visible = false 
            }
            onVisibleChanged: { 
                if (visible) {
                    forceActiveFocus()
                }
            }

            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: " Apply Templates"
                        color: Colors.green
                        font.pixelSize: 16
                        font.bold: true
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Apply colors to external applications."
                        color: Colors.grey1
                        font.pixelSize: 11
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 15

                    Rectangle {
                        width: 120
                        height: 40
                        radius: 8
                        color: tplRoot.gtkEnabled ? Colors.green : Colors.bg1
                        border.color: tplRoot.gtkEnabled ? Colors.green : Colors.bg2
                        border.width: 1
                        Text { 
                            anchors.centerIn: parent
                            text: "GTK Apps"
                            color: tplRoot.gtkEnabled ? Colors.bg0 : Colors.fg
                            font.bold: true
                            font.pixelSize: 13
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                tplRoot.gtkEnabled = !tplRoot.gtkEnabled
                                if (tplRoot.gtkEnabled) {
                                    tplRoot.applyGtk()
                                } else {
                                    tplRoot.removeGtk()
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: 120
                        height: 40
                        radius: 8
                        color: tplRoot.zedEnabled ? Colors.green : Colors.bg1
                        border.color: tplRoot.zedEnabled ? Colors.green : Colors.bg2
                        border.width: 1
                        Text { 
                            anchors.centerIn: parent
                            text: "Zed Editor"
                            color: tplRoot.zedEnabled ? Colors.bg0 : Colors.fg
                            font.bold: true
                            font.pixelSize: 13
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                tplRoot.zedEnabled = !tplRoot.zedEnabled
                                if (tplRoot.zedEnabled) {
                                    tplRoot.applyZed()
                                } else {
                                    tplRoot.removeZed()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
