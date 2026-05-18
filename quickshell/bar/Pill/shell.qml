import QtQuick
import Quickshell
import Quickshell.Wayland
import "./meth/" 

ShellRoot {
    PanelWindow {
        anchors.top: true
        width: 410
        height: 38 
        margins.top: 5
        color: "transparent"
        WlrLayershell.namespace: "pill"
        WlrLayershell.layer: WlrLayer.Top

        Rectangle {
            anchors.fill: parent
            color: Qt.alpha(Colors.bg0, 0.75)
            border.color: Colors.bg2
            border.width: 1
            radius: 18

            // 1. One master Row that holds everything and sits dead center
            Row {
                anchors.centerIn: parent 
                spacing: 10 // 2. Gap between Clock, Workspaces, and the Tray block

                // Left item (Now just the first item in the centered row)
                Clock {
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Center item
                Workspaces {
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Right items (Kept in a nested Row so they keep their smaller 5px spacing)
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    WifiWidget {}
                    BluetoothWidget {}
                    Battery {}
                    DashboardWidget {}
                }
            }
        }
        OsdWindow {}
    }
}
