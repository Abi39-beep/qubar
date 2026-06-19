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
        // THE FIX: Smart back-navigation for all menus!
        if (currentView === 1 || currentView === 2 || currentView === 3) {
            currentView = 0; // Go to Main Grid
        } else if (currentView === 4) {
            currentView = 3; // From Themes, go back to Settings!
        } else {
            closeRequested(); // Close entirely
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
        Item {
            width: parent.width
            height: 36

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: ccBackArea.containsMouse ? Colors.bg2 : Colors.bg1
                    border.color: Colors.bg3
                    border.width: 1

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰁍"
                        font.family: Config.fontName
                        font.pixelSize: 18
                        color: Colors.fg0
                    }

                    MouseArea {
                        id: ccBackArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
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

            // --- THE NEW SETTINGS BUTTON ---
            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 36
                height: 36
                radius: 18
                color: settingsArea.containsMouse ? Colors.bg2 : Colors.bg1
                border.color: Colors.bg3
                border.width: 1

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰒓" // Gear Icon
                    font.family: Config.fontName
                    font.pixelSize: 18
                    color: Colors.fg0

                    RotationAnimation on rotation {
                        running: settingsArea.containsMouse
                        from: 0
                        to: 90
                        duration: 300
                        easing.type: Easing.OutQuart
                    }
                }

                MouseArea {
                    id: settingsArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: ccRoot.currentView = 3
                }
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
    // VIEW 1 & 2: WI-FI & BLUETOOTH
    // ==========================================
    WifiMenu {
        anchors.fill: parent
        anchors.margins: Config.ccPadding
        visible: ccRoot.currentView === 1
        onBackRequested: ccRoot.currentView = 0
    }

    BluetoothMenu {
        anchors.fill: parent
        anchors.margins: Config.ccPadding
        visible: ccRoot.currentView === 2
        onBackRequested: ccRoot.currentView = 0
    }

    // ==========================================
    // VIEW 3: SETTINGS MENU
    // ==========================================
    Setting {
        anchors.fill: parent
        anchors.margins: Config.ccPadding
        visible: ccRoot.currentView === 3
        onBackRequested: ccRoot.currentView = 0
        onOpenThemeRequested: ccRoot.currentView = 4
    }

    // ==========================================
    // VIEW 4: THEME MENU
    // ==========================================
    ThemeMenu {
        anchors.fill: parent
        anchors.margins: Config.ccPadding
        visible: ccRoot.currentView === 4
        onBackRequested: ccRoot.currentView = 3
    }
}
