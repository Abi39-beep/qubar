import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import ".."

PanelWindow {
    id: rightOSDWindow
    visible: false
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "rightosd"

    anchors {
        right: true
        top: true
        bottom: true
        left: true
    }
    color: "transparent"

    function toggleRight() {
        rightOSDWindow.visible = !rightOSDWindow.visible;
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            rightOSDWindow.visible = false;
        }
    }

    Rectangle {
        id: rightBg
        width: 440
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        anchors.margins: 20
        color: Qt.alpha(Colors.bg0, 0.75)
        border.color: Colors.bg2
        border.width: 2
        radius: 15

        MouseArea {
            anchors.fill: parent
        }

        focus: true
        Keys.onEscapePressed: {
            rightOSDWindow.visible = false;
        }
        onVisibleChanged: {
            if (visible) {
                rightBg.forceActiveFocus();
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20

            // 1. Direct Power Button Row
            Row {
                width: parent.width
                spacing: 10
                Repeater {
                    model: powerMenu.actionModel
                    Rectangle {
                        width: (parent.width - 40) / 5
                        height: 60
                        radius: 10
                        color: powerMouse.containsMouse ? Colors.bg2 : Colors.bg1
                        border.width: 1
                        border.color: Colors.bg2
                        Column {
                            anchors.centerIn: parent
                            spacing: 4
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.icon
                                color: modelData.color
                                font.pixelSize: 18
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.name
                                color: Colors.fg
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                        MouseArea {
                            id: powerMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                rightOSDWindow.visible = false;
                                powerMenu.openMenu(index);
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Colors.bg2
            }

            // 2. CPU, Memory, and Battery Perfectly Aligned in One Row!
            Row {
                width: parent.width
                height: 50
                spacing: 10

                System {
                    // System.qml handles 2 items. We give it 2/3 of the total width + the 10px spacing between them.
                    width: ((parent.width - 20) / 3) * 2 + 10
                }

                Battery {
                    // Battery.qml handles 1 item. We give it exactly 1/3 of the total width.
                    width: (parent.width - 20) / 3

                    onCloseMainPanel: {
                        rightOSDWindow.visible = false;
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Colors.bg2
            }

            // 3. Network & Bluetooth
            Row {
                width: parent.width
                spacing: 15
                Network {
                    onCloseMainPanel: {
                        rightOSDWindow.visible = false;
                    }
                }
                Bluetooth {
                    onCloseMainPanel: {
                        rightOSDWindow.visible = false;
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Colors.bg2
            }

            // 4. Templates
            Template {
                onCloseMainPanel: {
                    rightOSDWindow.visible = false;
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Colors.bg2
            }

            property int activeTab: 0

            // 5. Tabs
            Row {
                width: parent.width
                height: 40
                spacing: 15
                Rectangle {
                    width: (parent.width - 15) / 2
                    height: parent.height
                    radius: 8
                    color: parent.parent.activeTab === 0 ? Colors.bg2 : Colors.bg1
                    border.width: 1
                    border.color: parent.parent.activeTab === 0 ? Colors.bg3 : Colors.bg2
                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            text: "󰂚"
                            color: parent.parent.parent.parent.activeTab === 0 ? Colors.yellow : Colors.grey1
                            font.pixelSize: 14
                            font.family: "JetBrainsMono Nerd Font"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Notifications"
                            color: Colors.fg
                            font.bold: true
                            font.pixelSize: 13
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            parent.parent.parent.activeTab = 0;
                        }
                    }
                }
                Rectangle {
                    width: (parent.width - 15) / 2
                    height: parent.height
                    radius: 8
                    color: parent.parent.activeTab === 1 ? Colors.bg2 : Colors.bg1
                    border.width: 1
                    border.color: parent.parent.activeTab === 1 ? Colors.bg3 : Colors.bg2
                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            text: "󰅌"
                            color: parent.parent.parent.parent.activeTab === 1 ? Colors.orange : Colors.grey1
                            font.pixelSize: 14
                            font.family: "JetBrainsMono Nerd Font"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Clipboard"
                            color: Colors.fg
                            font.bold: true
                            font.pixelSize: 13
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            parent.parent.parent.activeTab = 1;
                        }
                    }
                }
            }

            // 6. Content Views
            Item {
                width: parent.width
                height: parent.parent.height - y - 25

                Notification {
                    visible: parent.parent.activeTab === 0
                }

                Clipboard {
                    visible: parent.parent.activeTab === 1
                }
            }
        }
    }
}
