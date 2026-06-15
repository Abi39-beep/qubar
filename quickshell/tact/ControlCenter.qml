import QtQuick

Item {
    id: ccRoot
    signal closeRequested

    property int currentView: 0

    onVisibleChanged: {
        if (!visible) {
            currentView = 0; // Wipes memory to show Grid when reopened!
        }
    }

    focus: true
    Keys.onEscapePressed: {
        // If deep inside a menu (Wifi or Bluetooth), go back to main grid
        if (currentView === 1 || currentView === 2) {
            currentView = 0;
        } else
        // If already on the main grid, close the control center
        {
            closeRequested();
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: ccRoot.forceActiveFocus()
    }

    // ==========================================
    // VIEW 0: MAIN CONTROL CENTER GRID
    // ==========================================
    Column {
        anchors.fill: parent
        anchors.margins: Config.ccPadding
        spacing: Config.ccSpacing
        visible: ccRoot.currentView === 0

        // --- HEADER ---
        Row {
            width: parent.width
            spacing: 12

            // THE FIX: Always visible circle with hover highlight!
            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: ccBackArea.containsMouse ? Colors.bg2 : Colors.bg1
                border.color: Colors.bg2
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "󰁍"
                    font.family: Config.fontName
                    font.pixelSize: 18 // Matched exactly to the submenus
                    color: Colors.fg0
                }

                MouseArea {
                    id: ccBackArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true // Enables the hover highlight!
                    onClicked: ccRoot.closeRequested()
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
                onOpenMenuRequested: ccRoot.currentView = 2
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
    // VIEW 1: WI-FI MENU
    // ==========================================
    WifiMenu {
        anchors.fill: parent
        anchors.margins: Config.ccPadding
        visible: ccRoot.currentView === 1
        onBackRequested: ccRoot.currentView = 0
    }

    // ==========================================
    // VIEW 2: BLUETOOTH MENU
    // ==========================================
    BluetoothMenu {
        anchors.fill: parent
        anchors.margins: Config.ccPadding
        visible: ccRoot.currentView === 2
        onBackRequested: ccRoot.currentView = 0
    }
}
