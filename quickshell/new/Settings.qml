import QtQuick
import Quickshell

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

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
    }
}
