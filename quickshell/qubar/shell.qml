pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "meth"

// qmllint disable unqualified

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
            margins.top: 10

            width: pillBg.implicitWidth
            height: 38

            color: "transparent"
            WlrLayershell.namespace: "pill"
            WlrLayershell.layer: WlrLayer.Top

            Rectangle {
                id: pillBg
                anchors.fill: parent
                implicitWidth: mainLayout.implicitWidth + 32
                color: Qt.alpha(Colors.bg0, 1.00)
                border.color: Colors.bg2
                border.width: 1
                radius: 18

                RowLayout {
                    id: mainLayout
                    anchors.centerIn: parent
                    spacing: 25

                    Clock {}

                    Workspaces {
                        Layout.preferredWidth: 146
                        Layout.preferredHeight: 146
                        Layout.maximumWidth: 146
                    }

                    RowLayout {
                        spacing: 14

                        Networking {
                            onOpenWifiMenu: {
                                controlCenterWindow.visible = true;
                                controlCenterWindow.currentView = "wifi";
                            }
                        }

                        BluetoothWidget {
                            onOpenBtMenu: {
                                controlCenterWindow.visible = true;
                                controlCenterWindow.currentView = "bluetooth";
                            }
                        }

                        Battery {
                            onOpenProfileMenu: {
                                controlCenterWindow.visible = true;
                                controlCenterWindow.currentView = "profile";
                            }
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
