import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
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

    implicitWidth: 600
    implicitHeight: Config.expandedHeight + (Config.topMargin * 2)

    property int viewState: 0
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
    property bool isVisible: !hasWindows || isHoverTriggered || viewState === 2 || viewState === 1

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

    // --- THE MORPHING PILL ---
    Rectangle {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        y: pillWindow.isVisible ? Config.topMargin : -(height + Config.topMargin)
        height: pillWindow.viewState === 1 ? Config.expandedHeight : Config.pillHeight
        radius: height / 2

        color: Colors.bg1
        border.color: Colors.bg2
        border.width: 2
        clip: true

        width: {
            if (pillWindow.viewState === 0)
                return pillWindow.isMediaPlaying ? Config.timeWithEqWidth : Config.timeWidth;
            if (pillWindow.viewState === 1)
                return pillWindow.isMediaPlaying ? Config.expandedWidth : Config.timeWidth + sysPill.width + Config.dashboardSpacing;
            if (pillWindow.viewState === 2) {
                let count = pillWindow.activeWorkspaces.length;
                if (count === 0)
                    return Config.timeWidth;
                return Math.max((count * 24) + ((count - 1) * 8) + 40, Config.timeWidth);
            }
            return Config.timeWidth;
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

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: if (pillWindow.hasWindows)
                hideTimer.stop()
            onExited: if (pillWindow.hasWindows)
                hideTimer.restart()
            onClicked: viewState = (pillWindow.viewState === 2) ? 1 : ((pillWindow.viewState === 0) ? 1 : 0)
        }

        // === CONTENT VIEWS ===

        // State 0: Time Only
        Row {
            anchors.centerIn: parent
            spacing: 12
            opacity: pillWindow.viewState === 0 ? 1 : 0
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

        // State 1: Expanded Dashboard
        Row {
            anchors.centerIn: parent
            spacing: Config.dashboardSpacing
            opacity: pillWindow.viewState === 1 ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            // Left Side: Equalizer and Title
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                visible: pillWindow.isMediaPlaying

                // FIXED: Removed the ID to stop breaking your Equalizer's internal bindings!
                Equalizer {
                    anchors.verticalCenter: parent.verticalCenter
                    isPlaying: pillWindow.isMediaPlaying
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: Colors.fg2
                    font.family: Config.fontName
                    font.pixelSize: Config.fontSizeMediaTitle
                    text: (Mpris.players.values.length > 0 && Mpris.players.values[0].metadata) ? (Mpris.players.values[0].metadata["xesam:title"] || "") : ""

                    // THE FIX: Added an outer padding reserve to the math!
                    width: {
                        let outerPadding = 56; // Reserves 28px of empty space on both the left and right sides
                        let internalSpacing = 10; // Space between EQ and Title
                        let availableSpace = Config.expandedWidth - 24 - timeDateCol.width - sysPill.width - (Config.dashboardSpacing * 2) - internalSpacing - outerPadding;
                        return Math.max(50, availableSpace);
                    }
                    elide: Text.ElideRight
                }
            }

            // Center Side: Time Stacked Over Date
            Column {
                id: timeDateCol
                anchors.verticalCenter: parent.verticalCenter
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

            // Right Side: Imported System Pill Component
            SystemPill {
                id: sysPill
            }
        }

        // State 2: Workspaces
        Row {
            id: workspaceRow
            anchors.centerIn: parent
            spacing: 8
            opacity: pillWindow.viewState === 2 ? 1 : 0
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
    }
}
