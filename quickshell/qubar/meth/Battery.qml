import QtQuick
import Quickshell.Services.UPower
import ".."

Rectangle {
    id: batteryWidget
    width: 40
    height: 20
    radius: 11
    color: Colors.grey0
    anchors.verticalCenter: parent.verticalCenter
    property string activeProfile: ""
    readonly property int batPercent: UPower.displayDevice?.ready ? Math.round(UPower.displayDevice.percentage * 100) : 0
    readonly property bool isCharging: !UPower.onBattery
    Rectangle {
        id: fillBar
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: (batteryWidget.batPercent / 100) * (parent.width - 4)
        height: parent.height - 4
        radius: 9
        color: Colors.green
        anchors.leftMargin: 2
        Behavior on width {
            NumberAnimation {
                duration: 300
            }
        }
    }
    Row {
        anchors.centerIn: parent
        spacing: 1
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: batteryWidget.isCharging
            text: "󱐋"
            color: Colors.bg0
            font {
                pixelSize: 12
                family: "JetBrainsMono Nerd Font Propo"
                bold: true
            }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: batteryWidget.batPercent
            color: Colors.bg0
            font {
                pixelSize: 12
                family: "JetBrainsMono Nerd Font Propo"
                bold: true
                letterSpacing: -0.5
            }
        }
    }
}
