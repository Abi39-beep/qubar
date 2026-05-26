import QtQuick
import "../.."

Row {
    width: parent.width
    height: 40
    spacing: 10

    Rectangle {
        width: (parent.width - 10) / 2
        height: parent.height
        radius: 8
        color: Colors.bg1
        border.width: 1
        border.color: Colors.bg2
        Row {
            anchors.centerIn: parent
            spacing: 10
            Text {
                text: "󰻠"
                color: Colors.blue
                font.pixelSize: 18
                font.family: "JetBrainsMono Nerd Font"
                anchors.verticalCenter: parent.verticalCenter
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Text {
                    text: "CPU"
                    color: Colors.grey1
                    font.pixelSize: 10
                    font.bold: true
                }
                Text {
                    text: dashWidget.cpuUsage
                    color: Colors.fg
                    font.pixelSize: 13
                    font.bold: true
                }
            }
        }
    }

    Rectangle {
        width: (parent.width - 10) / 2
        height: parent.height
        radius: 8
        color: Colors.bg1
        border.width: 1
        border.color: Colors.bg2
        Row {
            anchors.centerIn: parent
            spacing: 10
            Text {
                text: "󰍛"
                color: Colors.orange
                font.pixelSize: 18
                font.family: "JetBrainsMono Nerd Font"
                anchors.verticalCenter: parent.verticalCenter
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Text {
                    text: "Memory"
                    color: Colors.grey1
                    font.pixelSize: 10
                    font.bold: true
                }
                Text {
                    text: dashWidget.memUsage
                    color: Colors.fg
                    font.pixelSize: 13
                    font.bold: true
                }
            }
        }
    }
}
