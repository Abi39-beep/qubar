import QtQuick
import Quickshell.Networking

Rectangle {
    id: root

    signal openMenu

    property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    property var activeNetwork: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null
    property bool isRadioOn: Networking.wifiEnabled
    property string currentSsid: activeNetwork ? activeNetwork.name : ""
    property real currentSignal: activeNetwork ? activeNetwork.signalStrength : 0
    property bool isHovered: menuArea.containsMouse || circleArea.containsMouse

    width: parent.width
    height: 56
    radius: 28
    color: isRadioOn ? (isHovered ? Qt.rgba(Colors.aqua.r, Colors.aqua.g, Colors.aqua.b, 0.85) : Colors.aqua) : (isHovered ? Colors.bg1 : Colors.bg0)
    border.color: Colors.bg3
    border.width: isRadioOn ? 0 : 2

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    function getWifiOpacity(sig) {
        if (root.currentSsid === "")
            return 1.0;
        if (sig >= 0.75)
            return 1.0;
        if (sig >= 0.50)
            return 0.75;
        if (sig >= 0.25)
            return 0.50;
        return 0.35;
    }

    Row {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 12

        // 1. THE TOGGLE ICON CIRCLE
        Rectangle {
            width: 44
            height: 44
            radius: 22
            color: root.isRadioOn ? (circleArea.containsMouse ? Qt.rgba(0, 0, 0, 0.45) : Qt.rgba(0, 0, 0, 0.30)) : (circleArea.containsMouse ? Colors.bg3 : Colors.bg2)

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Text {
                anchors.centerIn: parent
                text: ""
                font.family: "SF Pro Display"
                font.pixelSize: 18
                color: root.isRadioOn ? Colors.bg0 : Colors.fg0
                opacity: root.isRadioOn ? root.getWifiOpacity(root.currentSignal) : 0.6

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                    }
                }
            }

            MouseArea {
                id: circleArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    Networking.wifiEnabled = !Networking.wifiEnabled;
                }
            }
        }

        // 2. TEXT AND MENU EXPAND AREA
        Item {
            width: parent.width - 56
            height: parent.height

            Column {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 2

                Text {
                    text: "Wi-Fi"
                    font.family: "SF Pro Display"
                    font.pixelSize: 14
                    font.bold: true
                    color: root.isRadioOn ? Colors.bg0 : Colors.fg0
                }

                Text {
                    text: !root.isRadioOn ? "Off" : (root.currentSsid !== "" ? root.currentSsid : "On")
                    font.family: "SF Pro Display"
                    font.pixelSize: 12
                    color: root.isRadioOn ? Qt.rgba(Colors.bg0.r, Colors.bg0.g, Colors.bg0.b, 0.7) : Colors.fg3
                    width: parent.width
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                id: menuArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: root.openMenu()
            }
        }
    }
}
