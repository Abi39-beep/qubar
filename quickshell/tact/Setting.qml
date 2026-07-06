import QtQuick

Item {
    id: settingRoot
    signal backRequested
    signal openThemeRequested
    signal openWallpaperRequested
    signal openBarRequested

    property int currentIndex: -1

    onVisibleChanged: {
        if (visible) {
            forceActiveFocus();
            currentIndex = -1;
        }
    }

    // --- KEYBOARD NAVIGATION ---
    Keys.onEscapePressed: settingRoot.backRequested()
    Keys.onDownPressed: {
        if (currentIndex === -1)
            currentIndex = 0;
        else
            currentIndex = (currentIndex + 1) % 3;
    }
    Keys.onUpPressed: {
        if (currentIndex === -1)
            currentIndex = 2;
        else
            currentIndex = (currentIndex + 2) % 3;
    }
    Keys.onReturnPressed: if (currentIndex !== -1)
        executeCurrent()
    Keys.onEnterPressed: if (currentIndex !== -1)
        executeCurrent()

    function executeCurrent() {
        if (currentIndex === 0)
            settingRoot.openThemeRequested();
        else if (currentIndex === 1)
            settingRoot.openWallpaperRequested();
        else if (currentIndex === 2)
            settingRoot.openBarRequested();
    }

    Column {
        anchors.fill: parent
        spacing: 16

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
                    color: backArea.containsMouse ? Colors.bg2 : Colors.bg1
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
                        id: backArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: settingRoot.backRequested()
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "System Settings"
                    font.family: Config.fontName
                    font.pixelSize: 16
                    font.bold: true
                    color: Colors.fg0
                }
            }
        }

        // --- SETTINGS BUTTONS ---

        // 1. THEMES BUTTON
        Rectangle {
            width: parent.width
            height: 52
            radius: 12

            color: (themeBtnArea.containsMouse || settingRoot.currentIndex === 0) ? Colors.bg2 : Colors.bg1
            border.color: (themeBtnArea.containsMouse || settingRoot.currentIndex === 0) ? Colors.bg3 : Colors.bg2
            border.width: 1

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 16

                Text {
                    text: "󰸉"
                    color: Colors.aqua
                    font.family: Config.fontName
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "Themes"
                    color: Colors.fg0
                    font.family: Config.fontName
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: "󰅂"
                color: Colors.fg3
                font.family: Config.fontName
                font.pixelSize: 18
            }

            MouseArea {
                id: themeBtnArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: settingRoot.currentIndex = 0
                onClicked: settingRoot.openThemeRequested()
            }
        }

        // 2. WALLPAPERS BUTTON
        Rectangle {
            width: parent.width
            height: 52
            radius: 12

            color: (wallBtnArea.containsMouse || settingRoot.currentIndex === 1) ? Colors.bg2 : Colors.bg1
            border.color: (wallBtnArea.containsMouse || settingRoot.currentIndex === 1) ? Colors.bg3 : Colors.bg2
            border.width: 1

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 16

                Text {
                    text: "󰋩"
                    color: Colors.blue
                    font.family: Config.fontName
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "Wallpapers"
                    color: Colors.fg0
                    font.family: Config.fontName
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: "󰅂"
                color: Colors.fg3
                font.family: Config.fontName
                font.pixelSize: 18
            }

            MouseArea {
                id: wallBtnArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: settingRoot.currentIndex = 1
                onClicked: settingRoot.openWallpaperRequested()
            }
        }

        // 3. BAR LAYOUTS BUTTON
        Rectangle {
            width: parent.width
            height: 52
            radius: 12

            color: (barBtnArea.containsMouse || settingRoot.currentIndex === 2) ? Colors.bg2 : Colors.bg1
            border.color: (barBtnArea.containsMouse || settingRoot.currentIndex === 2) ? Colors.bg3 : Colors.bg2
            border.width: 1

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 16

                Text {
                    text: "󰹯"
                    color: Colors.aqua
                    font.family: Config.fontName
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "Bar Layouts"
                    color: Colors.fg0
                    font.family: Config.fontName
                    font.pixelSize: 14
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: "󰅂"
                color: Colors.fg3
                font.family: Config.fontName
                font.pixelSize: 18
            }

            MouseArea {
                id: barBtnArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: settingRoot.currentIndex = 2
                onClicked: settingRoot.openBarRequested()
            }
        }
    }
}
