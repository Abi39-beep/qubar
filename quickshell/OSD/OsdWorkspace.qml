import QtQuick
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    id: osdRoot

    // Anchor to top edge and allow width to be determined by anchors
    anchors.top: true
    anchors.left: true
    anchors.right: true

    // Make the PanelWindow minimal height; the visible OSD will be centered inside.
    implicitHeight: 60

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    visible: osdOpacity > 0
    aboveWindows: true

    // Fade in/out control
    property real osdOpacity: 0
    Behavior on osdOpacity { NumberAnimation { duration: 150 } }

    // Startup readiness
    property bool isReady: false
    Timer { interval: 800; running: true; repeat: false; onTriggered: isReady = true }

    // Auto-hide timer
    Timer { id: hideTimer; interval: 1500; repeat: false; onTriggered: osdRoot.osdOpacity = 0 }

    // Workspace state
    property var ws: Hyprland.focusedWorkspace
    property string wsLabel: ws ? (ws.name !== "" ? ws.name : ws.id.toString()) : "?"

    onWsLabelChanged: {
        if (!isReady) return
        osdRoot.osdOpacity = 1
        hideTimer.restart()
    }

    // The PanelWindow spans the top edge; place a centered container inside.
    Item {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: parent.implicitHeight

        // The visible OSD box is centered by using an implicitWidth and anchoring it horizontally to parent center.
        Rectangle {
            id: box
            width: 120         // change this to your preferred OSD width
            height: 46
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 6

            opacity: osdRoot.osdOpacity

            radius: 28
            color: (typeof Colors !== "undefined") ? Colors.bg0 : "#222222"
            border.color: (typeof Colors !== "undefined") ? Colors.bg2 : "#3a3a3a"
            border.width: 1

            Row {
                anchors.centerIn: parent
                spacing: 12

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰕰"
                    color: (typeof Colors !== "undefined") ? Colors.blue : "#6ea8fe"
                    font.pixelSize: 22
                    font.family: "JetBrainsMono Nerd Font"
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: wsLabel
                    color: (typeof Colors !== "undefined") ? Colors.fg : "#e6e6e6"
                    font.pixelSize: 16
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }
            }
        }
    }
}
