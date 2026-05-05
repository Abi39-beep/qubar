import QtQuick
import Quickshell
import "." 

ShellRoot {
    PanelWindow {
        anchors.top: true
        width: 700
        height: 38 
        margins.top: 2
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Qt.alpha(Colors.bg0, 0.70)
            radius: 18

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 15 
                anchors.verticalCenter: parent.verticalCenter
                Clock {} 
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                Workspaces {} 
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 15 
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

                WifiWidget {}
                BluetoothWidget {}
                Battery {}
                DashboardWidget {}
            }
        }
        OsdWindow {}
    }
}
