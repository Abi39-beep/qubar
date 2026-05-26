import QtQuick
import Quickshell
import "../.."

Row {
    width: parent.width
    spacing: 10
    Repeater {
        model: dashWidget.actionModel
        Rectangle {
            width: (parent.width - 40) / 5
            height: 60
            radius: 10
            color: powerMouse.containsMouse ? Colors.bg2 : Colors.bg1
            border.width: 1
            border.color: Colors.bg2
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
            scale: powerMouse.pressed ? 0.92 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: 100
                }
            }

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
                    dashPopup.visible = false;
                    powerMenuWindow.visible = true;
                    bgDimmer.forceActiveFocus();
                    powerList.forceActiveFocus();
                    powerMenuWindow.handleTrigger(index, modelData.cmd);
                }
            }
        }
    }
}
