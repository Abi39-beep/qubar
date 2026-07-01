import Quickshell
import QtQuick

Text {
    id: clockText

    text: Qt.formatDateTime(clock.date, "hh:mmA")
    color: clockArea.containsMouse ? Colors.green : Colors.aqua

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    font {
        family: "SF Mono Light"
        letterSpacing: -0.5
        pixelSize: 15
        weight: 700
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    MouseArea {
        id: clockArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        // qmllint disable unqualified
        onClicked: controlCenterWindow.visible = !controlCenterWindow.visible
    }
}
