import QtQuick
import Quickshell
import ".."

Rectangle {
    id: clockPill
    // Automatically adjust width based on the content
    width: clockRow.width + 15
    height: 30
    radius: 15
    color: Colors.bg1
    border.color: Colors.bg2
    anchors.verticalCenter: parent.verticalCenter

    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 5

        // Time Section
        Text {
            id: timeDisplay
            text: Qt.formatDateTime(new Date(), "hh:mm AP")
            color: Colors.fg
            font.pixelSize: 15
            font.family: "JetBrainsMono Nerd Font"
            font.bold: true
        }

        // Separator Line
        Rectangle {
            width: 1; height: 14
            color: Colors.bg4
            anchors.verticalCenter: parent.verticalCenter
        }

        // Date Section
        Text {
            id: dateDisplay
            text: Qt.formatDateTime(new Date(), "ddd, MMM d")
            color: Colors.blue
            font.pixelSize: 13
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    // This updates both the time and the date every second
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            var now = new Date();
            timeDisplay.text = Qt.formatDateTime(now, "hh:mm AP");
            dateDisplay.text = Qt.formatDateTime(now, "ddd, MMM d");
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        // Open the popup we defined below
        onClicked: calendarPopup.visible = !calendarPopup.visible
    }

    // --- POPUP MOVED HERE ---
    // Because it is instantiated here, we can anchor it directly to the clock!
    CalendarWindow {
        id: calendarPopup
        anchor.item: clockPill
        anchor.edges: Edges.Bottom | Edges.Left
    }
}
