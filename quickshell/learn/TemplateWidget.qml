import QtQuick
import QtQuick.Controls 
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "."

Rectangle {
    id: templateBtn
    width: 30; height: 30; radius: 15
    color: themerWindow.visible ? Colors.green : Colors.bg1 
    border.width: 1
    border.color: Colors.bg2
    Behavior on color { ColorAnimation { duration: 200 } }

    Text {
        anchors.centerIn: parent
        text: "󰏘" // Paintbrush Icon
        font.pixelSize: 15
        font.family: "JetBrainsMono Nerd Font"
        color: themerWindow.visible ? Colors.bg0 : Colors.fg 
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            themerWindow.visible = !themerWindow.visible;
            if (themerWindow.visible) bgRect.forceActiveFocus();
        }
    }

    property bool gtkEnabled: false
    property bool zedEnabled: false

    Process {
        id: checkFlags
        command: ["bash", "-c", "[[ -f ~/.cache/qs_gtk_enabled ]] && echo 'gtk'; [[ -f ~/.cache/qs_zed_enabled ]] && echo 'zed'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data === "gtk") templateBtn.gtkEnabled = true;
                if (data === "zed") templateBtn.zedEnabled = true;
            }
        }
    }

    Timer {
        id: applyTimer
        interval: 1000 
        running: true
        onTriggered: {
            if (templateBtn.gtkEnabled) templateBtn.applyGtk();
            if (templateBtn.zedEnabled) templateBtn.applyZed();
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
`;
        let cmd = `mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0 && echo "${css}" > ~/.config/gtk-3.0/gtk.css && echo "${css}" > ~/.config/gtk-4.0/gtk.css && touch ~/.cache/qs_gtk_enabled`;
        Quickshell.execDetached(["bash", "-c", cmd]);

        let reloadCmd = `
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        if pacman -Qs adw-gtk3 > /dev/null; then
            gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
        else
            gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
        fi
        `;
        Quickshell.execDetached(["bash", "-c", reloadCmd]);
    }

    function removeGtk() {
        Quickshell.execDetached(["bash", "-c", "rm -f ~/.config/gtk-3.0/gtk.css ~/.config/gtk-4.0/gtk.css ~/.cache/qs_gtk_enabled"]);
    }

    function applyZed() {
        // HUGE Zed Upgrade: Added massive Syntax Highlighting block so code looks gorgeous!
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
        "terminal.ansi.magenta": "${Colors.magenta}",
        "terminal.ansi.cyan": "${Colors.cyan}",
        "terminal.ansi.white": "${Colors.fg}",
        "syntax": {
          "keyword": { "color": "${Colors.magenta}" },
          "control": { "color": "${Colors.magenta}" },
          "boolean": { "color": "${Colors.orange}" },
          "function": { "color": "${Colors.blue}" },
          "string": { "color": "${Colors.green}" },
          "number": { "color": "${Colors.orange}" },
          "property": { "color": "${Colors.cyan}" },
          "attribute": { "color": "${Colors.cyan}" },
          "type": { "color": "${Colors.yellow}" },
          "constructor": { "color": "${Colors.yellow}" },
          "comment": { "color": "${Colors.grey1}", "font_style": "italic" },
          "variable": { "color": "${Colors.fg}" },
          "constant": { "color": "${Colors.orange}" },
          "punctuation": { "color": "${Colors.grey0}" },
          "operator": { "color": "${Colors.cyan}" },
          "tag": { "color": "${Colors.red}" }
        }
      }
    }
  ]
}`;
        let cmd1 = `mkdir -p ~/.config/zed/themes && cat << 'EOF' > ~/.config/zed/themes/quickshell-sync.json\n${zedJson}\nEOF\ntouch ~/.cache/qs_zed_enabled`;
        Quickshell.execDetached(["bash", "-c", cmd1]);
        
        let cmd2 = `sed -i 's/"theme":.*/"theme": "Quickshell Sync",/' ~/.config/zed/settings.json || sed -i '1s/{/{\\n  "theme": "Quickshell Sync",/' ~/.config/zed/settings.json`;
        Quickshell.execDetached(["bash", "-c", cmd2]);
    }

    function removeZed() {
        Quickshell.execDetached(["bash", "-c", "rm -f ~/.cache/qs_zed_enabled"]);
    }

    // --- POPUP UI WINDOW ---
    PanelWindow {
        id: themerWindow
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        visible: false

        MouseArea {
            anchors.fill: parent
            onClicked: themerWindow.visible = false
        }

        Rectangle {
            id: bgRect
            anchors.centerIn: parent
            width: 500; height: 250 // Made it smaller since tabs are gone!
            color: Qt.alpha(Colors.bg0, 0.90)
            radius: 12
            border.color: Colors.bg2
            border.width: 1
            focus: true
            Keys.onEscapePressed: themerWindow.visible = false

            MouseArea { anchors.fill: parent } 

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                // TITLE & CLOSE
                Row {
                    width: parent.width
                    Text {
                        text: " Templates"
                        color: Colors.green
                        font.pixelSize: 20
                        font.bold: true
                    }
                    Item { width: parent.width - 170 } // Spacer
                    Rectangle {
                        width: 30; height: 30; radius: 15
                        color: closeMouse.containsMouse ? Colors.red : Colors.bg1
                        Text { anchors.centerIn: parent; text: "✕"; color: Colors.fg; font.pixelSize: 14 }
                        MouseArea {
                            id: closeMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: themerWindow.visible = false
                        }
                    }
                }

                Text {
                    text: "Apply colors to external applications."
                    color: Colors.grey1
                    font.pixelSize: 14
                }

                Rectangle { width: parent.width; height: 1; color: Colors.bg2 }

                // TEMPLATE TOGGLES
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20

                    // GTK BUTTON
                    Rectangle {
                        width: 150; height: 45; radius: 8
                        color: templateBtn.gtkEnabled ? Colors.green : Colors.bg1
                        border.color: templateBtn.gtkEnabled ? Colors.green : Colors.bg2; border.width: 1
                        Text { 
                            anchors.centerIn: parent; text: "GTK Apps"
                            color: templateBtn.gtkEnabled ? Colors.bg0 : Colors.fg; font.bold: true; font.pixelSize: 14
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                templateBtn.gtkEnabled = !templateBtn.gtkEnabled;
                                if (templateBtn.gtkEnabled) templateBtn.applyGtk();
                                else templateBtn.removeGtk();
                            }
                        }
                    }

                    // ZED BUTTON
                    Rectangle {
                        width: 150; height: 45; radius: 8
                        color: templateBtn.zedEnabled ? Colors.green : Colors.bg1
                        border.color: templateBtn.zedEnabled ? Colors.green : Colors.bg2; border.width: 1
                        Text { 
                            anchors.centerIn: parent; text: "Zed Editor"
                            color: templateBtn.zedEnabled ? Colors.bg0 : Colors.fg; font.bold: true; font.pixelSize: 14
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                templateBtn.zedEnabled = !templateBtn.zedEnabled;
                                if (templateBtn.zedEnabled) templateBtn.applyZed();
                                else templateBtn.removeZed();
                            }
                        }
                    }
                }
            }
        }
    }
}
