import QtQuick
import ".."

Item {
    id: settingRoot
    height: 224

    signal closeMenu
    signal openThemeMenu
    signal openWallpaperMenu
    signal openBarMenu

    property int currentIndex: -1

    onVisibleChanged: {
        if (visible) {
            forceActiveFocus();
            currentIndex = -1;
        }
    }

    // --- KEYBOARD NAVIGATION ---
    Keys.onEscapePressed: settingRoot.closeMenu()
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
            settingRoot.openThemeMenu();
        else if (currentIndex === 1)
            settingRoot.openWallpaperMenu();
        else if (currentIndex === 2)
            settingRoot.openBarMenu();
    }

    Column {
        anchors.fill: parent
        spacing: 12

        // --- HEADER ---
        Item {
            width: parent.width
            height: 32

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: backArea.containsMouse ? Colors.bg2 : "transparent"
                    border.color: Colors.bg2
                    border.width: 2

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: Colors.fg2
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                    }
                    MouseArea {
                        id: backArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: settingRoot.closeMenu()
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Settings"
                    color: Colors.fg0
                    font.pixelSize: 16
                    font.bold: true
                    font.family: "SF Pro Display"
                }
            }
        }

        // --- 1. THEMES BUTTON ---
        Rectangle {
            width: parent.width
            height: 52
            radius: 16

            color: (themeBtnArea.containsMouse || settingRoot.currentIndex === 0) ? Colors.bg2 : Colors.bg1
            border.color: (themeBtnArea.containsMouse || settingRoot.currentIndex === 0) ? Colors.bg3 : Colors.bg2
            border.width: 2

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
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "Themes"
                    color: Colors.fg0
                    font.family: "SF Pro Display"
                    font.pixelSize: 15
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
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
            }

            MouseArea {
                id: themeBtnArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: settingRoot.currentIndex = 0
                onClicked: settingRoot.openThemeMenu()
            }
        }

        // --- 2. WALLPAPERS BUTTON ---
        Rectangle {
            width: parent.width
            height: 52
            radius: 16

            color: (wallBtnArea.containsMouse || settingRoot.currentIndex === 1) ? Colors.bg2 : Colors.bg1
            border.color: (wallBtnArea.containsMouse || settingRoot.currentIndex === 1) ? Colors.bg3 : Colors.bg2
            border.width: 2

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
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "Wallpapers"
                    color: Colors.fg0
                    font.family: "SF Pro Display"
                    font.pixelSize: 15
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
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
            }

            MouseArea {
                id: wallBtnArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: settingRoot.currentIndex = 1
                onClicked: settingRoot.openWallpaperMenu()
            }
        }

        // --- 3. BAR LAYOUTS BUTTON ---
        Rectangle {
            width: parent.width
            height: 52
            radius: 16

            color: (barBtnArea.containsMouse || settingRoot.currentIndex === 2) ? Colors.bg2 : Colors.bg1
            border.color: (barBtnArea.containsMouse || settingRoot.currentIndex === 2) ? Colors.bg3 : Colors.bg2
            border.width: 2

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
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "Bar Layouts"
                    color: Colors.fg0
                    font.family: "SF Pro Display"
                    font.pixelSize: 15
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
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
            }

            MouseArea {
                id: barBtnArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: settingRoot.currentIndex = 2
                onClicked: settingRoot.openBarMenu()
            }
        }
    }
}
