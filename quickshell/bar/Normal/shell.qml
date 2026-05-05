import QtQuick
import Quickshell
import "." 

ShellRoot {
    PanelWindow {
        anchors.top: true
        anchors.left: true
        anchors.right: true
        height: 38 
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Qt.alpha(Colors.bg0, 0.90)

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 5
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
                anchors.rightMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                NotificationWidget {}
                ClipboardWidget {}
                VolumeWidget {}
                WifiWidget {}
                BluetoothWidget {}
                Battery {}
                PowerWidget {}
            }
        }
        OsdWindow {}
    }
}
