pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "meth"

ShellRoot {
    id: root

    function toggleControlCenter() {
        controlCenterWindow.visible = !controlCenterWindow.visible;
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors.top: true

            // Exact dimensions and margins from your qubar design
            width: 370
            height: 38
            margins.top: 5

            color: "transparent"
            WlrLayershell.namespace: "pill"
            WlrLayershell.layer: WlrLayer.Top

            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(Colors.bg0, 1.00)
                border.color: Colors.bg2
                border.width: 1
                radius: 18

                Row {
                    anchors.centerIn: parent
                    spacing: 10

                    Clock {
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Workspaces {
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Networking {
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        BluetoothWidget {
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Battery {
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }

    OsdWindow {
        id: osdWindow
    }

    Applauncher {
        id: myLauncher
    }

    Controlcenter {
        id: controlCenterWindow
    }

    Keybinds {
        launcherTarget: myLauncher
        controlCenterTarget: controlCenterWindow
    }
}
