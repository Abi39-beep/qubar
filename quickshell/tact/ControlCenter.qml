import QtQuick

Item {
    id: ccRoot
    signal closeRequested
    property int currentView: 0

    // --- THE FOCUS FIX: Part 1 ---
    focus: true
    Keys.onEscapePressed: {
        if (currentView === 1) {
            currentView = 0; // If in Wi-Fi Menu, go back to Grid
        } else {
            closeRequested(); // If in Grid, close the Control Center
        }
    }

    MouseArea {
        anchors.fill: parent
        // THE FIX: Stop the keyboard from dropping into the void!
        onClicked: ccRoot.forceActiveFocus()
    }
    // -----------------------------

    // ... (The rest of your Column code remains exactly the same below here)

    // ==========================================
    // VIEW 0: MAIN CONTROL CENTER
    // ==========================================
    Column {
        anchors.fill: parent
        anchors.margins: Config.ccPadding
        spacing: Config.ccSpacing
        visible: ccRoot.currentView === 0

        // Explicit Header
        Row {
            width: parent.width
            spacing: 16

            MouseArea {
                width: 32
                height: 32
                cursorShape: Qt.PointingHandCursor
                onClicked: ccRoot.closeRequested() // Tells PillBar to close!

                Text {
                    anchors.centerIn: parent
                    text: "󰁍"
                    font.family: Config.fontName
                    font.pixelSize: 20
                    color: Colors.fg0
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Control Center"
                font.family: Config.fontName
                font.pixelSize: 16
                font.bold: true
                color: Colors.fg0
            }
        }

        Grid {
            width: parent.width
            columns: 2
            spacing: 12

            Wifi {
                width: (parent.width - 12) / 2
                onOpenMenuRequested: ccRoot.currentView = 1
            }
            Bluetooth {
                width: (parent.width - 12) / 2
            }
            Display {
                width: (parent.width - 12) / 2
            }
            Peace {
                width: (parent.width - 12) / 2
            }
        }

        Volume {
            width: parent.width
        }
    }

    // ==========================================
    // VIEW 1: WI-FI DETAILED MENU
    // ==========================================
    WifiMenu {
        anchors.fill: parent
        anchors.margins: Config.ccPadding
        visible: ccRoot.currentView === 1

        onBackRequested: ccRoot.currentView = 0
    }
}
