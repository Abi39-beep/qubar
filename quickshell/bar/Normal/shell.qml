import QtQuick
import Quickshell
import Quickshell.Hyprland
import "./widget/"

ShellRoot {
    PanelWindow {
        anchors.top: true
        anchors.right: true
        anchors.left: true
        height: 38
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Qt.alpha(Colors.bg0, 1.00)

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                Row {
                    spacing: 5

                    Repeater {
                        model: [1, 2, 3, 4, 5] // Your 5 persistent workspaces

                        Rectangle {
                            required property int modelData
                            width: 30
                            height: 30
                            radius: 15

                            // Get the live workspace object
                            property var ws: Hyprland.workspaces.values.find(w => w.id === modelData)

                            // 1. Is this the one I'm currently on?
                            readonly property bool isFocused: Hyprland.focusedWorkspace?.id === modelData

                            // 2. Does it have windows?
                            // "toplevels" actively tracks the windows (toplevels). We check if the array length > 0.
                            readonly property bool isOccupied: ws ? ws.toplevels.values.length > 0 : false

                            // Dynamic Styling
                            color: isFocused ? Colors.green : (isOccupied ? Colors.bg3 : Colors.bg1)
                            border.width: isFocused ? 0 : 1
                            border.color: isOccupied ? Colors.grey0 : Colors.bg2

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 13
                                font.family: "JetBrainsMono Nerd Font"
                                font.bold: parent.isFocused
                                color: parent.isFocused ? Colors.bg0 : (parent.isOccupied ? Colors.fg : Colors.grey1)
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Hyprland.dispatch(`hl.dsp.focus({workspace = "${modelData}"})`)
                            }
                        }
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                ActiveWindowWidget {}
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

                WifiWidget {}
                BluetoothWidget {}
                Battery {}
                Rectangle {
                    id: clockPill
                    width: timeDisplay.implicitWidth + 24 // Automatically perfectly sized
                    height: 30
                    radius: 15
                    color: Colors.bg1
                    border.color: Colors.bg2
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: timeDisplay
                        anchors.centerIn: parent
                        text: Qt.formatDateTime(new Date(), "hh:mm AP")
                        color: Colors.fg
                        font.pixelSize: 13
                        font.family: "JetBrainsMono Nerd Font"
                        font.bold: true
                    }

                    // Updates the time every second
                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: {
                            timeDisplay.text = Qt.formatDateTime(new Date(), "hh:mm AP");
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: calendarPopup.visible = !calendarPopup.visible
                    }

                    CalendarWindow {
                        id: calendarPopup
                        anchor.item: clockPill
                        anchor.edges: Edges.Bottom | Edges.Left
                    }
                }
                DashboardWidget {}
            }
        }
        OsdWindow {}
    }
}
