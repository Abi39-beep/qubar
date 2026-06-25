import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

PanelWindow {
    id: clook
    color: "transparent"

    anchors {
        top: true
        left: false
        right: false
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top

    implicitWidth: 180
    implicitHeight: 60

    // 2. THE ULTIMATE LOGIC FIX
    // We stop trusting activeToplevel because wallpapers trick it.
    // Instead, we explicitly count the number of windows on your workspace.
    property bool hasWindows: {
        // By referencing activeToplevel here, we force QML to re-run this exact
        // check every single time you open, close, or focus a window.
        var _ = Hyprland.activeToplevel;

        // If your workspace exists, we check the length of the toplevels array.
        // If the length is 0, the desktop is truly empty and hasWindows becomes false!
        if (Hyprland.focusedWorkspace !== null) {
            return Hyprland.focusedWorkspace.toplevels.values.length > 0;
        }
        return false;
    }

    property bool isHoverTriggered: false
    property bool isVisible: !hasWindows || isHoverTriggered

    SystemClock {
        id: time
        precision: SystemClock.Seconds
    }

    Timer {
        id: hideTimer
        interval: 3000
        onTriggered: clook.isHoverTriggered = false
    }

    MouseArea {
        id: triggerZone
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: 350
        height: 20
        hoverEnabled: true

        onEntered: {
            if (clook.hasWindows) {
                clook.isHoverTriggered = true;
                hideTimer.restart();
            }
        }
        onExited: {
            if (clook.hasWindows) {
                hideTimer.restart();
            }
        }
    }

    Rectangle {
        id: notchBase
        width: parent.width

        property int cornerRadius: 11

        height: 60 + cornerRadius
        y: clook.isVisible ? -cornerRadius : -height

        Behavior on y {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutExpo
            }
        }

        color: Colors.bg1
        radius: cornerRadius

        border.color: Colors.bg1
        border.width: 2

        Column {
            anchors.top: parent.top
            anchors.topMargin: notchBase.cornerRadius + 5
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 1

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Colors.fg
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 20
                font.bold: true
                text: Qt.formatTime(time.date, "h:mm AP")
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Colors.aqua
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                font.bold: true
                text: Qt.formatDate(time.date, "dd/MM/yyyy")
            }
        }
    }
}
