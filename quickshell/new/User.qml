import QtQuick
import QtQuick.Layouts
import Quickshell

RowLayout {
    id: userRoot
    spacing: 12

    // 1. User Avatar (Circle)
    Rectangle {
        implicitWidth: 52
        implicitHeight: 52
        radius: 26
        color: Colors.bg2
        border.color: Colors.bg3
        border.width: 2

        Text {
            anchors.centerIn: parent
            text: ""
            color: Colors.fg2
            font.pixelSize: 20
        }
    }

    // 2. Text Details
    ColumnLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: 4

        Text {
            text: "abimanyu"
            color: Colors.fg0
            font.pixelSize: 18
            font.bold: true
            font.family: "SF Pro Display"
        }

        Text {
            color: Colors.fg2
            font.pixelSize: 13
            font.family: "SF Mono Light"

            SystemClock {
                id: headerClock
                precision: SystemClock.Days
            }
            text: Qt.formatDateTime(headerClock.date, "dddd, MMM d")
        }
    }
}
