import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: osdRoot

    anchors.top: true
    anchors.left: true
    anchors.right: true

    implicitHeight: 60

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "workspaceosd"
    WlrLayershell.layer: WlrLayer.Overlay
    aboveWindows: true
    visible: osdOpacity > 0

    // Fade
    property real osdOpacity: 0
    Behavior on osdOpacity { NumberAnimation { duration: 150 } }

    // Startup delay
    property bool isReady: false
    Timer {
        interval: 800
        running: true
        repeat: false
        onTriggered: isReady = true
    }

    // Auto-hide
    Timer {
        id: hideTimer
        interval: 1500
        repeat: false
        onTriggered: osdRoot.osdOpacity = 0
    }

    // Focused workspace (current)
    property var ws: Hyprland.focusedWorkspace
    property string wsLabel: ws ? (ws.name !== "" ? ws.name : ws.id.toString()) : "?"

    // Show OSD whenever focused workspace changes (this must stay)
    onWsLabelChanged: {
        if (!isReady) return
        osdRoot.osdOpacity = 1
        hideTimer.restart()
    }

    // ---- USER CONTROLS ----
    property int boxHeight: 38    // change this to control OSD height
    property int pillSpacing: 8
    property int pillSidePadding: 2
    property int minPillWidth: 26
    property int sidePadding: 24
    property int maxBoxWidth: 720

    Item {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: parent.implicitHeight

        Rectangle {
            id: box
            // compute width from repeater.count and approximated pill widths
            // use wsRepeater.count (number of created delegates) which is reliable
            width: Math.min(parent.width - 38,
                            Math.max(120,
                                     (wsRepeater.count * (minPillWidth + pillSidePadding)) +
                                     Math.max(0, (wsRepeater.count - 1)) * pillSpacing +
                                     sidePadding
                                    )
                           )
            Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutQuad } }

            height: boxHeight
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 15

            opacity: osdRoot.osdOpacity

            radius: boxHeight / 2
            color: (typeof Colors !== "undefined") ? Qt.alpha(Colors.bg0, 0.50) : Qt.alpha("#222222", 0.50)
            border.color: (typeof Colors !== "undefined") ? Colors.bg2 : "#3a3a3a"
            border.width: 1

            Row {
                anchors.centerIn: parent
                spacing: pillSpacing

                Repeater {
                    id: wsRepeater
                    model: Hyprland.workspaces
                    delegate: Rectangle {
                        readonly property bool isCurrent: modelData.focused || modelData.active
                        readonly property string label: modelData.name !== "" ? modelData.name : modelData.id.toString()

                        radius: 999
                        height: boxHeight * 0.46 + 10
                        implicitWidth: Math.max(minPillWidth, labelText.implicitWidth + pillSidePadding)

                        color: isCurrent
                               ? ((typeof Colors !== "undefined") ? Colors.blue : "#5c7cff")
                               : ((typeof Colors !== "undefined") ? Colors.bg2 : "#3a3a3a")

                        border.width: isCurrent ? 0 : 1
                        border.color: (typeof Colors !== "undefined") ? Colors.bg3 : "#555555"

                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on opacity { NumberAnimation { duration: 120 } }

                        Row {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                id: labelText
                                text: label
                                color: (typeof Colors !== "undefined")
                                       ? (isCurrent ? Colors.bg0 : Colors.fg)
                                       : (isCurrent ? "#121212" : "#e6e6e6")
                                font.pixelSize: Math.max(12, boxHeight * 0.22)
                                font.bold: isCurrent
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                    }
                }
            }
        }
    }
}
