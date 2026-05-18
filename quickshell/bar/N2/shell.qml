import QtQuick
import Quickshell
import Quickshell.Wayland
import "./widget/"

ShellRoot {
    PanelWindow {
        anchors.top: true
        anchors.right: true
        anchors.left: true
        height: 38
        color: "transparent"
        WlrLayershell.namespace: "normal2"
        WlrLayershell.layer: WlrLayer.Top

        Rectangle {
            anchors.fill: parent
            color: Qt.alpha(Colors.bg0, 0.75)

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Clock {}
                Workspaces {}
                WifiWidget {}
                BluetoothWidget {}
                Battery {}
                DashboardWidget {}
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 15
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        OsdWindow {}
    }
}
