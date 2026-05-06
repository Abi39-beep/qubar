import QtQuick
import QtQuick.Controls 
import QtQuick.Effects 
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland 
import Quickshell.Services.Pipewire
import Quickshell.Services.Notifications
import "."

Rectangle {
    id: dashWidget
    width: 30; height: 30; radius: 15
    color: dashPopup.visible ? Colors.blue : Colors.bg1 
    border.width: 1
    border.color: Colors.bg2

    Behavior on color { ColorAnimation { duration: 200 } }

    Text {
        anchors.centerIn: parent
        text: "󰕮" 
        font.pixelSize: 15
        font.family: "JetBrainsMono Nerd Font"
        color: dashPopup.visible ? Colors.bg0 : Colors.fg 
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            dashPopup.visible = !dashPopup.visible;
            if (dashPopup.visible && dashWidget.activeTab === 1) {
                refreshClip.running = false;
                resetTimer.start();
            }
        }
    }

    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0) return "0:00";
        let m = Math.floor(seconds / 60);
        let s = Math.floor(seconds % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    GlobalShortcut {
        name: "powermenu" 
        onPressed: {
            if (!powerMenuWindow.visible) {
                powerMenuWindow.visible = true
                bgDimmer.forceActiveFocus() 
                powerList.forceActiveFocus() 
            } else {
                powerMenuWindow.closeMenu()
            }
        }
    }

    property int activeTab: 0 

    // ==========================================
    // EXTERNAL TEMPLATES LOGIC (GTK & ZED)
    // ==========================================
    property bool gtkEnabled: false
    property bool zedEnabled: false

    Process {
        id: checkFlags
        command:["bash", "-c", "[[ -f ~/.cache/qs_gtk_enabled ]] && echo 'gtk'; [[ -f ~/.cache/qs_zed_enabled ]] && echo 'zed'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data === "gtk") dashWidget.gtkEnabled = true;
                if (data === "zed") dashWidget.zedEnabled = true;
            }
        }
    }

    Timer {
        id: applyTimer
        interval: 1000 
        running: true
        onTriggered: {
            if (dashWidget.gtkEnabled) dashWidget.applyGtk();
            if (dashWidget.zedEnabled) dashWidget.applyZed();
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
    // ==========================================

    // Audio
    PwObjectTracker { objects: Pipewire.defaultAudioSink ?[Pipewire.defaultAudioSink] :[] }
    property var audio: Pipewire.defaultAudioSink?.audio
    property int volPercent: audio ? Math.round(audio.volume * 100) : 0
    property bool isMuted: audio ? audio.muted : false

    // Brightness
    property int briPercent: 50 
    Timer {
        interval: 2000; running: true; repeat: true
        onTriggered: getBri.running = true
        Component.onCompleted: getBri.running = true 
    }
    Process {
        id: getBri
        command:["brightnessctl", "-m"]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.split(",");
                if (parts.length >= 4) { dashWidget.briPercent = parseInt(parts[3].replace("%", "")); }
            }
        }
    }

    // --- SYSTEM STATS ---
    property string cpuUsage: "0.0%"
    property string memUsage: "0 MB"

    Timer {
        id: statTimer
        interval: 2000; running: true; repeat: true
        onTriggered: { cpuPoll.running = true; memPoll.running = true; }
        Component.onCompleted: { cpuPoll.running = true; memPoll.running = true; }
    }

    Process {
        id: cpuPoll
        command:["bash", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4}'"]
        stdout: SplitParser { onRead: data => { if (data.trim() !== "") dashWidget.cpuUsage = parseFloat(data).toFixed(1) + "%"; } }
    }

    Process {
        id: memPoll
        command:["bash", "-c", "free -m | awk '/Mem:/ { if($3 < 1024) printf \"%d MB\", $3; else printf \"%.1f GB\", $3/1024 }'"]
        stdout: SplitParser { onRead: data => { if (data.trim() !== "") dashWidget.memUsage = data.trim(); } }
    }

    // --- MEDIA CONTROLLER ---
    property string mediaStatus: "Stopped"
    property string mediaTitle: "No Media Playing"
    property string mediaArtist: ""
    property string mediaArt: ""
    property real mediaLength: 0
    property real mediaPosition: 0

    Timer {
        id: mediaPollTimer
        interval: 1000 
        running: true; repeat: true
        onTriggered: { 
            if (!mediaWatcher.running) mediaWatcher.running = true; 
            if (dashWidget.mediaStatus === "Playing" && !mediaPosWatcher.running) mediaPosWatcher.running = true;
        }
    }

    Process {
        id: mediaWatcher
        command:["playerctl", "metadata", "--format", "{{status}}||{{title}}||{{artist}}||{{mpris:artUrl}}||{{mpris:length}}"]
        
        stdout: SplitParser {
            onRead: data => {
                let parts = data.split("||");
                if (parts.length >= 5) {
                    dashWidget.mediaStatus = parts[0].trim();
                    dashWidget.mediaTitle = parts[1].trim() || "Unknown Title";
                    dashWidget.mediaArtist = parts[2] ? parts[2].trim() : "Unknown Artist";
                    dashWidget.mediaArt = parts[3] ? parts[3].trim() : "";
                    
                    let len = parseInt(parts[4].trim());
                    dashWidget.mediaLength = isNaN(len) ? 0 : (len / 1000000.0);
                }
            }
        }
        onExited: (code) => {
            if (code !== 0) {
                dashWidget.mediaStatus = "Stopped";
                dashWidget.mediaTitle = "No Media Playing";
                dashWidget.mediaArtist = "";
                dashWidget.mediaArt = "";
                dashWidget.mediaLength = 0;
                dashWidget.mediaPosition = 0;
            }
        }
    }

    Process {
        id: mediaPosWatcher
        command:["playerctl", "position"]
        stdout: SplitParser {
            onRead: data => {
                let pos = parseFloat(data.trim());
                if (!isNaN(pos) && !mediaProgress.pressed) {
                    dashWidget.mediaPosition = pos;
                }
            }
        }
    }

    Process { id: executor; property string currentCommand: ""; command:["bash", "-c", currentCommand] }
    property var actionModel:[
        { name: "Lock", icon: "", cmd: "$HOME/.config/hypr/hyprlock.sh", color: Colors.blue },
        { name: "Sleep", icon: "󰤄", cmd: "systemctl suspend", color: Colors.blue },
        { name: "Logout", icon: "󰍃", cmd: "hyprctl dispatch exit", color: Colors.orange },
        { name: "Reboot", icon: "", cmd: "systemctl reboot", color: Colors.orange },
        { name: "Power", icon: "", cmd: "systemctl poweroff", color: Colors.red }
    ]

    Timer {
        id: resetTimer
        interval: 10
        onTriggered: {
            refreshClip.command =["bash", "-c", "cliphist list #" + Date.now()];
            refreshClip.fullOutput = ""; 
            refreshClip.running = true;
        }
    }
    ListModel { id: clipModel }
    Process {
        id: refreshClip
        command:["bash", "-c", "cliphist list"]
        property string fullOutput: ""
        stdout: SplitParser { onRead: data => { refreshClip.fullOutput += data + "\n"; } }
        onExited: {
            clipModel.clear();
            let lines = fullOutput.split("\n");
            fullOutput = ""; 
            let count = 0;
            for (let i = 0; i < lines.length; i++) {
                if (!lines[i].trim()) continue; 
                let sep = lines[i].indexOf('\t');
                if (sep !== -1) {
                    let id = lines[i].substring(0, sep);
                    let text = lines[i].substring(sep + 1);
                    clipModel.append({ "clipId": id, "clipText": text, "justCopied": false });
                    count++;
                    if (count >= 30) break; 
                }
            }
        }
    }

    NotificationServer {
        id: server
        onNotification: (notification) => { notification.tracked = true; }
    }

    Component {
        id: notifDelegate
        Rectangle {
            id: cardRoot
            width: parent ? parent.width : 320
            property bool isOsd: ListView.view === null
            property bool osdExpired: false
            
            visible: isOsd ? !osdExpired : true
            implicitHeight: visible ? (contentCol.implicitHeight + 24) : 0
            color: Colors.bg0
            border.color: (modelData && modelData.urgency === 2) ? Colors.red : Colors.blue
            border.width: 1; radius: 12
            clip: true

            Timer { interval: 5000; running: cardRoot.isOsd && modelData && modelData.urgency !== 2 && !cardRoot.osdExpired; onTriggered: cardRoot.osdExpired = true }

            Row {
                anchors.fill: parent; anchors.margins: 12; spacing: 10
                Column {
                    id: contentCol
                    width: parent.width - 34; spacing: 4
                    Row {
                        spacing: 6
                        height: Math.max(iconTxt.implicitHeight, appTxt.implicitHeight) 
                        Text { id: iconTxt; text: "󰎆"; color: Colors.blue; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                        Text { id: appTxt; text: (modelData && modelData.appName) ? modelData.appName : "System"; color: Colors.blue; font.pixelSize: 11; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                    }
                    Text { text: (modelData && modelData.summary) ? modelData.summary : ""; color: Colors.fg; font.pixelSize: 13; font.bold: true; width: parent.width; wrapMode: Text.Wrap }
                    Text { text: ((modelData && modelData.body) ? modelData.body : "").replace(/<[^>]*>?/gm, ''); color: Colors.grey1; font.pixelSize: 12; width: parent.width; wrapMode: Text.Wrap; visible: text.length > 0; maximumLineCount: cardRoot.isOsd ? 3 : 10; elide: Text.ElideRight }
                }
            }

            Rectangle {
                anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 12; width: 24; height: 24; radius: 4
                color: closeMouse.containsMouse ? Colors.red : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }
                Text { 
                    anchors.centerIn: parent; text: "󰅖"; color: closeMouse.containsMouse ? Colors.bg0 : Colors.grey1; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"
                    rotation: closeMouse.containsMouse ? 90 : 0
                    Behavior on rotation { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                }
                MouseArea {
                    id: closeMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (cardRoot.isOsd) cardRoot.osdExpired = true;
                        else { if (modelData) try { modelData.dismiss(); } catch(e) {} }
                    }
                }
            }

            Rectangle {
                id: timeoutBar
                height: 3; width: cardRoot.isOsd ? parent.width : 0
                color: (modelData && modelData.urgency === 2) ? Colors.red : Colors.blue
                anchors.bottom: parent.bottom; anchors.left: parent.left
                opacity: cardRoot.isOsd ? 1 : 0
                PropertyAnimation on width { from: cardRoot.width; to: 0; duration: 5000; running: cardRoot.isOsd && modelData && modelData.urgency !== 2 }
            }
        }
    }

    // ==========================================
    // 2. DASHBOARD POPUP WINDOW 
    // ==========================================
    PanelWindow {
        id: dashPopup
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        
        WlrLayershell.layer: WlrLayer.Overlay 
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand 
        visible: false
        
        onVisibleChanged: { if (visible) bgRect.forceActiveFocus() }

        MouseArea { anchors.fill: parent; onClicked: dashPopup.visible = false }

        Rectangle {
            id: bgRect
            anchors.top: parent.top; anchors.right: parent.right
            anchors.topMargin: 45; anchors.rightMargin: 15    
            width: 380; height: 810 
            color: Qt.alpha(Colors.bg0, 0.95); border.color: Colors.bg2; border.width: 1; radius: 16
            focus: true
            Keys.onEscapePressed: dashPopup.visible = false
            MouseArea { anchors.fill: parent }

            Column {
                anchors.fill: parent; anchors.margins: 15; spacing: 15

                // --- POWER OPTIONS ROW ---
                Row {
                    width: parent.width; spacing: 10
                    Repeater {
                        model: dashWidget.actionModel
                        Rectangle {
                            width: (parent.width - 40) / 5; height: 60; radius: 10
                            color: powerMouse.containsMouse ? Colors.bg2 : Colors.bg1; border.width: 1; border.color: Colors.bg2
                            Behavior on color { ColorAnimation { duration: 150 } }
                            scale: powerMouse.pressed ? 0.92 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }

                            Column {
                                anchors.centerIn: parent; spacing: 4
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.icon; color: modelData.color; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font" }
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.name; color: Colors.fg; font.pixelSize: 10; font.bold: true }
                            }
                            MouseArea {
                                id: powerMouse
                                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    dashPopup.visible = false;
                                    powerMenuWindow.visible = true;
                                    bgDimmer.forceActiveFocus();
                                    powerList.forceActiveFocus();
                                    powerMenuWindow.handleTrigger(index, modelData.cmd);
                                }
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Colors.bg2 }

                // --- MEDIA CONTROLLER ---
                Item {
                    width: parent.width; height: 110 
                    Rectangle {
                        id: mediaBaseRect
                        anchors.fill: parent; radius: 12; color: Colors.bg1; border.width: 1; border.color: Colors.bg2
                        
                        Image {
                            id: artImage
                            anchors.fill: parent; anchors.margins: 1
                            source: {
                                if (!dashWidget.mediaArt) return "";
                                if (dashWidget.mediaArt.startsWith("http") || dashWidget.mediaArt.startsWith("file://")) return dashWidget.mediaArt;
                                return "file://" + dashWidget.mediaArt; 
                            }
                            fillMode: Image.PreserveAspectCrop; visible: false
                            layer.enabled: true 
                        }

                        Rectangle {
                            id: maskRect
                            anchors.fill: parent; anchors.margins: 1; radius: 11
                            color: "black"; visible: false
                            layer.enabled: true 
                        }

                        MultiEffect {
                            anchors.fill: maskRect
                            source: artImage
                            maskEnabled: true
                            maskSource: maskRect
                            opacity: dashWidget.mediaArt !== "" ? 0.6 : 0
                            Behavior on opacity { NumberAnimation { duration: 300 } }
                        }
                        
                        Rectangle {
                            anchors.fill: parent; anchors.margins: 1; radius: 11
                            color: dashWidget.mediaArt !== "" ? "#B3000000" : "transparent"
                            Behavior on color { ColorAnimation { duration: 300 } }
                        }
                        
                        Item {
                            anchors.fill: parent; anchors.margins: 12

                            Item {
                                anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                                height: 40

                                Column {
                                    anchors.left: parent.left; anchors.right: btnRow.left; anchors.rightMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter; spacing: 4
                                    Text { text: dashWidget.mediaTitle; color: Colors.fg; font.pixelSize: 14; font.bold: true; elide: Text.ElideRight; maximumLineCount: 1; width: parent.width }
                                    Text { text: dashWidget.mediaArtist; color: Colors.grey1; font.pixelSize: 12; elide: Text.ElideRight; maximumLineCount: 1; width: parent.width }
                                }
                                
                                Row {
                                    id: btnRow
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; spacing: 8
                                    Rectangle {
                                        width: 30; height: 30; radius: 15; color: hoverPrev.containsMouse ? Colors.bg2 : "transparent"
                                        scale: hoverPrev.pressed ? 0.9 : 1.0; Behavior on scale { NumberAnimation { duration: 100 } }
                                        Text { anchors.centerIn: parent; text: "󰒮"; color: Colors.fg; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font" }
                                        MouseArea { id: hoverPrev; anchors.fill: parent; hoverEnabled: true; onClicked: { Quickshell.execDetached(["playerctl", "previous"]); mediaWatcher.running = true; } }
                                    }
                                    Rectangle {
                                        width: 36; height: 36; radius: 18; color: Colors.blue
                                        scale: hoverPlay.pressed ? 0.9 : 1.0; Behavior on scale { NumberAnimation { duration: 100 } }
                                        Text { 
                                            anchors.centerIn: parent; text: dashWidget.mediaStatus === "Playing" ? "󰏤" : "󰐊"; color: Colors.bg0; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"
                                            anchors.horizontalCenterOffset: dashWidget.mediaStatus === "Playing" ? 0 : 2 
                                        }
                                        MouseArea { id: hoverPlay; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { Quickshell.execDetached(["playerctl", "play-pause"]); mediaWatcher.running = true; } }
                                    }
                                    Rectangle {
                                        width: 30; height: 30; radius: 15; color: hoverNext.containsMouse ? Colors.bg2 : "transparent"
                                        scale: hoverNext.pressed ? 0.9 : 1.0; Behavior on scale { NumberAnimation { duration: 100 } }
                                        Text { anchors.centerIn: parent; text: "󰒭"; color: Colors.fg; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font" }
                                        MouseArea { id: hoverNext; anchors.fill: parent; hoverEnabled: true; onClicked: { Quickshell.execDetached(["playerctl", "next"]); mediaWatcher.running = true; } }
                                    }
                                }
                            }

                            Item {
                                anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                                height: 35
                                
                                Text {
                                    anchors.left: parent.left; anchors.top: parent.top
                                    text: dashWidget.formatTime(dashWidget.mediaPosition)
                                    color: Colors.grey1; font.pixelSize: 11
                                }
                                
                                Text {
                                    anchors.right: parent.right; anchors.top: parent.top
                                    text: dashWidget.formatTime(dashWidget.mediaLength)
                                    color: Colors.grey1; font.pixelSize: 11
                                }

                                Slider {
                                    id: mediaProgress
                                    anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                                    height: 20; focusPolicy: Qt.NoFocus 
                                    from: 0; to: dashWidget.mediaLength > 0 ? dashWidget.mediaLength : 1
                                    value: dashWidget.mediaPosition
                                    
                                    onPressedChanged: {
                                        if (!pressed) { 
                                            Quickshell.execDetached(["playerctl", "position", value.toString()]);
                                            dashWidget.mediaPosition = value;
                                        }
                                    }
                                    
                                    background: Rectangle {
                                        x: mediaProgress.leftPadding; y: mediaProgress.topPadding + mediaProgress.availableHeight / 2 - height / 2; width: mediaProgress.availableWidth; height: 6; radius: 3; color: Colors.bg2
                                        Rectangle { width: mediaProgress.visualPosition * parent.width; height: parent.height; color: Colors.blue; radius: 3 }
                                    }
                                    handle: Rectangle {
                                        x: mediaProgress.leftPadding + mediaProgress.visualPosition * (mediaProgress.availableWidth - width); y: mediaProgress.topPadding + mediaProgress.availableHeight / 2 - height / 2; 
                                        width: 14; height: 14; radius: 7; color: Colors.bg0; border.color: Colors.blue
                                        border.width: mediaProgress.pressed ? 4 : 2
                                        scale: mediaProgress.hovered ? 1.2 : 1.0
                                        Behavior on border.width { NumberAnimation { duration: 150 } }
                                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                                    }
                                }
                            }
                        }
                    }
                }

                // --- HARDWARE STATS ---
                Row {
                    width: parent.width; height: 40; spacing: 10
                    
                    Rectangle {
                        width: (parent.width - 10) / 2; height: parent.height; radius: 8
                        color: Colors.bg1; border.width: 1; border.color: Colors.bg2
                        Row {
                            anchors.centerIn: parent; spacing: 10
                            Text { text: "󰻠"; color: Colors.blue; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                Text { text: "CPU"; color: Colors.grey1; font.pixelSize: 10; font.bold: true }
                                Text { text: dashWidget.cpuUsage; color: Colors.fg; font.pixelSize: 13; font.bold: true }
                            }
                        }
                    }
                    
                    Rectangle {
                        width: (parent.width - 10) / 2; height: parent.height; radius: 8
                        color: Colors.bg1; border.width: 1; border.color: Colors.bg2
                        Row {
                            anchors.centerIn: parent; spacing: 10
                            Text { text: "󰍛"; color: Colors.orange; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                Text { text: "Memory"; color: Colors.grey1; font.pixelSize: 10; font.bold: true }
                                Text { text: dashWidget.memUsage; color: Colors.fg; font.pixelSize: 13; font.bold: true }
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Colors.bg2 }

                // --- SLIDERS ---
                Item {
                    width: parent.width; height: 45
                    Item {
                        width: parent.width; height: 20
                        Row { anchors.left: parent.left; spacing: 8
                            Text { 
                                text: {
                                    if (dashWidget.isMuted || dashWidget.volPercent === 0) return "󰝟";
                                    if (dashWidget.volPercent < 33) return "󰕿";
                                    if (dashWidget.volPercent < 66) return "󰖀";
                                    return "󰕾";
                                }
                                color: Colors.blue; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter 
                            }
                            Text { text: "Volume"; color: Colors.blue; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                        }
                        Text { anchors.right: parent.right; text: dashWidget.volPercent + "%"; color: Colors.blue; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
                    }
                    Slider {
                        id: volSlider
                        anchors.bottom: parent.bottom; width: parent.width; height: 24 
                        from: 0; to: 100; focusPolicy: Qt.NoFocus 
                        value: dashWidget.volPercent
                        onMoved: { if (dashWidget.audio) dashWidget.audio.volume = value / 100.0; }
                        onPressedChanged: { if (!pressed) Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (value / 100.0).toFixed(2)]); }
                        MouseArea {
                            anchors.fill: parent; acceptedButtons: Qt.NoButton
                            onWheel: (wheel) => {
                                let newVol = dashWidget.volPercent + (wheel.angleDelta.y > 0 ? 5 : -5);
                                newVol = Math.max(0, Math.min(100, newVol));
                                if (dashWidget.audio) dashWidget.audio.volume = newVol / 100.0;
                                Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (newVol / 100.0).toFixed(2)]);
                            }
                        }
                        background: Rectangle {
                            x: volSlider.leftPadding; y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2; width: volSlider.availableWidth; height: 6; radius: 3; color: Colors.bg2
                            Rectangle { width: volSlider.visualPosition * parent.width; height: parent.height; color: Colors.blue; radius: 3 }
                        }
                        handle: Rectangle {
                            x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width); y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2; 
                            width: 16; height: 16; radius: 8; color: Colors.bg0; border.color: Colors.blue
                            border.width: volSlider.pressed ? 6 : 4
                            scale: volSlider.hovered ? 1.2 : 1.0
                            Behavior on border.width { NumberAnimation { duration: 150 } }
                            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        }
                    }
                }

                Item {
                    width: parent.width; height: 45
                    Item {
                        width: parent.width; height: 20
                        Row { anchors.left: parent.left; spacing: 8
                            Text { 
                                text: {
                                    if (dashWidget.briPercent < 33) return "󰃞";
                                    if (dashWidget.briPercent < 66) return "󰃟";
                                    return "󰃠";
                                }
                                color: Colors.orange; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter 
                            }
                            Text { text: "Brightness"; color: Colors.orange; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                        }
                        Text { anchors.right: parent.right; text: dashWidget.briPercent + "%"; color: Colors.orange; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
                    }
                    Slider {
                        id: briSlider
                        anchors.bottom: parent.bottom; width: parent.width; height: 24 
                        from: 0; to: 100; focusPolicy: Qt.NoFocus
                        value: dashWidget.briPercent
                        onMoved: { dashWidget.briPercent = Math.round(value); }
                        onPressedChanged: { if (!pressed) Quickshell.execDetached(["brightnessctl", "set", Math.round(value) + "%"]); }
                        MouseArea {
                            anchors.fill: parent; acceptedButtons: Qt.NoButton 
                            onWheel: (wheel) => {
                                let newBri = dashWidget.briPercent + (wheel.angleDelta.y > 0 ? 5 : -5);
                                newBri = Math.max(0, Math.min(100, newBri));
                                dashWidget.briPercent = newBri; 
                                Quickshell.execDetached(["brightnessctl", "set", newBri + "%"]);
                            }
                        }
                        background: Rectangle {
                            x: briSlider.leftPadding; y: briSlider.topPadding + briSlider.availableHeight / 2 - height / 2; width: briSlider.availableWidth; height: 6; radius: 3; color: Colors.bg2
                            Rectangle { width: briSlider.visualPosition * parent.width; height: parent.height; color: Colors.orange; radius: 3 }
                        }
                        handle: Rectangle {
                            x: briSlider.leftPadding + briSlider.visualPosition * (briSlider.availableWidth - width); y: briSlider.topPadding + briSlider.availableHeight / 2 - height / 2; 
                            width: 16; height: 16; radius: 8; color: Colors.bg0; border.color: Colors.orange
                            border.width: briSlider.pressed ? 6 : 4
                            scale: briSlider.hovered ? 1.2 : 1.0
                            Behavior on border.width { NumberAnimation { duration: 150 } }
                            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Colors.bg2 }

                // ==========================================
                // 5. EXTERNAL TEMPLATES BUTTON 
                // ==========================================
                Rectangle {
                    id: themerBtn
                    width: parent.width; height: 40; radius: 8
                    color: themerBtnMouse.containsMouse || themerWindow.visible ? Colors.bg2 : Colors.bg1
                    border.width: 1; border.color: Colors.bg2
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    Row {
                        anchors.centerIn: parent; spacing: 10
                        Text { text: "󰏘"; color: Colors.blue; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "External App Templates"; color: Colors.fg; font.bold: true; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                    }
                    
                    MouseArea {
                        id: themerBtnMouse
                        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            dashPopup.visible = false;
                            themerWindow.visible = true;
                            themerBg.forceActiveFocus();
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Colors.bg2 }

                // --- 6. TAB SELECTOR ---
                Row {
                    width: parent.width; height: 30; spacing: 10
                    
                    Rectangle {
                        width: (parent.width - 10) / 2; height: 30; radius: 6
                        color: dashWidget.activeTab === 0 ? Colors.bg2 : "transparent"
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Row { 
                            anchors.centerIn: parent; spacing: 6
                            Text { text: "󰂚"; color: Colors.fg; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "Notifications"; color: Colors.fg; font.bold: true; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: dashWidget.activeTab = 0 }
                    }
                    
                    Rectangle {
                        width: (parent.width - 10) / 2; height: 30; radius: 6
                        color: dashWidget.activeTab === 1 ? Colors.bg2 : "transparent"
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Row { 
                            anchors.centerIn: parent; spacing: 6
                            Text { text: "󰅌"; color: Colors.fg; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "Clipboard"; color: Colors.fg; font.bold: true; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                        }
                        MouseArea { 
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: { dashWidget.activeTab = 1; refreshClip.running = false; resetTimer.start(); } 
                        }
                    }
                }

                // --- 7. LIST CONTENT AREA ---
                Item {
                    width: parent.width; height: parent.height - y
                    
                    // NOTIFICATIONS VIEW
                    Item {
                        anchors.fill: parent; visible: dashWidget.activeTab === 0
                        Rectangle {
                            width: 70; height: 24; radius: 4; color: Colors.red
                            anchors.top: parent.top; anchors.right: parent.right; z: 2 
                            scale: clearNotifMouse.pressed ? 0.9 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }
                            Row {
                                anchors.centerIn: parent; spacing: 4
                                Text { text: "󰆴"; color: Colors.bg0; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "Clear"; color: Colors.bg0; font.bold: true; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                            }
                            MouseArea {
                                id: clearNotifMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    try {
                                        let itemsToClear = server.trackedNotifications.values;
                                        for (let i = itemsToClear.length - 1; i >= 0; i--) itemsToClear[i].dismiss();
                                    } catch(err) {}
                                }
                            }
                        }

                        ListView {
                            id: notifList
                            anchors.fill: parent; anchors.topMargin: 34; clip: true; spacing: 8
                            model: server.trackedNotifications
                            delegate: notifDelegate
                        }
                        Text { anchors.centerIn: parent; text: "No new notifications"; color: Colors.grey0; font.pixelSize: 12; visible: notifList.count === 0 }
                    }

                    // CLIPBOARD VIEW
                    Item {
                        anchors.fill: parent; visible: dashWidget.activeTab === 1
                        Rectangle {
                            width: 70; height: 24; radius: 4; color: Colors.red
                            anchors.top: parent.top; anchors.right: parent.right; z: 2
                            scale: clearClipMouse.pressed ? 0.9 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }
                            Row {
                                anchors.centerIn: parent; spacing: 4
                                Text { text: "󰆴"; color: Colors.bg0; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "Clear"; color: Colors.bg0; font.bold: true; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                            }
                            MouseArea {
                                id: clearClipMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { Quickshell.execDetached(["cliphist", "wipe"]); clipModel.clear(); }
                            }
                        }

                        ListView {
                            anchors.fill: parent; anchors.topMargin: 34; clip: true; spacing: 6
                            model: clipModel
                            delegate: Item {
                                width: parent.width; height: 40
                                Rectangle { anchors.fill: parent; radius: 6; color: itemMouse.containsMouse ? Colors.bg2 : "transparent"; Behavior on color { ColorAnimation { duration: 150 } } }
                                
                                Timer { id: copySuccessTimer; interval: 1500; onTriggered: clipModel.setProperty(index, "justCopied", false) }

                                MouseArea {
                                    id: itemMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        let cmd = "cliphist list | awk -F $'\\t' '$1 == \"" + model.clipId + "\"' | cliphist decode | wl-copy";
                                        Quickshell.execDetached(["bash", "-c", cmd]);
                                        clipModel.setProperty(index, "justCopied", true);
                                        copySuccessTimer.restart();
                                    }
                                }
                                Row {
                                    anchors.fill: parent; anchors.margins: 6; spacing: 8
                                    Text { text: model.clipText; color: Colors.fg; font.pixelSize: 12; width: parent.width - 68; anchors.verticalCenter: parent.verticalCenter; elide: Text.ElideRight; maximumLineCount: 2; wrapMode: Text.Wrap }
                                    
                                    Rectangle {
                                        width: 26; height: 26; radius: 4; color: model.justCopied ? "transparent" : (copyMouse.containsMouse ? Colors.blue : Colors.bg3); anchors.verticalCenter: parent.verticalCenter
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                        Text { 
                                            anchors.centerIn: parent; text: model.justCopied ? "󰄬" : "󰆏"; color: model.justCopied ? "#A6E3A1" : (copyMouse.containsMouse ? Colors.bg0 : Colors.fg); font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" 
                                        }
                                        MouseArea {
                                            id: copyMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                let cmd = "cliphist list | awk -F $'\\t' '$1 == \"" + model.clipId + "\"' | cliphist decode | wl-copy";
                                                Quickshell.execDetached(["bash", "-c", cmd]);
                                                clipModel.setProperty(index, "justCopied", true);
                                                copySuccessTimer.restart();
                                            }
                                        }
                                    }
                                    Rectangle {
                                        width: 26; height: 26; radius: 4; color: delMouse.containsMouse ? Colors.red : "transparent"; anchors.verticalCenter: parent.verticalCenter
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                        Text { anchors.centerIn: parent; text: "󰆴"; color: delMouse.containsMouse ? Colors.bg0 : Colors.grey1; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
                                        MouseArea {
                                            id: delMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                let cmd = "cliphist list | awk -F $'\\t' '$1 == \"" + model.clipId + "\"' | cliphist delete";
                                                Quickshell.execDetached(["bash", "-c", cmd]);
                                                clipModel.remove(index);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // 3. FULL SCREEN POWER MENU OVERLAY
    // ==========================================
    PanelWindow {
        id: powerMenuWindow
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        
        WlrLayershell.layer: WlrLayer.Overlay 
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        
        visible: false
        
        property int activeIndex: -1
        property int countdown: 10
        
        function closeMenu() {
            visible = false
            activeIndex = -1
            countdownTimer.stop()
        }
        
        function executeAction(cmd) {
            countdownTimer.stop()
            executor.currentCommand = cmd
            executor.running = true
            closeMenu()
        }

        function handleTrigger(index, cmd) {
            if (activeIndex === index) {
                executeAction(cmd)
            } else {
                activeIndex = index
                countdown = 10
                countdownTimer.restart()
            }
        }

        Timer {
            id: countdownTimer; interval: 1000; repeat: true
            onTriggered: {
                powerMenuWindow.countdown--
                if (powerMenuWindow.countdown <= 0) {
                    let cmd = dashWidget.actionModel[powerMenuWindow.activeIndex].cmd
                    powerMenuWindow.executeAction(cmd)
                }
            }
        }

        Rectangle {
            id: bgDimmer
            anchors.fill: parent
            color: "#CC000000" 
            
            focus: true
            Keys.onEscapePressed: powerMenuWindow.closeMenu()

            MouseArea { anchors.fill: parent; onClicked: powerMenuWindow.closeMenu() }

            ListView {
                id: powerList
                anchors.centerIn: parent
                width: (120 * 5) + (20 * 4) 
                height: 120
                orientation: ListView.Horizontal
                spacing: 20
                focus: true
                
                Keys.onEscapePressed: powerMenuWindow.closeMenu()
                Keys.onLeftPressed: currentIndex = Math.max(0, currentIndex - 1)
                Keys.onRightPressed: currentIndex = Math.min(count - 1, currentIndex + 1)
                
                Keys.onReturnPressed: {
                    let currentItem = dashWidget.actionModel[currentIndex]
                    powerMenuWindow.handleTrigger(currentIndex, currentItem.cmd)
                }

                model: dashWidget.actionModel

                delegate: Rectangle {
                    id: btnRect
                    width: 120; height: 120; radius: 16
                    color: Colors.bg0
                    
                    property bool isActive: powerMenuWindow.activeIndex === index
                    property bool isFocused: powerList.currentIndex === index && powerList.activeFocus
                    
                    border.width: isActive ? 2 : (isFocused ? 1 : 1)
                    border.color: isActive ? Colors.red : (isFocused ? Colors.blue : Colors.bg2)

                    scale: fullPowerMouse.containsMouse || isFocused ? 1.05 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                    Column {
                        anchors.centerIn: parent; spacing: 12
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: btnRect.isActive ? powerMenuWindow.countdown : modelData.icon
                            font.pixelSize: 40; font.family: "JetBrainsMono Nerd Font"
                            color: btnRect.isActive ? Colors.red : modelData.color
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: btnRect.isActive ? "Confirm?" : modelData.name
                            font.pixelSize: 14; font.bold: true; color: Colors.fg
                        }
                    }

                    MouseArea {
                        id: fullPowerMouse
                        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onEntered: { powerList.currentIndex = index }
                        onClicked: {
                            powerList.currentIndex = index
                            powerList.forceActiveFocus()
                            powerMenuWindow.handleTrigger(index, modelData.cmd)
                        }
                    }
                }
            }
            
            Text {
                anchors.top: powerList.bottom; anchors.topMargin: 40
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Click once or press Enter to start 10s timer. Double click to execute instantly.\nPress Esc or click outside to cancel."
                horizontalAlignment: Text.AlignHCenter; color: Colors.grey1; font.pixelSize: 12
            }
        }
    }

    // ==========================================
    // 4. THEMER POPUP WINDOW (CENTERED)
    // ==========================================
    PanelWindow {
        id: themerWindow
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        visible: false

        // Click outside anywhere to close it instantly
        MouseArea {
            anchors.fill: parent
            onClicked: themerWindow.visible = false
        }

        Rectangle {
            id: themerBg
            anchors.centerIn: parent
            width: 320; height: 140 
            color: Qt.alpha(Colors.bg0, 0.98)
            radius: 12
            border.color: Colors.bg2
            border.width: 1
            focus: true
            
            Keys.onEscapePressed: themerWindow.visible = false

            MouseArea { anchors.fill: parent } // Prevent clicks falling through to the background

            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                // CLEAN TEXT, NO 'X' BUTTON
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

                // TEMPLATE TOGGLES
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 15

                    // GTK BUTTON
                    Rectangle {
                        width: 120; height: 40; radius: 8
                        color: dashWidget.gtkEnabled ? Colors.green : Colors.bg1
                        border.color: dashWidget.gtkEnabled ? Colors.green : Colors.bg2; border.width: 1
                        Text { 
                            anchors.centerIn: parent; text: "GTK Apps"
                            color: dashWidget.gtkEnabled ? Colors.bg0 : Colors.fg; font.bold: true; font.pixelSize: 13
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                dashWidget.gtkEnabled = !dashWidget.gtkEnabled;
                                if (dashWidget.gtkEnabled) dashWidget.applyGtk();
                                else dashWidget.removeGtk();
                            }
                        }
                    }

                    // ZED BUTTON
                    Rectangle {
                        width: 120; height: 40; radius: 8
                        color: dashWidget.zedEnabled ? Colors.green : Colors.bg1
                        border.color: dashWidget.zedEnabled ? Colors.green : Colors.bg2; border.width: 1
                        Text { 
                            anchors.centerIn: parent; text: "Zed Editor"
                            color: dashWidget.zedEnabled ? Colors.bg0 : Colors.fg; font.bold: true; font.pixelSize: 13
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                dashWidget.zedEnabled = !dashWidget.zedEnabled;
                                if (dashWidget.zedEnabled) dashWidget.applyZed();
                                else dashWidget.removeZed();
                            }
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // 5. FLOATING OSD
    // ==========================================
    PanelWindow {
        id: osdWindow
        anchors.top: true; anchors.right: true
        margins.top: 45; margins.right: 15
        
        implicitWidth: 335 
        implicitHeight: osdCol.implicitHeight > 0 ? (osdCol.implicitHeight + 60) : 1
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        visible: !dashPopup.visible 

        Column {
            id: osdCol
            width: 320; spacing: 10
            anchors.top: parent.top; anchors.right: parent.right

            Repeater {
                model: server.trackedNotifications
                delegate: notifDelegate
            }
        }
    }
}
