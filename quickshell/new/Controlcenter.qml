import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

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

    onVisibleChanged: {
        if (!visible) {
            ccBox.currentView = "main";
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: ccRoot.visible = false
    }

    // --- MAIN BACKGROUND BOX ---
    Rectangle {
        id: ccBox

        property string currentView: "main"

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 46
        anchors.rightMargin: 10

        width: currentView === "main" ? 420 : 400
        height: (currentView === "main" ? mainColumn.height : (currentView === "wifi" ? wifiMenuView.height : (currentView === "bluetooth" ? btMenuView.height : (currentView === "profile" ? profileMenuView.height : powerMenuView.height)))) + 40

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
                duration: 200
                easing.type: Easing.OutQuart
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 200
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
            spacing: 24

            visible: opacity > 0
            opacity: ccBox.currentView === "main" ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }

            // HEADER: User Profile & Power Buttons
            RowLayout {
                width: parent.width

                User {}

                Item {
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 8

                    Power {
                        onOpenMenu: ccBox.currentView = "power"
                    }
                    Settings {}
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
        // VIEW 2: MENUS
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
                    duration: 150
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
                    duration: 150
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
                    duration: 150
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
                    duration: 150
                }
            }

            onCloseRequested: ccBox.currentView = "main"
            onClosePanel: ccRoot.visible = false
        }
    }
}
