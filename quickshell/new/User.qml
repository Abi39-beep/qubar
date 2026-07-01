import QtQuick
import QtQuick.Layouts
import Quickshell

RowLayout {
    id: userRoot
    spacing: 16

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
        Layout.fillWidth: true
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
                precision: SystemClock.Minutes
            }
            text: Qt.formatDateTime(headerClock.date, "hh:mm A • dddd, MMM d")
        }
    }

    // 3. Icons (Settings & Power)
    RowLayout {
        spacing: 8

        // Settings Button
        Rectangle {
            implicitWidth: 36
            implicitHeight: 36
            radius: 18
            color: "transparent"
            border.color: Colors.bg2
            border.width: 2
            Text {
                anchors.centerIn: parent
                text: ""
                color: Colors.fg1
                font.pixelSize: 16
            }
        }

        // Power Button
        Rectangle {
            implicitWidth: 36
            implicitHeight: 36
            radius: 18
            color: Colors.red
            Text {
                anchors.centerIn: parent
                text: ""
                color: Colors.bg0
                font.pixelSize: 16
            }
        }
    }
}
