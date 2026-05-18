import QtQuick
import Quickshell
import "./widget/"

ShellRoot {
    PanelWindow {
        anchors.top: true
        anchors.left: true
        anchors.right: true
        height: 38
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Qt.alpha(Colors.bg0, 0)

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                Workspaces {}
            }

            // --- CENTER ROW ---
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

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
                        font.pixelSize: 15
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
            }

            // --- RIGHT ROW ---
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                WifiWidget {}
                BluetoothWidget {}
                Battery {}
                DashboardWidget {}
            }
        }

        OsdWindow {}
    }
}
