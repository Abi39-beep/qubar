import QtQuick

Item {
    id: settingRoot
    signal backRequested
    signal openThemeRequested
    signal openWallpaperRequested

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
            color: themeBtnArea.containsMouse || activeFocus ? Colors.bg2 : Colors.bg1
            border.color: themeBtnArea.containsMouse || activeFocus ? Colors.bg3 : Colors.bg2
            border.width: 1
            focus: true

            Behavior on color {
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

            Keys.onReturnPressed: settingRoot.openThemeRequested()
            MouseArea {
                id: themeBtnArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: settingRoot.openThemeRequested()
            }
        }

        // 2. WALLPAPERS BUTTON
        Rectangle {
            width: parent.width
            height: 52
            radius: 12
            color: wallBtnArea.containsMouse || activeFocus ? Colors.bg2 : Colors.bg1
            border.color: wallBtnArea.containsMouse || activeFocus ? Colors.bg3 : Colors.bg2
            border.width: 1
            focus: true

            Behavior on color {
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

            Keys.onReturnPressed: settingRoot.openWallpaperRequested()
            MouseArea {
                id: wallBtnArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: settingRoot.openWallpaperRequested()
            }
        }
    }
}
