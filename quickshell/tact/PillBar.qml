import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Io
import Quickshell.Services.Notifications

PanelWindow {
    id: pillWindow
    color: "transparent"

    anchors {
        top: true
        left: false
        right: false
    }

    WlrLayershell.exclusiveZone: Config.alwaysShowPill ? (Config.pillHeight + Config.topMargin) : 0

    property bool isBouncing: false
    WlrLayershell.layer: pillWindow.isBouncing ? WlrLayer.Bottom : WlrLayer.Top

    readonly property int viewTime: 0
    readonly property int viewExpanded: 1
    readonly property int viewWorkspaces: 2
    readonly property int viewMedia: 3
    readonly property int viewPowerMenu: 4
    readonly property int viewLauncher: 5
    readonly property int viewOsd: 6
    readonly property int viewControlCenter: 7

    property int viewState: pillWindow.viewTime
    property bool isNotifying: false
    property var currentNotification: null
    property alias cc: controlCenter

    // === THE NOTIFICATION SERVER ===
    NotificationServer {
        id: notificationServer
        onNotification: notification => {
            notification.tracked = true;
            pillWindow.currentNotification = notification;
            pillWindow.isNotifying = true;
        }
    }

    // === NOTIFICATION FOCUS ===
    property bool holdExclusiveFocus: false
    WlrLayershell.keyboardFocus: pillWindow.holdExclusiveFocus ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // --- THE WAYLAND MASK ---
    implicitWidth: Math.max(Config.expandedWidth, Config.launcherWidth, Config.powerMenuWidth, 600) + 50
    implicitHeight: Math.max(Config.expandedHeight, 600, Config.powerMenuHeight, Config.mediaCtrlHeight) + (Config.topMargin * 2) + 50

    mask: Region {
        item: pill
        Region {
            item: triggerZone
        }
    }

    // --- THE MASTER WAYLAND FOCUS STATE MACHINE ---
    Timer {
        id: focusDelayTimer
        interval: 50
        onTriggered: pill.forceActiveFocus()
    }

    Timer {
        id: dropFocusTimer
        interval: 350
        onTriggered: {
            pillWindow.holdExclusiveFocus = false;
            pillWindow.isBouncing = true;
            layerBounceTimer.restart();
        }
    }

    Timer {
        id: layerBounceTimer
        interval: 50
        onTriggered: pillWindow.isBouncing = false
    }

    function updateFocusState() {
        let isOpen = (pillWindow.viewState === pillWindow.viewExpanded || pillWindow.viewState === pillWindow.viewMedia || pillWindow.viewState === pillWindow.viewPowerMenu || pillWindow.viewState === pillWindow.viewLauncher || pillWindow.viewState === pillWindow.viewControlCenter || pillWindow.isNotifying);

        if (isOpen) {
            dropFocusTimer.stop();
            layerBounceTimer.stop();
            pillWindow.isBouncing = false;

            pillWindow.holdExclusiveFocus = true;
            focusDelayTimer.restart();
        } else {
            pill.focus = false;
            focusDelayTimer.stop();
            dropFocusTimer.restart();
        }
    }

    onViewStateChanged: pillWindow.updateFocusState()
    onIsNotifyingChanged: pillWindow.updateFocusState()

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

    // ==========================================
    // MEDIA TRACKING ARCHITECTURE
    // ==========================================
    property var activePlayer: null
    readonly property bool isMediaPlaying: pillWindow.activePlayer !== null && pillWindow.activePlayer.playbackState === MprisPlaybackState.Playing

    Timer {
        interval: 500
        running: Mpris.players.values.length > 0
        repeat: true
        onTriggered: {
            let players = Mpris.players.values;
            let best = null;
            for (let i = 0; i < players.length; i++) {
                if (players[i] && players[i].playbackState === MprisPlaybackState.Playing) {
                    best = players[i];
                    break;
                }
                if (players[i] && !best)
                    best = players[i];
            }
            pillWindow.activePlayer = best;
        }
    }

    property bool isHoverTriggered: false
    property bool isVisible: Config.alwaysShowPill || !pillWindow.hasWindows || pillWindow.isHoverTriggered || pillWindow.viewState !== pillWindow.viewTime || pillWindow.isNotifying

    function refreshWorkspaces() {
        var rawWorkspaces = Hyprland.workspaces.values;
        var safeWbs = [];
        var currentFocusedId = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1;

        for (var i = 0; i < rawWorkspaces.length; i++) {
            var ws = rawWorkspaces[i];
            if (ws) {
                var hasToplevels = (ws.toplevels && ws.toplevels.values.length > 0);
                if (ws.id === currentFocusedId || hasToplevels) {
                    safeWbs.push({
                        id: ws.id
                    });
                }
            }
        }
        safeWbs.sort(function (a, b) {
            return a.id - b.id;
        });
        pillWindow.activeWorkspaces = safeWbs;
    }

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            pillWindow.refreshWorkspaces();
            pillWindow.checkWindowState();
            pillWindow.viewState = pillWindow.viewWorkspaces;
            workspaceTimer.restart();
        }
        function onActiveToplevelChanged() {
            pillWindow.checkWindowState();
        }
    }

    Component.onCompleted: {
        pillWindow.refreshWorkspaces();
        pillWindow.checkWindowState();
        getBri.running = true;
    }

    Timer {
        id: workspaceTimer
        interval: 2500
        onTriggered: if (pillWindow.viewState === pillWindow.viewWorkspaces)
            pillWindow.viewState = pillWindow.viewTime
    }

    SystemClock {
        id: time
        precision: SystemClock.Minutes
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
            if (pillWindow.viewState === pillWindow.viewOsd)
                pillWindow.viewState = pillWindow.viewTime;
        }
    }

    function triggerOsd(value, icon, iconColor, barColor) {
        if (!pillWindow.osdReady)
            return;

        pillWindow.currentOsdValue = value;
        pillWindow.currentOsdIcon = icon;
        pillWindow.currentOsdIconColor = iconColor;
        pillWindow.currentOsdBarColor = barColor;

        if (pillWindow.viewState === pillWindow.viewTime || pillWindow.viewState === pillWindow.viewWorkspaces || pillWindow.viewState === pillWindow.viewOsd) {
            pillWindow.viewState = pillWindow.viewOsd;
            osdHideTimer.restart();
        }
    }

    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    property var activeAudioNode: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
    property real trackedVolume: pillWindow.activeAudioNode ? pillWindow.activeAudioNode.volume : 0
    property bool trackedMute: pillWindow.activeAudioNode ? pillWindow.activeAudioNode.muted : false

    onTrackedVolumeChanged: {
        let icn = pillWindow.trackedMute ? "󰝟" : (pillWindow.trackedVolume > 0.5 ? "󰕾" : (pillWindow.trackedVolume > 0 ? "󰖀" : "󰕿"));
        let clr = pillWindow.trackedMute ? Colors.red : Colors.blue;
        pillWindow.triggerOsd(pillWindow.trackedVolume, icn, clr, Colors.blue);
    }

    onTrackedMuteChanged: {
        let icn = pillWindow.trackedMute ? "󰝟" : (pillWindow.trackedVolume > 0.5 ? "󰕾" : (pillWindow.trackedVolume > 0 ? "󰖀" : "󰕿"));
        let clr = pillWindow.trackedMute ? Colors.red : Colors.blue;
        pillWindow.triggerOsd(pillWindow.trackedVolume, icn, clr, Colors.blue);
    }

    property real currentBriValue: 0.5

    Process {
        id: getBri
        command: ["brightnessctl", "-m"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                let parts = data.split(",");
                if (parts.length >= 4) {
                    let newBri = parseInt(parts[3].replace("%", "")) / 100.0;
                    if (pillWindow.currentBriValue !== newBri) {
                        pillWindow.currentBriValue = newBri;
                        pillWindow.triggerOsd(newBri, "󰃠", Colors.orange, Colors.green);
                    }
                }
            }
        }

        // qmllint disable signal-handler-parameters
        onExited: getBri.running = false
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            if (!getBri.running) {
                getBri.running = true;
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

        // --- MASTER KEYBOARD CONTROLLER ---
        Keys.onEscapePressed: {
            if (pillWindow.isNotifying) {
                if (pillWindow.currentNotification)
                    pillWindow.currentNotification.dismiss();
                pillWindow.isNotifying = false;
            } else if (pillWindow.viewState === pillWindow.viewControlCenter) {
                if (pillWindow.cc.currentView === 4 || pillWindow.cc.currentView === 5) {
                    pillWindow.cc.currentView = 3;
                } else if (pillWindow.cc.currentView !== 0) {
                    pillWindow.cc.currentView = 0;
                } else {
                    pillWindow.viewState = pillWindow.viewExpanded;
                }
            } else if (pillWindow.viewState === pillWindow.viewMedia) {
                pillWindow.viewState = pillWindow.viewExpanded;
            } else if (pillWindow.viewState === pillWindow.viewExpanded || pillWindow.viewState === pillWindow.viewPowerMenu || pillWindow.viewState === pillWindow.viewLauncher) {
                pillWindow.viewState = pillWindow.viewTime;
            }
        }

        Keys.onLeftPressed: {
            if (pillWindow.viewState === pillWindow.viewPowerMenu)
                powerMenu.moveLeft();
        }
        Keys.onRightPressed: {
            if (pillWindow.viewState === pillWindow.viewPowerMenu)
                powerMenu.moveRight();
        }
        Keys.onReturnPressed: {
            if (pillWindow.viewState === pillWindow.viewPowerMenu)
                powerMenu.executeSelected();
        }
        Keys.onEnterPressed: {
            if (pillWindow.viewState === pillWindow.viewPowerMenu)
                powerMenu.executeSelected();
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: if (pillWindow.hasWindows)
                hideTimer.stop()
            onExited: if (pillWindow.hasWindows)
                hideTimer.restart()
            onClicked: {
                pill.forceActiveFocus();
                if (pillWindow.viewState === pillWindow.viewMedia || pillWindow.viewState === pillWindow.viewPowerMenu || pillWindow.viewState === pillWindow.viewLauncher || pillWindow.viewState === pillWindow.viewControlCenter)
                    pillWindow.viewState = pillWindow.viewExpanded;
                else
                    pillWindow.viewState = (pillWindow.viewState === pillWindow.viewTime || pillWindow.viewState === pillWindow.viewWorkspaces) ? pillWindow.viewExpanded : pillWindow.viewTime;
            }
        }

        width: {
            if (pillWindow.isNotifying)
                return Config.notifWidth;
            if (pillWindow.viewState === pillWindow.viewTime)
                return pillWindow.isMediaPlaying ? Config.timeWithEqWidth : Config.timeWidth;
            if (pillWindow.viewState === pillWindow.viewExpanded)
                return pillWindow.isMediaPlaying ? Config.expandedWidth : Config.timeWidth + sysPill.width + 48;
            if (pillWindow.viewState === pillWindow.viewWorkspaces) {
                let count = pillWindow.activeWorkspaces.length;
                if (count === 0)
                    return Config.timeWidth;
                return Math.max((count * 24) + ((count - 1) * 8) + 40, Config.timeWidth);
            }
            if (pillWindow.viewState === pillWindow.viewMedia)
                return Config.mediaCtrlWidth;
            if (pillWindow.viewState === pillWindow.viewPowerMenu)
                return Config.powerMenuWidth;
            if (pillWindow.viewState === pillWindow.viewLauncher)
                return Config.launcherWidth;
            if (pillWindow.viewState === pillWindow.viewOsd)
                return Config.osdWidth;
            if (pillWindow.viewState === pillWindow.viewControlCenter)
                return Config.ccWidth;
            return Config.timeWidth;
        }

        height: {
            if (pillWindow.isNotifying)
                return notifView.dynamicHeight;
            if (pillWindow.viewState === pillWindow.viewExpanded)
                return Config.expandedHeight;
            if (pillWindow.viewState === pillWindow.viewMedia)
                return Config.mediaCtrlHeight;
            if (pillWindow.viewState === pillWindow.viewPowerMenu)
                return Config.powerMenuHeight;
            if (pillWindow.viewState === pillWindow.viewLauncher)
                return appLauncher.dynamicHeight;
            if (pillWindow.viewState === pillWindow.viewOsd)
                return Config.osdHeight;
            if (pillWindow.viewState === pillWindow.viewControlCenter)
                return Config.ccHeight;
            return Config.pillHeight;
        }

        radius: {
            if (pillWindow.isNotifying)
                return Config.notifRadius;
            if (pillWindow.viewState === pillWindow.viewMedia)
                return Config.mediaCtrlRadius;
            if (pillWindow.viewState === pillWindow.viewPowerMenu)
                return Config.powerMenuHeight / 2;
            if (pillWindow.viewState === pillWindow.viewLauncher)
                return Config.launcherRadius;
            if (pillWindow.viewState === pillWindow.viewOsd)
                return Config.osdRadius;
            if (pillWindow.viewState === pillWindow.viewControlCenter)
                return Config.ccRadius;
            return pill.height / 2;
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

        // === CONTENT VIEWS ===

        Row {
            anchors.centerIn: parent
            spacing: 12
            opacity: (pillWindow.viewState === pillWindow.viewTime && !pillWindow.isNotifying) ? 1 : 0
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
            opacity: (pillWindow.viewState === pillWindow.viewExpanded && !pillWindow.isNotifying) ? 1 : 0
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
                        text: (pillWindow.activePlayer && pillWindow.activePlayer.metadata) ? (pillWindow.activePlayer.metadata["xesam:title"] || "") : ""
                        width: Math.min(implicitWidth, (pill.width / 2) - timeDateCol.width / 2 - eqIcon.width - 40)
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: pillWindow.viewState = pillWindow.viewMedia
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

            MouseArea {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: sysPill.width
                height: sysPill.height
                cursorShape: Qt.PointingHandCursor

                onClicked: pillWindow.viewState = pillWindow.viewControlCenter

                SystemPill {
                    id: sysPill
                    anchors.centerIn: parent
                }
            }
        }

        Row {
            id: workspaceRow
            anchors.centerIn: parent
            spacing: 8
            opacity: (pillWindow.viewState === pillWindow.viewWorkspaces && !pillWindow.isNotifying) ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            Repeater {
                model: pillWindow.activeWorkspaces

                Rectangle {
                    id: workspaceRect
                    required property var modelData
                    width: 24
                    height: 24
                    radius: 12
                    property bool isFocused: workspaceRect.modelData.id === (Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1)
                    color: workspaceRect.isFocused ? Colors.aqua : "transparent"
                    border.color: workspaceRect.isFocused ? Colors.aqua : Colors.fg3
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: workspaceRect.modelData.id
                        color: workspaceRect.isFocused ? Colors.bg0 : Colors.fg0
                        font.family: Config.fontName
                        font.pixelSize: Config.fontSizeWorkspace
                        font.bold: true
                    }
                }
            }
        }

        // --- RESTORED PERSISTENT VIEWS ---
        MediaController {
            id: mediaCtrl
            anchors.fill: parent
            opacity: (pillWindow.viewState === pillWindow.viewMedia && !pillWindow.isNotifying) ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }
            onCloseRequested: pillWindow.viewState = pillWindow.viewExpanded
        }

        PowerMenu {
            id: powerMenu
            anchors.fill: parent
            opacity: (pillWindow.viewState === pillWindow.viewPowerMenu && !pillWindow.isNotifying) ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }
            onCloseRequested: pillWindow.viewState = pillWindow.viewTime
        }

        AppLauncher {
            id: appLauncher
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: Config.launcherWidth
            height: parent.height
            opacity: (pillWindow.viewState === pillWindow.viewLauncher && !pillWindow.isNotifying) ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }
            onCloseRequested: pillWindow.viewState = pillWindow.viewTime
        }

        Osd {
            id: osdView
            anchors.fill: parent
            opacity: (pillWindow.viewState === pillWindow.viewOsd && !pillWindow.isNotifying) ? 1 : 0
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

        NotificationView {
            id: notifView
            anchors.fill: parent
            activeNotif: pillWindow.currentNotification

            opacity: pillWindow.isNotifying ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            onDismissed: pillWindow.isNotifying = false
        }

        ControlCenter {
            id: controlCenter
            anchors.fill: parent
            opacity: (pillWindow.viewState === pillWindow.viewControlCenter && !pillWindow.isNotifying) ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            onCloseRequested: pillWindow.viewState = pillWindow.viewExpanded
        }
    }

    Keybinds {
        target: pillWindow
    }
}
