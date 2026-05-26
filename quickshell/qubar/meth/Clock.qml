import QtQuick
import Quickshell
import ".."

Item {
    id: clockWidget
    width: 70
    height: 30
    anchors.verticalCenter: parent.verticalCenter

    Text {
        id: timeDisplay
        anchors.centerIn: parent
        text: Qt.formatDateTime(new Date(), "hh:mm AP")
        color: Colors.fg
        font.pixelSize: 14
        font.family: "JetBrainsMono Nerd Font"
        font.bold: true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date();
            timeDisplay.text = Qt.formatDateTime(now, "hh:mm AP");
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: calendarPopup.visible = !calendarPopup.visible
    }

    CalendarWindow {
        id: calendarPopup
        anchor.item: clockWidget
        anchor.edges: Edges.Bottom | Edges.Left
    }
}
