import QtQuick
import QtQuick.Layouts
import Quickshell
import Qt5Compat.GraphicalEffects

RowLayout {
    id: userRoot
    spacing: 12

    signal openCalendar

    // 1. User Avatar (Circle)
    Rectangle {
        id: avatarBox
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
            font.family: "JetBrainsMono Nerd Font"
        }

        Image {
            id: avatarImage
            source: "file://" + Quickshell.env("HOME") + "/.config/quickshell/scripts/avatar.jpg"
            anchors.fill: parent
            anchors.margins: 2
            fillMode: Image.PreserveAspectCrop
            visible: false
        }

        Rectangle {
            id: maskShape
            anchors.fill: parent
            anchors.margins: 2
            radius: 24
            visible: false
        }

        OpacityMask {
            anchors.fill: parent
            anchors.margins: 2
            source: avatarImage
            maskSource: maskShape
            visible: avatarImage.status === Image.Ready
        }
    }

    // 2. Text Details
    ColumnLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: 4

        Text {
            text: {
                let u = Quickshell.env("USER") || "User";
                return u.charAt(0).toUpperCase() + u.slice(1);
            }
            color: Colors.fg0
            font.pixelSize: 18
            font.bold: true
            font.family: "SF Pro Display"
        }

        Text {
            color: dateArea.containsMouse ? Colors.aqua : Colors.fg2
            font.pixelSize: 13
            font.family: "SF Mono Light"

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            SystemClock {
                id: headerClock
                precision: SystemClock.Days
            }
            text: Qt.formatDateTime(headerClock.date, "dddd, MMM d")

            MouseArea {
                id: dateArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: userRoot.openCalendar()
            }
        }
    }
}
