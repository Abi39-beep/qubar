import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick

PanelWindow {
    id: pillWindow
    color: "transparent"

    anchors {
        top: true
        left: false
        right: false
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top

    WlrLayershell.keyboardFocus: (pillWindow.viewState === 1 || pillWindow.viewState === 3 || pillWindow.viewState === 4 || pillWindow.viewState === 5) ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // --- THE ULTIMATE WAYLAND MASK FIX ---
    implicitWidth: Math.max(Config.expandedWidth, Config.launcherWidth, Config.powerMenuWidth, 600) + 50
    implicitHeight: Math.max(Config.expandedHeight, 600, Config.powerMenuHeight, Config.mediaCtrlHeight) + (Config.topMargin * 2) + 50

    mask: Region {
        item: pill
        Region {
            item: triggerZone
        }
    }

    property int viewState: 0

    onViewStateChanged: {
        if (viewState === 1 || viewState === 3 || viewState === 4 || viewState === 5) {
            pill.forceActiveFocus();
        } else if (viewState === 0) {
            pill.focus = false;
        }
    }

    property var activeWorkspaces: []
    property bool hasWindows: false

    function checkWindowState() {
        var fw = Hyprland.focusedWorkspace;
        if (fw && fw.toplevels && fw.toplevels.values) {
            let windows = fw.toplevels.values;
            for (let i = 0; i < windows.length; i++) {
                let win = windows[i];
                if (win.fullscreen) {
                    pillWindow.hasWindows = true;
                    return;
                }
                let isFloating = false;
                if (typeof win.isFloating !== "undefined")
                    isFloating = win.isFloating;
                else if (typeof win.floating !== "undefined")
                    isFloating = win.floating;
                else if (win.lastIpcObject && typeof win.lastIpcObject.floating !== "undefined")
                    isFloating = win.lastIpcObject.floating;
                if (!isFloating) {
                    pillWindow.hasWindows = true;
                    return;
                }
            }
            pillWindow.hasWindows = false;
            return;
        }
        pillWindow.hasWindows = false;
    }

    property bool isMediaPlaying: false

    function checkMediaState() {
        let players = Mpris.players.values;
        let playing = false;
        for (let i = 0; i < players.length; i++) {
            if (players[i] && players[i].playbackState === 1) {
                playing = true;
                break;
            }
        }
        pillWindow.isMediaPlaying = playing;
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            checkMediaState();
            checkWindowState();
        }
    }

    property bool isHoverTriggered: false
    // FIX: State 6 added here so it can show up over fullscreen apps!
    property bool isVisible: !hasWindows || isHoverTriggered || viewState === 1 || viewState === 2 || viewState === 3 || viewState === 4 || viewState === 5 || viewState === 6

    function refreshWorkspaces() {
        var rawWorkspaces = Hyprland.workspaces.values;
        var safeWbs = [];
        var currentFocusedId = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1;
        for (var i = 0; i < rawWorkspaces.length; i++) {
            var ws = rawWorkspaces[i];
            if (ws) {
                var hasToplevels = (ws.toplevels && ws.toplevels.values.length > 0);
                if (ws.id === currentFocusedId || hasToplevels)
                    safeWbs.push({
                        id: ws.id
                    });
            }
        }
        safeWbs.sort(function (a, b) {
            return a.id - b.id;
        });
        pillWindow.activeWorkspaces = safeWbs;
    }

    Connections {
        target: Hyprland
        function onWorkspacesChanged() {
            pillWindow.refreshWorkspaces();
            pillWindow.checkWindowState();
        }
        function onFocusedWorkspaceChanged() {
            pillWindow.refreshWorkspaces();
            pillWindow.checkWindowState();
            pillWindow.viewState = 2;
            workspaceTimer.restart();
        }
        function onActiveToplevelChanged() {
            pillWindow.checkWindowState();
        }
    }

    Component.onCompleted: {
        refreshWorkspaces();
        getBri.running = true; // Boots up the brightness tracker on launch
    }

    Timer {
        id: workspaceTimer
        interval: 2500
        onTriggered: if (pillWindow.viewState === 2)
            pillWindow.viewState = 0
    }

    SystemClock {
        id: time
        precision: SystemClock.Seconds
    }

    Timer {
        id: hideTimer
        interval: 3000
        onTriggered: pillWindow.isHoverTriggered = false
    }

    MouseArea {
        id: triggerZone
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: 400
        height: 10
        hoverEnabled: true
        onEntered: if (pillWindow.hasWindows) {
            pillWindow.isHoverTriggered = true;
            hideTimer.stop();
        }
        onExited: if (pillWindow.hasWindows)
            hideTimer.restart()
    }

    // ==========================================
    // OSD ENGINE (VOLUME & BRIGHTNESS)
    // ==========================================
    property real currentOsdValue: 0
    property string currentOsdIcon: "󰃠"
    property color currentOsdIconColor: Colors.orange
    property color currentOsdBarColor: Colors.green

    // --- 1. THE BOOT FIX ---
    // Prevents the OSD from annoying you and flashing on screen when you reload!
    property bool osdReady: false
    Timer {
        interval: 1500
        running: true
        onTriggered: pillWindow.osdReady = true
    }

    Timer {
        id: osdHideTimer
        interval: 2000
        onTriggered: {
            if (pillWindow.viewState === 6)
                pillWindow.viewState = 0;
        }
    }

    function triggerOsd(value, icon, iconColor, barColor) {
        if (!pillWindow.osdReady)
            return; // Block the trigger if the system is still booting

        pillWindow.currentOsdValue = value;
        pillWindow.currentOsdIcon = icon;
        pillWindow.currentOsdIconColor = iconColor;
        pillWindow.currentOsdBarColor = barColor;

        if (pillWindow.viewState === 0 || pillWindow.viewState === 2 || pillWindow.viewState === 6) {
            pillWindow.viewState = 6;
            osdHideTimer.restart();
        }
    }

    // --- 2. QUICKSHELL NATIVE VOLUME LISTENER ---
    // Pipewire requires a PwObjectTracker to actively listen to hardware audio nodes!
    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    // We must access the internal .audio property to get the live volume
    property var activeAudioNode: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
    property real trackedVolume: activeAudioNode ? activeAudioNode.volume : 0
    property bool trackedMute: activeAudioNode ? activeAudioNode.muted : false

    onTrackedVolumeChanged: {
        let icn = trackedMute ? "󰝟" : (trackedVolume > 0.5 ? "󰕾" : (trackedVolume > 0 ? "󰖀" : "󰕿"));
        let clr = trackedMute ? Colors.red : Colors.blue;
        triggerOsd(trackedVolume, icn, clr, Colors.blue);
    }

    onTrackedMuteChanged: {
        let icn = trackedMute ? "󰝟" : (trackedVolume > 0.5 ? "󰕾" : (trackedVolume > 0 ? "󰖀" : "󰕿"));
        let clr = trackedMute ? Colors.red : Colors.blue;
        triggerOsd(trackedVolume, icn, clr, Colors.blue);
    }

    // --- 3. HARDWARE-LEVEL BRIGHTNESS LISTENER ---
    property real currentBriValue: 0.5

    Process {
        // Uses inotifywait to instantly catch hardware backlight changes with 0% CPU!
        command: ["bash", "-c", "while true; do brightnessctl -m; inotifywait -qq -e modify /sys/class/backlight/*/brightness; done"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let parts = data.split(",");
                if (parts.length >= 4) {
                    let newBri = parseInt(parts[3].replace("%", "")) / 100.0;
                    if (pillWindow.currentBriValue !== newBri) {
                        pillWindow.currentBriValue = newBri;
                        triggerOsd(newBri, "󰃠", Colors.orange, Colors.green);
                    }
                }
            }
        }
    }

    // --- THE MORPHING PILL ---
    Rectangle {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        y: pillWindow.isVisible ? Config.topMargin : -(height + Config.topMargin)

        focus: true
        clip: true
        color: Colors.bg1
        border.color: Colors.bg2
        border.width: 2

        Keys.onEscapePressed: {
            if (pillWindow.viewState === 3)
                pillWindow.viewState = 1;
            else if (pillWindow.viewState === 1 || pillWindow.viewState === 4 || pillWindow.viewState === 5)
                pillWindow.viewState = 0;
        }
        Keys.onLeftPressed: {
            if (pillWindow.viewState === 4)
                powerMenu.moveLeft();
        }
        Keys.onRightPressed: {
            if (pillWindow.viewState === 4)
                powerMenu.moveRight();
        }
        Keys.onReturnPressed: {
            if (pillWindow.viewState === 4)
                powerMenu.executeSelected();
        }
        Keys.onEnterPressed: {
            if (pillWindow.viewState === 4)
                powerMenu.executeSelected();
        }

        width: {
            if (pillWindow.viewState === 0)
                return pillWindow.isMediaPlaying ? Config.timeWithEqWidth : Config.timeWidth;
            if (pillWindow.viewState === 1)
                return pillWindow.isMediaPlaying ? Config.expandedWidth : Config.timeWidth + sysPill.width + 48;
            if (pillWindow.viewState === 2) {
                let count = pillWindow.activeWorkspaces.length;
                if (count === 0)
                    return Config.timeWidth;
                return Math.max((count * 24) + ((count - 1) * 8) + 40, Config.timeWidth);
            }
            if (pillWindow.viewState === 3)
                return Config.mediaCtrlWidth;
            if (pillWindow.viewState === 4)
                return Config.powerMenuWidth;
            if (pillWindow.viewState === 5)
                return Config.launcherWidth;
            if (pillWindow.viewState === 6)
                return Config.osdWidth; // OSD Width Hook
            return Config.timeWidth;
        }

        height: {
            if (pillWindow.viewState === 1)
                return Config.expandedHeight;
            if (pillWindow.viewState === 3)
                return Config.mediaCtrlHeight;
            if (pillWindow.viewState === 4)
                return Config.powerMenuHeight;
            if (pillWindow.viewState === 5)
                return appLauncher.dynamicHeight;
            if (pillWindow.viewState === 6)
                return Config.osdHeight; // OSD Height Hook
            return Config.pillHeight;
        }

        radius: {
            if (pillWindow.viewState === 3)
                return Config.mediaCtrlRadius;
            if (pillWindow.viewState === 4)
                return Config.powerMenuHeight / 2;
            if (pillWindow.viewState === 5)
                return Config.launcherRadius;
            if (pillWindow.viewState === 6)
                return Config.osdRadius; // OSD Radius Hook
            return height / 2;
        }

        Behavior on width {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Config.animEasing
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Config.animEasing
            }
        }
        Behavior on y {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Config.animEasing
            }
        }
        Behavior on radius {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Config.animEasing
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: if (pillWindow.hasWindows)
                hideTimer.stop()
            onExited: if (pillWindow.hasWindows)
                hideTimer.restart()
            onClicked: {
                if (pillWindow.viewState === 3 || pillWindow.viewState === 4 || pillWindow.viewState === 5)
                    pillWindow.viewState = 1;
                else
                    viewState = (pillWindow.viewState === 2) ? 1 : ((pillWindow.viewState === 0) ? 1 : 0);
            }
        }

        // === CONTENT VIEWS ===
        Row {
            anchors.centerIn: parent
            spacing: 12
            opacity: pillWindow.viewState === 0 ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            Equalizer {
                anchors.verticalCenter: parent.verticalCenter
                isPlaying: pillWindow.isMediaPlaying
                visible: pillWindow.isMediaPlaying
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: Colors.fg0
                font.family: Config.fontName
                font.pixelSize: Config.fontSizeTime
                font.bold: true
                text: Qt.formatTime(time.date, "h:mm AP")
            }
        }

        Item {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 16
            opacity: pillWindow.viewState === 1 ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            Item {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: eqIcon.width + 10 + mediaTitleText.width
                height: 40
                visible: pillWindow.isMediaPlaying

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    Equalizer {
                        id: eqIcon
                        anchors.verticalCenter: parent.verticalCenter
                        isPlaying: pillWindow.isMediaPlaying
                    }

                    Text {
                        id: mediaTitleText
                        anchors.verticalCenter: parent.verticalCenter
                        color: Colors.fg2
                        font.family: Config.fontName
                        font.pixelSize: Config.fontSizeMediaTitle
                        text: (Mpris.players.values.length > 0 && Mpris.players.values[0].metadata) ? (Mpris.players.values[0].metadata["xesam:title"] || "") : ""
                        width: Math.min(implicitWidth, (pill.width / 2) - timeDateCol.width / 2 - eqIcon.width - 40)
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: pillWindow.viewState = 3
                }
            }

            Column {
                id: timeDateCol
                anchors.verticalCenter: parent.verticalCenter
                x: pillWindow.isMediaPlaying ? (parent.width / 2) - (width / 2) : 0
                spacing: 0

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Colors.fg0
                    font.family: Config.fontName
                    font.pixelSize: Config.fontSizeTime
                    font.bold: true
                    text: Qt.formatTime(time.date, "h:mm AP")
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Colors.aqua
                    font.family: Config.fontName
                    font.pixelSize: Config.fontSizeDate - 2
                    font.bold: true
                    text: Qt.formatDate(time.date, "dd/MM/yyyy")
                }
            }

            SystemPill {
                id: sysPill
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            id: workspaceRow
            anchors.centerIn: parent
            spacing: 8
            opacity: pillWindow.viewState === 2 ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            Repeater {
                model: pillWindow.activeWorkspaces
                Rectangle {
                    width: 24
                    height: 24
                    radius: 12
                    property bool isFocused: modelData.id === Hyprland.focusedWorkspace?.id
                    color: isFocused ? Colors.aqua : "transparent"
                    border.color: isFocused ? Colors.aqua : Colors.fg3
                    border.width: 2
                    Text {
                        anchors.centerIn: parent
                        text: modelData.id
                        color: isFocused ? Colors.bg0 : Colors.fg0
                        font.family: Config.fontName
                        font.pixelSize: Config.fontSizeWorkspace
                        font.bold: true
                    }
                }
            }
        }

        MediaController {
            id: mediaCtrl
            anchors.fill: parent
            opacity: pillWindow.viewState === 3 ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            onCloseRequested: pillWindow.viewState = 1
        }

        PowerMenu {
            id: powerMenu
            anchors.fill: parent
            opacity: pillWindow.viewState === 4 ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            onCloseRequested: pillWindow.viewState = 0
        }

        AppLauncher {
            id: appLauncher
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: Config.launcherWidth
            height: parent.height

            opacity: pillWindow.viewState === 5 ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            onCloseRequested: pillWindow.viewState = 0
        }

        Osd {
            id: osdView
            anchors.fill: parent
            opacity: pillWindow.viewState === 6 ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            percentage: pillWindow.currentOsdValue
            icon: pillWindow.currentOsdIcon
            iconColor: pillWindow.currentOsdIconColor
            barColor: pillWindow.currentOsdBarColor
        }
    }

    Keybinds {
        target: pillWindow
    }
}
