import QtQuick
import Quickshell
import ".."

PopupWindow {
    id: calendarRoot
    visible: false

    width: 250
    height: 250 // Increased by 10 to make room for the gap

    color: "transparent"
    grabFocus: true

    // FIX: Force it to grab the keyboard when it opens
    onVisibleChanged: {
        if (visible) {
            bgRect.forceActiveFocus();
        }
    }

    Rectangle {
        id: bgRect
        anchors.fill: parent

        // FIX: This pushes the rectangle down, creating a 10px gap!
        anchors.topMargin: 10

        // FIX: Listen for the Escape key and focus loss (clicking outside)
        focus: true
        Keys.onEscapePressed: calendarRoot.visible = false
        onActiveFocusChanged: {
            // If it loses focus (you clicked another window), close it
            if (!activeFocus) {
                calendarRoot.visible = false;
            }
        }

        color: Qt.alpha(Colors.bg0, 0.95)
        border.color: Colors.bg2
        border.width: 1
        radius: 12

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            Text {
                text: Qt.formatDateTime(new Date(), "MMMM yyyy")
                color: Colors.green
                font.pixelSize: 18
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Grid {
                columns: 7
                spacing: 8
                anchors.horizontalCenter: parent.horizontalCenter
                Repeater {
                    model: 31
                    Rectangle {
                        width: 25
                        height: 25
                        radius: 4
                        color: (index + 1 === new Date().getDate()) ? Colors.green : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: index + 1
                            color: (index + 1 === new Date().getDate()) ? Colors.bg0 : Colors.fg
                        }
                    }
                }
            }
        }
    }
}
