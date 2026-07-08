import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import ".."

PanelWindow {
    id: ccRoot
    property alias currentView: ccBox.currentView

    WlrLayershell.namespace: "control_center"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    screen: Quickshell.screens[0] || null

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: false

    Timer {
        id: resetTimer
        interval: 300
        onTriggered: ccBox.currentView = "main"
    }

    onVisibleChanged: {
        if (!visible) {
            resetTimer.restart();
        } else {
            resetTimer.stop();
            if (ccBox.currentView === "main") {
                ccBox.forceActiveFocus();
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: ccRoot.visible = false
    }

    // --- MAIN BACKGROUND BOX ---
    Rectangle {
        id: ccBox

        focus: true
        Keys.onEscapePressed: ccRoot.visible = false

        property string currentView: "main"

        onCurrentViewChanged: {
            if (currentView === "main" && ccRoot.visible) {
                ccBox.forceActiveFocus();
            }
        }

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 46
        anchors.rightMargin: 10

        width: currentView === "main" ? 420 : 400
        height: (currentView === "main" ? mainColumn.height : (currentView === "wifi" ? wifiMenuView.height : (currentView === "bluetooth" ? btMenuView.height : (currentView === "profile" ? profileMenuView.height : (currentView === "settings" ? settingsMenuView.height : (currentView === "theme" ? themeMenuView.height : (currentView === "wallpaper" ? wallMenuView.height : (currentView === "bar" ? barMenuView.height : (currentView === "calendar" ? calMenuView.height : powerMenuView.height))))))))) + 40

        color: Colors.bg0
        radius: 24
        border.color: Colors.bg2
        border.width: 2
        clip: true

        transformOrigin: Item.TopRight
        scale: ccRoot.visible ? 1.0 : 0.8
        opacity: ccRoot.visible ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutBack
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: ccBox.opacity < 0.1 ? 0 : 200
                easing.type: Easing.OutQuart
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: ccBox.opacity < 0.1 ? 0 : 200
                easing.type: Easing.OutQuart
            }
        }

        MouseArea {
            anchors.fill: parent
        }

        // ==========================================
        // VIEW 1: THE MAIN CONTROL CENTER
        // ==========================================
        Column {
            id: mainColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            spacing: 16

            visible: opacity > 0
            opacity: ccBox.currentView === "main" ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: ccBox.opacity < 0.1 ? 0 : 150
                }
            }

            // HEADER: User Profile & Power Buttons
            RowLayout {
                width: parent.width

                User {
                    onOpenCalendar: ccBox.currentView = "calendar"
                }

                Item {
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 8

                    Power {
                        onOpenMenu: ccBox.currentView = "power"
                    }

                    // Static Settings Gear
                    Rectangle {
                        implicitWidth: 36
                        implicitHeight: 36
                        radius: 18
                        color: gearArea.containsMouse ? Colors.bg2 : "transparent"
                        border.color: Colors.bg2
                        border.width: 2

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: Colors.fg1
                            font.pixelSize: 16
                            font.family: "JetBrainsMono Nerd Font"
                        }

                        MouseArea {
                            id: gearArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ccBox.currentView = "settings"
                        }
                    }
                }
            }

            RowLayout {
                width: parent.width
                spacing: 16

                // LEFT COLUMN
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: togglesCol.implicitHeight + 24
                    color: Colors.bg1
                    border.color: Colors.bg2
                    border.width: 2
                    radius: 20

                    ColumnLayout {
                        id: togglesCol
                        anchors.centerIn: parent
                        width: parent.width - 24
                        spacing: 12

                        Wifi {
                            onOpenMenu: ccBox.currentView = "wifi"
                        }
                        Bluetooth {
                            onOpenMenu: ccBox.currentView = "bluetooth"
                        }
                        Profile {
                            onOpenMenu: ccBox.currentView = "profile"
                        }
                    }
                }

                // RIGHT COLUMN (CPU/RAM)
                System {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                }
            }

            Rectangle {
                width: parent.width
                height: 128
                color: Colors.bg1
                radius: 16
                border.color: Colors.bg2
                border.width: 2

                Bmslider {
                    anchors.centerIn: parent
                    width: parent.width - 32
                }
            }
        }

        // ==========================================
        // VIEW 2: ALL MENUS
        // ==========================================
        Wifimenu {
            id: wifiMenuView
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            visible: opacity > 0
            opacity: ccBox.currentView === "wifi" ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation {
                    duration: ccBox.opacity < 0.1 ? 0 : 150
                }
            }
            onCloseMenu: ccBox.currentView = "main"
        }

        Bluetoothmenu {
            id: btMenuView
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            visible: opacity > 0
            opacity: ccBox.currentView === "bluetooth" ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation {
                    duration: ccBox.opacity < 0.1 ? 0 : 150
                }
            }
            onCloseMenu: ccBox.currentView = "main"
        }

        Profilemenu {
            id: profileMenuView
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            visible: opacity > 0
            opacity: ccBox.currentView === "profile" ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation {
                    duration: ccBox.opacity < 0.1 ? 0 : 150
                }
            }
            onCloseMenu: ccBox.currentView = "main"
        }

        Powermenu {
            id: powerMenuView
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            visible: opacity > 0
            opacity: ccBox.currentView === "power" ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation {
                    duration: ccBox.opacity < 0.1 ? 0 : 150
                }
            }
            onCloseRequested: ccBox.currentView = "main"
            onClosePanel: ccRoot.visible = false
        }

        Settings {
            id: settingsMenuView
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            visible: opacity > 0
            opacity: ccBox.currentView === "settings" ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation {
                    duration: ccBox.opacity < 0.1 ? 0 : 150
                }
            }
            onCloseMenu: ccBox.currentView = "main"
            onOpenThemeMenu: ccBox.currentView = "theme"
            onOpenWallpaperMenu: ccBox.currentView = "wallpaper"
            onOpenBarMenu: ccBox.currentView = "bar"
        }

        Thememenu {
            id: themeMenuView
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            visible: opacity > 0
            opacity: ccBox.currentView === "theme" ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation {
                    duration: ccBox.opacity < 0.1 ? 0 : 150
                }
            }
            onCloseMenu: ccBox.currentView = "settings"
        }

        Wallpapermenu {
            id: wallMenuView
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            visible: opacity > 0
            opacity: ccBox.currentView === "wallpaper" ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation {
                    duration: ccBox.opacity < 0.1 ? 0 : 150
                }
            }
            onCloseMenu: ccBox.currentView = "settings"
        }

        Barmenu {
            id: barMenuView
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20

            visible: opacity > 0
            opacity: ccBox.currentView === "bar" ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: ccBox.opacity < 0.1 ? 0 : 150
                }
            }

            onCloseMenu: ccBox.currentView = "settings"
        }

        Calendarmenu {
            id: calMenuView
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20

            visible: opacity > 0
            opacity: ccBox.currentView === "calendar" ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: ccBox.opacity < 0.1 ? 0 : 150
                }
            }

            onCloseMenu: ccBox.currentView = "main"
        }
    }
}
