import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    property bool isActive: false
    property string subText: "Checking..."

    height: Config.ccToggleHeight
    radius: Config.ccToggleRadius
    color: isActive ? Colors.aqua : Colors.bg0
    border.color: Colors.bg3
    border.width: isActive ? 0 : 1

    Process {
        id: btProc
        command: ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo 'On' || echo 'Off'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let status = data.trim();
                root.isActive = (status === "On");
                root.subText = status;
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            btProc.running = false;
            btProc.running = true;
        }
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 16
        spacing: 12

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "󰂯"
            font.family: Config.fontName
            font.pixelSize: Config.fontSizeCcToggleIcon
            color: root.isActive ? Colors.bg0 : Colors.fg0
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text {
                text: "Bluetooth"
                font.family: Config.fontName
                font.pixelSize: Config.fontSizeCcToggleTitle
                font.bold: true
                color: root.isActive ? Colors.bg0 : Colors.fg0
            }
            Text {
                text: root.subText
                font.family: Config.fontName
                font.pixelSize: Config.fontSizeCcToggleSub
                color: root.isActive ? Colors.bg1 : Colors.fg3
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: parent.opacity = 0.8
        onExited: parent.opacity = 1.0
    }
}
